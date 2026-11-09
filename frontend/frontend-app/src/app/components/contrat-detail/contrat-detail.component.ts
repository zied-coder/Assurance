import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { ContratService } from '../../services/contrat.service';
import { DemandeServiceService } from '../../services/demande-service.service';
import { PdfService } from '../../services/pdf.service';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-contrat-detail',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './contrat-detail.component.html',
  styleUrls: ['./contrat-detail.component.css']
})
export class ContratDetailComponent implements OnInit {

  data: any;
  isUser = false;
  isGestionnaire = false;
  isGeneratingPdf = false;

  constructor(
    private contratService: ContratService,
    private demandeService: DemandeServiceService,
    private authService: AuthService,
    private pdfService: PdfService,
    private route: ActivatedRoute
  ) {}

  showRequestModal = false;
  requestType = '';
  requestDescription = '';

  // New fields for modification
  modifiedValeur: number | null = null;
  modifiedPuissance: number | null = null;
  modifiedAge: number | null = null;
  modifiedMarque: string = '';
  modifiedModele: string = '';
  modifiedImmatriculation: string = '';
  modifiedFormule: string = '';

  // Habitation fields
  modifiedValeurBien: number | null = null;
  modifiedNiveauSecurite: string = '';

  openRequestModal(type: string) {
    this.requestType = type;
    this.showRequestModal = true;

    // Initialize with current values if modification
    if (type === 'MODIFICATION') {
      if (this.data?.objets?.[0]) {
        const auto = this.data.objets.find((o: any) => o.type === 'AUTO');
        if (auto) {
          this.modifiedValeur = auto.valeurVehicule;
          this.modifiedPuissance = auto.puissanceFiscale;
          this.modifiedAge = auto.ageVehicule;
          this.modifiedMarque = auto.marque;
          this.modifiedModele = auto.modele;
          this.modifiedImmatriculation = auto.immatriculation;
        }

        const habitation = this.data.objets.find((o: any) => o.type === 'HABITATION');
        if (habitation) {
          this.modifiedValeurBien = habitation.valeurBien;
          this.modifiedNiveauSecurite = habitation.niveauSecurite;
        }
      }
      if (this.data?.contrat) {
        this.modifiedFormule = this.data.contrat.formule;
      }
    }
  }

  submitRequest() {
    const user = this.authService.getUser();
    if (!user) return;

    let updatePayloadObj: any = {
      formule: this.modifiedFormule
    };

    if (this.data.contrat.type === 'AUTO') {
      updatePayloadObj = {
        ...updatePayloadObj,
        valeurVehicule: this.modifiedValeur,
        puissanceFiscale: this.modifiedPuissance,
        ageVehicule: this.modifiedAge,
        marque: this.modifiedMarque,
        modele: this.modifiedModele,
        immatriculation: this.modifiedImmatriculation
      };
    } else if (this.data.contrat.type === 'HABITATION') {
      updatePayloadObj = {
        ...updatePayloadObj,
        valeurBien: this.modifiedValeurBien,
        niveauSecurite: this.modifiedNiveauSecurite
      };
    }

    const request = {
      contratId: this.data.contrat.id,
      userId: user.id,
      type: this.requestType,
      description: this.requestDescription,
      updatePayload: this.requestType === 'MODIFICATION' ? JSON.stringify(updatePayloadObj) : ''
    };

    this.demandeService.createRequest(request).subscribe({
      next: () => {
        alert("Demande envoyée avec succès");
        this.showRequestModal = false;
        this.resetForm();
      },
      error: (err) => alert("Erreur lors de l'envoi")
    });
  }

  // ================= PAIEMENT =================
  showPaymentModal = false;
  cardNumber = '';
  cardExpiry = '';
  cardCvv = '';
  cardHolder = '';
  isPaying = false;
  paymentSuccess = false;

  openPaymentModal() {
    this.cardNumber = '';
    this.cardExpiry = '';
    this.cardCvv = '';
    this.cardHolder = '';
    this.paymentSuccess = false;
    this.showPaymentModal = true;
  }

