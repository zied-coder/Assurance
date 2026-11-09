import { Injectable } from '@angular/core';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

/**
 * Génération de contrats PDF Assurances.
 *
 * Approche : API native jsPDF + jspdf-autotable (texte vectoriel net,
 * sélectionnable, pagination automatique propre, fichiers légers).
 * Remplace l'ancienne approche html2canvas (image floue, coupures de page).
 *
 * Installation :
 *   npm install jspdf jspdf-autotable
 * (html2canvas n'est plus nécessaire pour ce service)
 */
@Injectable({
  providedIn: 'root',
})
export class PdfService {
  // Charte Assurances
  private readonly PRIMARY: readonly number[] = [43, 57, 144]; // #2B3990
  private readonly PRIMARY_DARK: readonly number[] = [26, 36, 114]; // #1a2472
  private readonly GRAY: readonly number[] = [100, 116, 139];
  private readonly GRAY_SOFT: readonly number[] = [220, 224, 245];
  private readonly LIGHT_GRAY: readonly number[] = [243, 244, 246];
  private readonly BORDER: readonly number[] = [229, 231, 235];
  private readonly TEXT: readonly number[] = [26, 26, 46];
  private readonly GREEN: readonly number[] = [16, 185, 129];
  private readonly RED: readonly number[] = [239, 68, 68];
  private readonly AMBER: readonly number[] = [245, 158, 11];

  private readonly MARGIN = 15;

  private pageWidth = 0;
  private pageHeight = 0;
  private y = 0;

  constructor() {}

  // =========================================================================
  // POINT D'ENTRÉE
  // =========================================================================
  async generateContratPDF(contrat: any): Promise<void> {
    try {
      const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
      this.pageWidth = doc.internal.pageSize.getWidth();
      this.pageHeight = doc.internal.pageSize.getHeight();
      this.y = 0;

      this.addHeader(doc, contrat);
      this.addContratInfo(doc, contrat);
      this.addPeriode(doc, contrat);
      this.addAssure(doc, contrat);
      this.addGaranties(doc, contrat);
      this.addObjets(doc, contrat);
      this.addConditions(doc);
      this.addSignatures(doc);
      this.addFooter(doc, contrat);

      const filename = `Contrat_${contrat.numero ?? 'Assurances'}_${new Date()
        .toISOString()
        .split('T')[0]}.pdf`;
      doc.save(filename);
    } catch (error) {
      console.error('Erreur lors de la génération du PDF:', error);
      alert('Erreur lors de la génération du PDF. Veuillez réessayer.');
    }
  }

  // =========================================================================
  // HELPERS COULEUR (compatibles typage jsPDF)
  // =========================================================================
  private setFill(doc: jsPDF, c: readonly number[]): void {
    doc.setFillColor(c[0], c[1], c[2]);
  }
  private setText(doc: jsPDF, c: readonly number[]): void {
    doc.setTextColor(c[0], c[1], c[2]);
  }
  private setDraw(doc: jsPDF, c: readonly number[]): void {
    doc.setDrawColor(c[0], c[1], c[2]);
  }
  /** Tuple mutable [r,g,b] attendu par le type Color de jspdf-autotable. */
  private rgb(c: readonly number[]): [number, number, number] {
    return [c[0], c[1], c[2]];
  }

  // =========================================================================
  // FORMATAGE
  // =========================================================================
  private formatDate(date: any): string {
    if (!date) return 'N/A';
    try {
      return new Date(date).toLocaleDateString('fr-FR');
    } catch {
      return 'N/A';
    }
  }

  /** Évite l'espace insécable étroit (U+202F) de toLocaleString, mal rendu par jsPDF. */
  private formatMoney(v: any): string {
    if (v === null || v === undefined || isNaN(Number(v))) return 'N/A';
    return Number(v)
      .toFixed(0)
      .replace(/\B(?=(\d{3})+(?!\d))/g, ' ') + ' TND';
  }

  // =========================================================================
  // MISE EN PAGE
  // =========================================================================
  private checkPageBreak(doc: jsPDF, needed: number): void {
    if (this.y + needed > this.pageHeight - 20) {
      doc.addPage();
      this.y = this.MARGIN + 5;
    }
  }

