import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

import { ContratService } from '../../services/contrat.service';
import { AuthService } from '../../services/auth.service';
import { DemandeServiceService } from '../../services/demande-service.service';
import { PdfService } from '../../services/pdf.service';

@Component({
  selector: 'app-mes-contrats',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './mes-contrats.component.html'
})
export class MesContratsComponent implements OnInit {

  contrats: any[] = [];
  users: any[] = [];

  showForm = false;
  showContrats = false;
  searchNumeroContrat: string = '';

  contratEnEdition: any = null;
  formContrat: any = {};
  selectedContrat: any = null;

  isUser = false;
  isGestionnaire = false;
  isAdmin = false;
  isGeneratingPdf = false;

  constructor(
    private contratService: ContratService,
    private authService: AuthService,
    private demandeService: DemandeServiceService,
    private pdfService: PdfService
  ) {}

  showRequestModal = false;
  requestType = '';
  requestDescription = '';

  // Fields for modification
  modData: any = {
    // Auto
    valeurVehicule: 0,
    puissanceFiscale: 0,
    ageVehicule: 0,
    marque: '',
    modele: '',

    // Habitation
    valeurBien: 0,
    ageBatiment: 0,
    niveauSecurite: '',
    zoneGeo: '',

    // Sante / Vie
    ageAssure: 0,
    antecedentsMedicaux: '',
    profession: '',
    etatSante: '',
    capitalAssure: 0
  };

  openRequestModal(type: string) {
    this.requestType = type;
    this.showRequestModal = true;
    
    // Pre-fill with current data if modification
    if (type === 'MODIFICATION' && this.selectedContrat?.objets?.length) {
      const obj = this.selectedContrat.objets[0];
      this.modData = {
        valeurVehicule: obj.valeurVehicule || 0,
        puissanceFiscale: obj.puissanceFiscale || 0,
        ageVehicule: obj.ageVehicule || 0,
        marque: obj.marque || '',
        modele: obj.modele || '',
        
        valeurBien: obj.valeurBien || 0,
        ageBatiment: obj.ageBatiment || 0,
        niveauSecurite: obj.niveauSecurite || '',
        zoneGeo: obj.zoneGeo || '',
        
        ageAssure: obj.ageAssure || 0,
        antecedentsMedicaux: obj.antecedentsMedicaux || '',
        profession: obj.profession || '',
        etatSante: obj.etatSante || '',
        capitalAssure: obj.capitalAssure || 0
      };
    }
  }

  submitRequest() {
    const user = this.authService.getUser();
    if (!user || !this.selectedContrat) return;

    const request = {
      contratId: this.selectedContrat.id || this.selectedContrat._id,
      userId: user.id,
      type: this.requestType,
      description: this.requestDescription,
      updatePayload: this.requestType === 'MODIFICATION' ? JSON.stringify(this.modData) : null
    };

    this.demandeService.createRequest(request).subscribe({
      next: () => {
        alert("Demande envoyée avec succès");
        this.showRequestModal = false;
        this.requestDescription = '';
      },
      error: (err) => alert("Erreur lors de l'envoi")
    });
  }

  ngOnInit(): void {
    const user = this.authService.getUser();
    const token = this.authService.getToken();

    if (!user || !token) return;

    this.isUser = user.roles?.some((r: any) => r.name === 'ROLE_USER');
    this.isGestionnaire = user.roles?.some((r: any) => r.name === 'ROLE_GESTIONNAIRE');
    this.isAdmin = user.roles?.some((r: any) => r.name === 'ROLE_ADMIN');

    if (this.isGestionnaire) this.loadUsers();
    this.loadContrats();
  }

  // ================= LOAD CONTRATS =================
  loadContrats() {
    const token = this.authService.getToken();
    const user = this.authService.getUser();
    if (!token) return;

    if (this.isUser) {
      this.contratService.getMyContrats(token).subscribe({
        next: data => {
          // Add user email and CIN from authenticated user to each contract
          this.contrats = (data ?? []).map((c: any) => ({
            ...c,
            userEmail: user?.email || 'N/A',
            userCin: user?.cin || 'N/A'
          }));
        },
        error: err => console.error(err)
      });
    }

    if (this.isGestionnaire) {
      this.contratService.getAllContrats(token).subscribe({
        next: data => {
          this.contrats = (data ?? []).map((c: any) => {
            const user = this.users.find(u => u.id === c.userId);
            return {
              ...c,
              userEmail: user ? user.email : 'Inconnu',
              userCin: user ? user.cin : 'Inconnu'
            };
          });
        },
        error: err => console.error(err)
      });
    }
  }

  get filteredContrats() {
    if (!this.searchNumeroContrat || !this.searchNumeroContrat.trim()) {
      return this.contrats;
    }
    const query = this.searchNumeroContrat.trim().toLowerCase();
    return this.contrats.filter(c => c.numero?.toLowerCase().includes(query));
  }

  // ================= LOAD USERS =================
  loadUsers() {
    const token = this.authService.getToken();
    if (!token) return;

    this.contratService.getAllUsers(token).subscribe({
      next: data => this.users = data ?? [],
      error: err => console.error(err)
    });
  }

  getUserEmail(userId: string): string {
    const user = this.users.find(u => u.id === userId);
    return user ? user.email : 'Inconnu';
  }