  payPremium() {
    const token = this.authService.getToken();
    if (!token || !this.data?.contrat?.id) return;

    this.isPaying = true;
    const payload = {
      cardNumber: this.cardNumber,
      cardExpiry: this.cardExpiry,
      cardCvv: this.cardCvv,
      cardHolder: this.cardHolder
    };

    this.contratService.payContrat(this.data.contrat.id, payload, token).subscribe({
      next: (updatedContrat: any) => {
        this.isPaying = false;
        this.paymentSuccess = true;
        this.data.contrat = updatedContrat;
      },
      error: (err: any) => {
        this.isPaying = false;
        alert("Erreur lors du paiement. Veuillez vérifier vos coordonnées bancaires.");
      }
    });
  }

  downloadReceipt() {
    const token = this.authService.getToken();
    if (!token || !this.data?.contrat?.id) return;

    this.contratService.downloadReceipt(this.data.contrat.id, token).subscribe({
      next: (blob: any) => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `recu_paiement_${this.data.contrat.numero}.pdf`;
        a.click();
      },
      error: (err: any) => alert("Erreur lors du téléchargement du reçu")
    });
  }

  resetForm() {
    this.requestDescription = '';
    this.modifiedValeur = null;
    this.modifiedPuissance = null;
    this.modifiedAge = null;
    this.modifiedMarque = '';
    this.modifiedModele = '';
    this.modifiedImmatriculation = '';
    this.modifiedFormule = '';
    this.modifiedValeurBien = null;
    this.modifiedNiveauSecurite = '';
  }

  // ================= HELPERS =================
  getRemainingDuration(): string {
    if (!this.data?.contrat?.dateFin) return '—';
    const now = new Date();
    const end = new Date(this.data.contrat.dateFin);
    if (end <= now) return 'Contrat expiré';
    const diffMs = end.getTime() - now.getTime();
    const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
    const months = Math.floor(diffDays / 30);
    const years = Math.floor(months / 12);
    const remMonths = months % 12;
    if (years > 0 && remMonths > 0) return `${years} an(s) et ${remMonths} mois`;
    if (years > 0) return `${years} an(s)`;
    if (months > 0) return `${months} mois`;
    return `${diffDays} jour(s)`;
  }

  getPaymentLabel(): string {
    const freq = this.data?.contrat?.frequencePaiement;
    const map: { [key: string]: string } = {
      'MENSUEL': 'Mensuel — chaque mois',
      'TRIMESTRIEL': 'Trimestriel — tous les 3 mois',
      'SEMESTRIEL': 'Semestriel — tous les 6 mois',
      'ANNUEL': 'Annuel — une fois par an'
    };
    return map[freq] || freq || '—';
  }

  ngOnInit(): void {
    const user = this.authService.getUser();
    if (user) {
      this.isUser = user.role === 'ROLE_USER' || user.role === 'USER';
      this.isGestionnaire = user.role === 'ROLE_GESTIONNAIRE' || user.role === 'GESTIONNAIRE';
    }

    const id = this.route.snapshot.paramMap.get('id');
    const token = this.authService.getToken();

    if (!id || !token) {
      console.error("ID ou token manquant");
      return;
    }

    this.contratService.getContratFull(id, token).subscribe({
      next: (res) => this.data = res,
      error: (err) => console.error(err)
    });
  }

  // ================= PDF =================
  downloadPdf(id: string) {
    if (!this.data?.contrat) return;

    // Ensure userEmail and userCin are included
    const contratData = {
      ...this.data.contrat,
      userEmail: this.data.userEmail || this.data.contrat.userEmail,
      userCin: this.data.userCin || this.data.contrat.userCin
    };

    // Show loading state
    this.isGeneratingPdf = true;

    this.pdfService.generateContratPDF(contratData)
      .then(() => {
        this.isGeneratingPdf = false;
      })
      .catch(err => {
        this.isGeneratingPdf = false;
        console.error('Error downloading PDF:', err);
        alert('Erreur lors de la génération du PDF');
      });
  }
}