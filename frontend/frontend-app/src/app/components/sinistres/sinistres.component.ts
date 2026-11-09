import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SinistreService } from '../../services/sinistre.service';
import { AuthService } from '../../services/auth.service';
import { ContratService } from '../../services/contrat.service';

declare var google: any;

@Component({
  selector: 'app-sinistres',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './sinistres.component.html'
})
export class SinistresComponent implements OnInit {

  sinistres: any[] = [];

  showForm = false;
  sinistreEnEdition: any = null;
  selectedSinistre: any = null;
  selectedContrat: any = null;
  selectedFileUser: File | null = null;

  isUser = false;
  isGestionnaire = false;
  isAdmin = false;

  searchNumero: string = '';
  searchResult: any = undefined; // undefined = not searched, null = not found

  actionMode: 'CREATE' | 'EDIT' | 'COMPLETE' = 'CREATE';

  userContrats: any[] = [];
  googleMapsApiKey: string = '';
  isGeocoding = false; // 🔥 État de chargement
  todayString: string = '';

  constructor(
    private sinistreService: SinistreService,
    private authService: AuthService,
    private contratService: ContratService
  ) { }

  ngOnInit(): void {
    const user = this.authService.getUser();
    const token = this.authService.getToken();

    if (!user || !token) return;

    this.isUser = user.roles?.some((r: any) => r.name === 'ROLE_USER');
    this.isGestionnaire = user.roles?.some((r: any) => r.name === 'ROLE_GESTIONNAIRE');
    this.isAdmin = user.roles?.some((r: any) => r.name === 'ROLE_ADMIN');

    this.loadSinistres();
    this.loadUserContrats();
    this.loadMapKey();
    this.todayString = new Date().toISOString().split('T')[0];
  }

  // ================= LOAD =================
  loadSinistres() {
    const token = this.authService.getToken();
    if (!token) return;

    const obs = this.isUser
      ? this.sinistreService.getUserSinistres(token)
      : this.sinistreService.getAllSinistres(token);

    obs.subscribe({
      next: (data) => this.sinistres = data,
      error: (err) => console.error("LOAD ERROR:", err)
    });
  }

  loadUserContrats() {
    const token = this.authService.getToken();
    if (!token || !this.isUser) return;
    this.contratService.getMyContrats(token).subscribe(data => this.userContrats = data);
  }

  loadMapKey() {
    const token = this.authService.getToken();
    if (!token) return;
    this.sinistreService.getMapKey(token).subscribe(res => {
      this.googleMapsApiKey = res.key;
      this.loadGoogleMapsScript();
    });
  }

  loadGoogleMapsScript() {
    if (window.document.getElementById('google-maps-script')) return;
    const script = window.document.createElement('script');
    script.id = 'google-maps-script';
    script.src = `https://maps.googleapis.com/maps/api/js?key=${this.googleMapsApiKey}&libraries=places`;
    script.async = true;
    script.defer = true;
    window.document.head.appendChild(script);
  }