  // ================= FULL CONTRACT =================
  viewContrat(c: any) {
    const token = this.authService.getToken();
    if (!token) return;

    this.contratService.getContratFull(c.id || c._id, token).subscribe({
      next: (data: any) => {
        this.selectedContrat = {
          ...data?.contrat,
          garanties: data?.garanties ?? [],
          objets: data?.objets ?? [],
          userEmail: data?.userEmail,
          userCin: data?.userCin
        };
      },
      error: err => {
        console.error(err);
        this.selectedContrat = c;
      }
    });
  }

  // ================= UI ACTIONS =================
  voirTousLesContrats() {
    this.showContrats = true;
    this.loadContrats();
  }

  ouvrirFormulaireAjouter() {
    this.showForm = true;
    this.contratEnEdition = null;
    this.formContrat = {};
  }

  annulerForm() {
    this.showForm = false;
    this.formContrat = {};
    this.contratEnEdition = null;
  }

  // ================= ADD CONTRAT =================
  addContrat() {
    const token = this.authService.getToken();
    if (!token) return;

    if (!this.formContrat.type || !this.formContrat.statut || !this.formContrat.userId) {
      alert("Remplir tous les champs !");
      return;
    }

    this.contratService.addContrat(this.formContrat, token).subscribe({
      next: res => {
        this.contrats = [...this.contrats, res];
        this.annulerForm();
      },
      error: err => console.error(err)
    });
  }

  // ================= EDIT =================
  editContrat(c: any) {
    this.contratEnEdition = c;
    this.formContrat = { ...c };
    this.showForm = true;
  }

 validerModification() {
  const token = this.authService.getToken();
  if (!token) return;

  const id = this.contratEnEdition?.id || this.contratEnEdition?._id;

  if (!id) {
    console.error("❌ ID introuvable");
    return;
  }

  this.contratService.updateContrat(
    id,
    this.formContrat,
    token
  ).subscribe({
    next: res => {
      const i = this.contrats.findIndex(x =>
        (x.id || x._id) === (res.id || res._id)
      );

      if (i !== -1) this.contrats[i] = res;

      this.annulerForm();
    },
    error: err => console.error(err)
  });
}

  // ================= DELETE (FIX FINAL IMPORTANT) =================
deleteContrat(c: any) {
  const token = this.authService.getToken();
  if (!token) return;

  const id = c?._id || c?.id;
  if (!id) return;

  this.contratService.deleteContrat(id, token).subscribe({
    next: () => {

      console.log("✅ supprimé");

      // 🔥 IMPORTANT : reload complet
      this.loadContrats();

      // fermer détails si ouvert
      this.selectedContrat = null;

    },
    error: err => console.error(err)
  });
}
  // ================= PDF =================
  downloadPdf(id: string) {
    // Find the contract in the list
    let contrat = this.contrats.find(c => (c.id || c._id) === id) || this.selectedContrat;
    if (!contrat) return;

    // Ensure userEmail and userCin are present
    const user = this.authService.getUser();
    if (!contrat.userEmail) {
      contrat = {
        ...contrat,
        userEmail: user?.email || 'N/A',
        userCin: user?.cin || 'N/A'
      };
    }

    // Show loading state
    this.isGeneratingPdf = true;

    // Use the new PDF service to generate a professional PDF
    this.pdfService.generateContratPDF(contrat)
      .then(() => {
        this.isGeneratingPdf = false;
      })
      .catch(err => {
        this.isGeneratingPdf = false;
        console.error('Error downloading PDF:', err);
        alert('Erreur lors de la génération du PDF');
      });
  }
  hasCancelledContrats(): boolean {
    return this.contrats.some(c => c.statut === 'RESILIE');
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
    if (!token || !this.selectedContrat?.id) return;

    this.isPaying = true;
    const payload = {
      cardNumber: this.cardNumber,
      cardExpiry: this.cardExpiry,
      cardCvv: this.cardCvv,
      cardHolder: this.cardHolder
    };

    this.contratService.payContrat(this.selectedContrat.id, payload, token).subscribe({
      next: (updatedContrat: any) => {
        this.isPaying = false;
        this.paymentSuccess = true;
        this.selectedContrat = {
          ...this.selectedContrat,
          ...updatedContrat
        };
        // Update in active contrats list
        const idx = this.contrats.findIndex(c => (c.id || c._id) === updatedContrat.id);
        if (idx !== -1) {
          this.contrats[idx] = {
            ...this.contrats[idx],
            ...updatedContrat
          };
        }
      },
      error: (err: any) => {
        this.isPaying = false;
        alert("Erreur lors du paiement. Veuillez vérifier vos coordonnées bancaires.");
      }
    });
  }

  downloadReceipt(id?: string) {
    const token = this.authService.getToken();
    if (!token) return;

    const contratId = id || this.selectedContrat?.id;
    if (!contratId) return;

    this.contratService.downloadReceipt(contratId, token).subscribe({
      next: (blob: any) => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        const ref = this.selectedContrat?.numero || contratId;
        a.download = `recu_paiement_${ref}.pdf`;
        a.click();
      },
      error: (err: any) => alert("Erreur lors du téléchargement du reçu")
    });
  }
}