  private addHeader(doc: jsPDF, contrat: any): void {
    const h = 40;
    this.setFill(doc, this.PRIMARY);
    doc.rect(0, 0, this.pageWidth, h, 'F');
    this.setFill(doc, this.PRIMARY_DARK);
    doc.rect(0, h, this.pageWidth, 1.5, 'F');

    // Logo
    doc.setFillColor(255, 255, 255);
    doc.roundedRect(this.MARGIN, 10, 20, 20, 2, 2, 'F');
    this.setText(doc, this.PRIMARY);
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(15);
    doc.text('Assurances', this.MARGIN + 10, 22.5, { align: 'center' });

    // Nom société
    doc.setTextColor(255, 255, 255);
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(13);
    doc.text('Assurances', this.MARGIN + 25, 18);
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(8);
    this.setText(doc, this.GRAY_SOFT);
    doc.text("Compagnie d'assurances", this.MARGIN + 25, 23.5);

    // Titre + réf à droite
    doc.setTextColor(255, 255, 255);
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(15);
    doc.text("CONTRAT D'ASSURANCE", this.pageWidth - this.MARGIN, 16, { align: 'right' });
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(8);
    this.setText(doc, this.GRAY_SOFT);
    doc.text(`N° ${contrat.numero ?? 'N/A'}`, this.pageWidth - this.MARGIN, 22, {
      align: 'right',
    });
    doc.text('info@bna.tn   +216 71 940 000', this.pageWidth - this.MARGIN, 27, {
      align: 'right',
    });

    this.y = h + 12;
  }

  private sectionTitle(doc: jsPDF, title: string): void {
    this.checkPageBreak(doc, 16);
    this.setText(doc, this.PRIMARY);
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(11);
    doc.text(title.toUpperCase(), this.MARGIN, this.y);
    this.y += 2.5;
    this.setDraw(doc, this.PRIMARY);
    doc.setLineWidth(0.5);
    doc.line(this.MARGIN, this.y, this.pageWidth - this.MARGIN, this.y);
    this.y += 7;
  }

  private drawBadge(doc: jsPDF, text: string, x: number, baseline: number, color: readonly number[]): void {
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(8);
    const w = doc.getTextWidth(text) + 5;
    this.setFill(doc, color);
    doc.roundedRect(x, baseline - 3.7, w, 5.2, 1, 1, 'F');
    doc.setTextColor(255, 255, 255);
    doc.text(text, x + 2.5, baseline);
  }

  private infoGrid(
    doc: jsPDF,
    items: { label: string; value: string; badge?: readonly number[] }[]
  ): void {
    const colW = (this.pageWidth - this.MARGIN * 2) / 2;
    const rowH = 13;
    for (let i = 0; i < items.length; i += 2) {
      this.checkPageBreak(doc, rowH);
      const row = items.slice(i, i + 2);
      row.forEach((it, idx) => {
        const x = this.MARGIN + idx * colW;
        doc.setFont('helvetica', 'bold');
        doc.setFontSize(7.5);
        this.setText(doc, this.GRAY);
        doc.text(it.label.toUpperCase(), x, this.y);
        if (it.badge) {
          this.drawBadge(doc, it.value, x, this.y + 6, it.badge);
        } else {
          doc.setFont('helvetica', 'normal');
          doc.setFontSize(10);
          this.setText(doc, this.TEXT);
          doc.text(it.value, x, this.y + 6);
        }
      });
      this.y += rowH;
    }
    this.y += 2;
  }

  private renderTable(doc: jsPDF, head: string[], body: any[][]): void {
    autoTable(doc, {
      startY: this.y,
      margin: { left: this.MARGIN, right: this.MARGIN },
      head: [head],
      body,
      theme: 'grid',
      headStyles: {
        fillColor: this.rgb(this.PRIMARY),
        textColor: 255,
        fontStyle: 'bold',
        fontSize: 9,
        cellPadding: 3,
      },
      bodyStyles: { fontSize: 9, textColor: this.rgb(this.TEXT), cellPadding: 3 },
      alternateRowStyles: { fillColor: this.rgb(this.LIGHT_GRAY) },
      styles: { lineColor: this.rgb(this.BORDER), lineWidth: 0.1 },
    });
    this.y = (doc as any).lastAutoTable.finalY + 9;
  }

  // =========================================================================
  // SECTIONS
  // =========================================================================
  private addContratInfo(doc: jsPDF, c: any): void {
    this.sectionTitle(doc, 'Informations du contrat');
    this.infoGrid(doc, [
      { label: 'Numéro de contrat', value: c.numero ?? 'N/A' },
      { label: "Type d'assurance", value: c.type ?? 'N/A' },
      { label: 'Formule', value: c.formule || 'Standard' },
      { label: 'Statut', value: c.statut ?? 'N/A', badge: c.statut === 'ACTIF' ? this.GREEN : this.RED },
      { label: 'Prime annuelle', value: this.formatMoney(c.prime) },
      { label: 'Niveau de risque', value: c.riskLevel || 'N/A' },
    ]);
  }