  detectLocation() {
    if (!navigator.geolocation) {
      alert("La géolocalisation n'est pas supportée par votre navigateur.");
      return;
    }

    this.isGeocoding = true;
    this.sinistreEnEdition.adresse = "📍 Détection de l'emplacement...";

    navigator.geolocation.getCurrentPosition((position) => {
      const lat = position.coords.latitude;
      const lng = position.coords.longitude;
      this.sinistreEnEdition.latitude = lat;
      this.sinistreEnEdition.longitude = lng;

      // Use Google Reverse Geocoding for a professional address
      if (typeof google !== 'undefined' && google.maps) {
        const geocoder = new google.maps.Geocoder();
        const latlng = { lat, lng };

        geocoder.geocode({ location: latlng }, (results: any, status: any) => {
          this.isGeocoding = false;
          if (status === "OK") {
            if (results && results.length > 0) {
              // Chercher une adresse plus "humaine" (Ville, Quartier)
              const cityResult = results.find((r: any) =>
                r.types.includes('locality') ||
                r.types.includes('administrative_area_level_2') ||
                r.types.includes('sublocality')
              );

              if (cityResult) {
                this.sinistreEnEdition.adresse = cityResult.formatted_address;
              } else {
                this.sinistreEnEdition.adresse = results[0].formatted_address;
              }
            } else {
              this.sinistreEnEdition.adresse = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
            }
          } else {
            this.sinistreEnEdition.adresse = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
            console.error("Geocoding failed: " + status);
          }
        });
      } else {
        this.isGeocoding = false;
        this.sinistreEnEdition.adresse = `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
        console.error("Google Maps API not loaded.");
      }
    }, (error) => {
      this.isGeocoding = false;
      this.sinistreEnEdition.adresse = "";
      console.error(error);
      alert("Impossible de récupérer votre position GPS.");
    });
  }


  // ================= OPEN FORM =================
  ouvrirFormulaireAjouter() {
    this.actionMode = 'CREATE';

    this.sinistreEnEdition = {
      titre: '',
      description: '',
      incidentDate: this.todayString,
      statut: 'EN_ATTENTE',
      commentaire: ''
    };

    this.selectedFileUser = null;
    this.showForm = true;
  }

  // ================= FILE =================
  onFileSelected(event: any) {
    this.selectedFileUser = event.target.files?.[0] ?? null;
  }

  // ================= CREATE =================
  addSinistre() {
    const token = this.authService.getToken();
    if (!token || !this.sinistreEnEdition) return;

    const formData = new FormData();

    formData.append('titre', this.sinistreEnEdition.titre || '');
    formData.append('description', this.sinistreEnEdition.description || '');
    formData.append('incidentDate', this.sinistreEnEdition.incidentDate || '');

    // ✅ structured address
    formData.append('adresse', this.sinistreEnEdition.adresse || '');
    formData.append('contratId', this.sinistreEnEdition.contratId || '');

    if (this.sinistreEnEdition.latitude) formData.append('latitude', this.sinistreEnEdition.latitude.toString());
    if (this.sinistreEnEdition.longitude) formData.append('longitude', this.sinistreEnEdition.longitude.toString());

    // CIN (si tu veux l’envoyer côté front)
    formData.append('userCin', this.sinistreEnEdition.userCin || '');

    if (this.selectedFileUser) {
      formData.append('file', this.selectedFileUser, this.selectedFileUser.name);
    }

    this.sinistreService.createSinistreWithFile(formData, token).subscribe({
      next: () => {
        alert("✅ Sinistre créé avec succès");
        this.loadSinistres();
        this.annulerForm();
      },
      error: (err) => {
        console.error(err);
        alert("❌ erreur création");
      }
    });
  }

  // ================= EDIT =================
  editSinistre(s: any) {
    this.actionMode = 'EDIT';

    this.sinistreEnEdition = {
      id: s.id,
      statut: s.statut,
      commentaire: s.commentaire || ''
    };

    this.showForm = true;
  }

  // ================= UPDATE =================
  validerModification() {
    const token = this.authService.getToken();
    if (!token) return;

    this.sinistreService.updateStatus(
      this.sinistreEnEdition.id,
      this.sinistreEnEdition.statut,
      token,
      this.sinistreEnEdition.commentaire
    ).subscribe({
      next: () => {
        this.loadSinistres();
        this.annulerForm();
      },
      error: (err: any) => console.error("UPDATE ERROR:", err)
    });
  }

  // ================= COMPLETE =================
  completeSinistre(s: any) {
    this.actionMode = 'COMPLETE';

    this.sinistreEnEdition = {
      id: s.id,
      titre: s.titre,
      description: s.description,
      incidentDate: s.incidentDate ? new Date(s.incidentDate).toISOString().split('T')[0] : ''
    };

    this.selectedFileUser = null;
    this.showForm = true;
  }

  validerCompletionUser() {
    const token = this.authService.getToken();
    if (!token || !this.sinistreEnEdition) return;

    const formData = new FormData();

    formData.append('titre', this.sinistreEnEdition.titre || '');
    formData.append('description', this.sinistreEnEdition.description || '');
    formData.append('incidentDate', this.sinistreEnEdition.incidentDate || '');

    if (this.selectedFileUser) {
      formData.append('file', this.selectedFileUser, this.selectedFileUser.name);
    }

    this.sinistreService.completerSinistre(
      this.sinistreEnEdition.id,
      formData,
      token
    ).subscribe({
      next: () => {
        this.loadSinistres();
        this.annulerForm();
      },
      error: (err) => console.error("COMPLETE ERROR:", err)
    });
  }

  // ================= MANAGER ACTIONS =================

  examiner(id: string) {
    const token = this.authService.getToken();
    if (!token) return;
    this.sinistreService.updateStatus(id, 'UNDER_REVIEW', token, 'Dossier en cours d\'examen initial.').subscribe({
      next: () => {
        alert("🔍 Dossier passé en cours d'examen");
        this.loadSinistres();
        this.selectedSinistre = null;
      }
    });
  }

  demanderPlusInfo(id: string) {
    const comm = prompt("Quelles informations supplémentaires sont nécessaires ?");
    if (!comm) return;
    const token = this.authService.getToken();
    if (!token) return;
    this.sinistreService.demanderInfo(id, comm, token).subscribe({
      next: () => {
        alert("📧 Demande d'infos envoyée à l'assuré");
        this.loadSinistres();
        this.selectedSinistre = null;
      }
    });
  }

  assignerExpert(id: string) {
    const nom = prompt("Nom de l'expert :");
    if (!nom) return;
    const tel = prompt("Téléphone de l'expert :");
    if (!tel) return;
    const rdv = prompt("Détails du rendez-vous (Date/Lieu) :");
    if (!rdv) return;

    const token = this.authService.getToken();
    if (!token) return;
    this.sinistreService.assignExpert(id, nom, tel, rdv, token).subscribe({
      next: () => {
        alert("🧑🔧 Expert assigné avec succès");
        this.loadSinistres();
        this.selectedSinistre = null;
      }
    });
  }

  soumettreRapport(id: string) {
    const rapport = prompt("Résumé du rapport d'expertise :");
    if (!rapport) return;
    const token = this.authService.getToken();
    if (!token) return;
    this.sinistreService.submitExpertReport(id, rapport, token).subscribe({
      next: () => {
        alert("📝 Rapport d'expertise soumis");
        this.loadSinistres();
        this.selectedSinistre = null;
      }
    });
  }

  rendreDecision(id: string, decision: 'APPROVED' | 'REJECTED' | 'SETTLED') {
    let defaultComm = "";
    if (decision === 'APPROVED') defaultComm = "Votre sinistre a été approuvé. Le processus de dédommagement est actuellement en cours.";
    if (decision === 'SETTLED') defaultComm = "Votre sinistre a été réglé. Le paiement a été effectué avec succès.";

    const comm = prompt("Commentaire de décision finale :", defaultComm);
    if (comm === null) return; // Annuler

    const token = this.authService.getToken();
    if (!token) return;
    this.sinistreService.finalDecision(id, decision, comm || defaultComm, token).subscribe({
      next: () => {
        alert("🏁 Décision enregistrée : " + decision);
        this.loadSinistres();
        this.selectedSinistre = null;
      }
    });
  }

  deleteSinistre(s: any) {
    const token = this.authService.getToken();
    if (!token) return;

    this.sinistreService.deleteSinistre(s.id, token)
      .subscribe({
        next: () => this.loadSinistres(),
        error: (err) => console.error(err)
      });
  }

  viewSinistre(s: any) {
    this.selectedSinistre = s;
    this.selectedContrat = null;

    if (s?.contratId) {
      const token = this.authService.getToken();
      if (!token) return;

      this.contratService.getMyContrats(token).subscribe((contrats: any[]) => {
        this.selectedContrat = contrats.find(c => c.numero === s.contratId);
      });
    }
  }

  // ================= SEARCH =================
  clearSearch() {
    this.searchNumero = '';
  }

  // ================= FILTERS =================
  sinistresParStatut(statuts: string[]) {
    let list = this.sinistres.filter(s => statuts.includes(s.statut));
    if (this.searchNumero && this.searchNumero.trim()) {
      const query = this.searchNumero.trim().toLowerCase();
      list = list.filter(s => s.numero?.toLowerCase().includes(query));
    }
    return list;
  }

  // ================= RESET =================
  annulerForm() {
    this.showForm = false;
    this.sinistreEnEdition = null;
    this.selectedFileUser = null;
    this.actionMode = 'CREATE';
  }

  // ================= DELAY HELPERS =================
  getDelayDays(incidentDate: any, declarationDate: any): number | null {
    if (!incidentDate || !declarationDate) return null;
    const start = new Date(incidentDate);
    const end = new Date(declarationDate);
    start.setHours(0,0,0,0);
    end.setHours(0,0,0,0);
    const diffTime = end.getTime() - start.getTime();
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    return diffDays >= 0 ? diffDays : null;
  }

  getDelayString(s: any): string {
    if (!s || !s.incidentDate || !s.declarationDate) return '';
    const days = this.getDelayDays(s.incidentDate, s.declarationDate);
    if (days === null) return '';
    if (days === 0) return "Déclaré le jour même";
    if (days === 1) return "Déclaré 1 jour après l'incident";
    return `Déclaré ${days} jours après l'incident`;
  }
}