  private addPeriode(doc: jsPDF, c: any): void {
    this.sectionTitle(doc, 'Période de couverture');
    this.infoGrid(doc, [
      { label: 'Date de début', value: this.formatDate(c.dateDebut) },
      { label: 'Date de fin', value: this.formatDate(c.dateFin) },
      { label: "Date d'émission", value: this.formatDate(c.createdAt) },
      {
        label: 'État du paiement',
        value: c.etatPaiement === 'A_JOUR' ? 'À JOUR' : 'EN ATTENTE',
        badge: c.etatPaiement === 'A_JOUR' ? this.GREEN : this.AMBER,
      },
    ]);
  }

  private addAssure(doc: jsPDF, c: any): void {
    this.sectionTitle(doc, "Informations de l'assuré");
    this.infoGrid(doc, [
      { label: 'Email', value: c.userEmail || c.email || 'N/A' },
      { label: 'CIN', value: c.userCin || c.cin || 'N/A' },
    ]);
  }

  private addGaranties(doc: jsPDF, c: any): void {
    if (!c.garanties || c.garanties.length === 0) return;
    this.sectionTitle(doc, 'Garanties incluses');
    this.renderTable(
      doc,
      ['Garantie', 'Plafond / Limite'],
      c.garanties.map((g: any) => [g.nom ?? '—', g.plafond ? this.formatMoney(g.plafond) : 'Incluse'])
    );
  }

  private addObjets(doc: jsPDF, c: any): void {
    if (!c.objets || c.objets.length === 0) return;
    this.sectionTitle(doc, 'Biens assurés');
    this.renderTable(
      doc,
      ['Description', 'Type', 'Valeur déclarée'],
      c.objets.map((o: any) => {
        let desc = 'Bien non spécifié';
        if (o.type === 'AUTO') desc = `${o.marque ?? ''} ${o.modele ?? ''}`.trim();
        else if (o.type === 'HABITATION') desc = o.adresseBien ?? 'Habitation';
        const val = o.valeurVehicule ?? o.valeurBien;
        return [desc, o.type ?? '—', val ? this.formatMoney(val) : 'N/A'];
      })
    );
  }

  private addConditions(doc: jsPDF): void {
    this.sectionTitle(doc, 'Conditions générales');
    const list = [
      'Le présent contrat est soumis aux conditions générales et particulières de Assurances.',
      "La prime est payable annuellement à compter de la date d'effet du contrat.",
      "L'assuré s'engage à déclarer tout sinistre dans un délai de 48 heures.",
      "Ce contrat prend fin à la date d'expiration sauf en cas de non-paiement de la prime.",
      'Pour toute réclamation ou question, veuillez contacter notre service client.',
    ];
    const maxW = this.pageWidth - this.MARGIN * 2 - 6;
    list.forEach((c) => {
      const lines = doc.splitTextToSize(c, maxW);
      const blockH = lines.length * 4.8 + 2.5;
      this.checkPageBreak(doc, blockH);
      doc.setFont('helvetica', 'bold');
      doc.setFontSize(10);
      this.setText(doc, this.PRIMARY);
      doc.text('•', this.MARGIN, this.y);
      doc.setFont('helvetica', 'normal');
      doc.setFontSize(9.5);
      this.setText(doc, this.TEXT);
      doc.text(lines, this.MARGIN + 5, this.y);
      this.y += blockH;
    });
    this.y += 4;
  }

  private addSignatures(doc: jsPDF): void {
    this.checkPageBreak(doc, 32);
    this.y += 4;
    const colW = (this.pageWidth - this.MARGIN * 2) / 2;
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(9);
    this.setText(doc, this.TEXT);
    doc.text("Signature de l'assuré", this.MARGIN, this.y);
    doc.text('Pour Assurances', this.MARGIN + colW, this.y);
    this.setDraw(doc, this.GRAY);
    doc.setLineWidth(0.2);
    doc.line(this.MARGIN, this.y + 18, this.MARGIN + colW - 15, this.y + 18);
    doc.line(this.MARGIN + colW, this.y + 18, this.pageWidth - this.MARGIN, this.y + 18);
  }

  private addFooter(doc: jsPDF, c: any): void {
    const pageCount = doc.getNumberOfPages();
    const now = new Date();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      const fy = this.pageHeight - 12;
      this.setDraw(doc, this.BORDER);
      doc.setLineWidth(0.2);
      doc.line(this.MARGIN, fy, this.pageWidth - this.MARGIN, fy);
      doc.setFont('helvetica', 'normal');
      doc.setFontSize(7.5);
      this.setText(doc, this.GRAY);
      doc.text(
        `Assurances © ${now.getFullYear()} - Tous droits réservés`,
        this.MARGIN,
        fy + 5
      );
      doc.text(`Réf. ${c.numero ?? '—'}`, this.pageWidth / 2, fy + 5, { align: 'center' });
      doc.text(`Page ${i} / ${pageCount}`, this.pageWidth - this.MARGIN, fy + 5, {
        align: 'right',
      });
    }
  }
}