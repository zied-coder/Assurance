import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { ContratService } from '../../services/contrat.service';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-create-contrat-wizard',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './create-contrat-wizard.component.html'
})
export class CreateContratWizardComponent {

  step = 1;
  contratId: string = '';
  details: any;

  types: string[] = ['AUTO', 'HABITATION', 'SANTE', 'VIE'];

  // ================= STEP 1 =================
  formStep1: any = {
    cin: '',
    type: '',
    formule: '',
    duree: '',
    frequencePaiement: ''
  };

  // ================= STEP 2 =================
  formStep2: any = {

    // AUTO
    registrationType: 'TU',
    immatriculationPart1: '',
    immatriculationPart2: '',
    immatriculation: '',
    marque: '',
    modele: '',
    ageVehicule: null,
    puissanceFiscale: null,
    puissanceMoteur: null,
    valeurVehicule: null,

    // HABITATION
    adresseBien: '',
    valeurBien: null,
    ageBatiment: null,
    niveauSecurite: '',
    zoneGeo: '',

    // SANTE / VIE
    ageAssure: null,
    antecedentsMedicaux: '',
    profession: '',
    etatSante: '',
    capitalAssure: null,
    specialitesMedicales: [],
    couvertureHospitaliere: false
  };

  constructor(
    private contratService: ContratService,
    private authService: AuthService
  ) {}

  // ================= STEP 1 =================
  createContrat() {

    console.log("DATA:", this.formStep1);

    if (
      !this.formStep1.cin?.trim() ||
      !this.formStep1.type?.trim() ||
      !this.formStep1.formule?.trim() ||
      !this.formStep1.duree ||
      !this.formStep1.frequencePaiement?.trim()
    ) {
      alert("⚠️ Remplir tous les champs !");
      return;
    }

    const token = this.authService.getToken();

    this.contratService.addContrat(this.formStep1, token!)
      .subscribe({
        next: (res: any) => {
          this.contratId = res.id;
          this.step = 2;
        },
        error: (err) => {
          console.error(err);
          alert("❌ Erreur création contrat");
        }
      });
  }

  // ================= STEP 2 =================
  onRegistrationTypeChange() {
    this.formStep2.immatriculation = '';
    this.formStep2.immatriculationPart1 = '';
    this.formStep2.immatriculationPart2 = '';
  }

  toggleSpecialite(spec: string) {
    const index = this.formStep2.specialitesMedicales.indexOf(spec);
    if (index > -1) {
      this.formStep2.specialitesMedicales.splice(index, 1);
    } else {
      this.formStep2.specialitesMedicales.push(spec);
    }
  }

  get finalImmatriculation(): string {
    const type = this.formStep2.registrationType;
    if (type === 'TU') {
      if (this.formStep2.immatriculationPart1 && this.formStep2.immatriculationPart2) {
        return `${this.formStep2.immatriculationPart1} TUNES ${this.formStep2.immatriculationPart2}`;
      }
    } else if (type === 'ETAT') {
      if (this.formStep2.immatriculationPart1 && this.formStep2.immatriculationPart2) {
        return `${this.formStep2.immatriculationPart1} ETAT ${this.formStep2.immatriculationPart2}`;
      }
    } else if (type === 'RS' || type === 'FSR') {
      if (this.formStep2.immatriculation) {
        return `${type} ${this.formStep2.immatriculation}`;
      }
    }
    return '';
  }

  addObjet() {

    const token = this.authService.getToken();
    const type = this.formStep1.type;

    let objet: any;

    // 🚗 AUTO (FULL BACKEND MATCH)
    if (type === 'AUTO') {

      const finalImm = this.finalImmatriculation;

      if (
        !this.formStep2.marque ||
        !this.formStep2.modele ||
        !finalImm ||
        this.formStep2.ageVehicule == null ||
        this.formStep2.puissanceFiscale == null ||
        this.formStep2.puissanceMoteur == null ||
        this.formStep2.valeurVehicule == null
      ) {
        alert("⚠️ Remplir toutes les infos véhicule et la plaque d'immatriculation complète !");
        return;
      }

      const regType = this.formStep2.registrationType;
      if (regType === 'TU') {
        if (!/^\d{3}$/.test(this.formStep2.immatriculationPart1) || !/^\d{4}$/.test(this.formStep2.immatriculationPart2)) {
          alert("⚠️ Format invalide : l'immatriculation TU doit être '3 chiffres' TUNES '4 chiffres'.");
          return;
        }
      } else if (regType === 'ETAT') {
        if (!/^\d{2}$/.test(this.formStep2.immatriculationPart1) || !/^\d{6}$/.test(this.formStep2.immatriculationPart2)) {
          alert("⚠️ Format invalide : l'immatriculation ETAT doit être '2 chiffres' ETAT '6 chiffres'.");
          return;
        }
      } else if (regType === 'RS' || regType === 'FSR') {
        if (!/^\d{6}$/.test(this.formStep2.immatriculation)) {
          alert(`⚠️ Format invalide : l'immatriculation ${regType} doit contenir exactement 6 chiffres.`);
          return;
        }
      }

      objet = {
        type: "AUTO",
        registrationType: this.formStep2.registrationType,
        marque: this.formStep2.marque,
        modele: this.formStep2.modele,
        immatriculation: finalImm,
        ageVehicule: this.formStep2.ageVehicule,
        puissanceFiscale: this.formStep2.puissanceFiscale,
        puissanceMoteur: this.formStep2.puissanceMoteur,
        valeurVehicule: this.formStep2.valeurVehicule
      };
    }

    // 🏠 HABITATION
    else if (type === 'HABITATION') {
      objet = {
        type: "HABITATION",
        adresseBien: this.formStep2.adresseBien,
        valeurBien: this.formStep2.valeurBien || 0,
        ageBatiment: this.formStep2.ageBatiment || 0,
        niveauSecurite: this.formStep2.niveauSecurite,
        zoneGeo: this.formStep2.zoneGeo
      };
    }

    // 🏥 SANTE / 👤 VIE
    else if (type === 'SANTE' || type === 'VIE') {
      objet = {
        type: type,
        ageAssure: this.formStep2.ageAssure || 0,
        antecedentsMedicaux: this.formStep2.antecedentsMedicaux,
        profession: this.formStep2.profession,
        etatSante: this.formStep2.etatSante,
        capitalAssure: this.formStep2.capitalAssure || 0,
        specialitesMedicales: this.formStep2.specialitesMedicales,
        couvertureHospitaliere: this.formStep2.couvertureHospitaliere
      };
    }

    this.contratService.addObjet(this.contratId, objet, token!)
      .subscribe({
        next: () => {
          this.loadDetails();
          this.step = 3;
        },
        error: (err) => {
          console.error(err);
          alert("❌ Erreur ajout objet");
        }
      });
  }

  // ================= SKIP (SANTE / VIE) =================
  skipObjet() {

    const token = this.authService.getToken();

    this.contratService.getContratFull(this.contratId, token!)
      .subscribe({
        next: (res) => {
          this.details = res;
          this.step = 3;
        },
        error: (err) => {
          console.error(err);
          alert("❌ Erreur chargement détails");
        }
      });
  }

  // ================= STEP 3 =================
  loadDetails() {

    const token = this.authService.getToken();

    this.contratService.getContratFull(this.contratId, token!)
      .subscribe({
        next: (res) => this.details = res,
        error: (err) => {
          console.error(err);
          alert("❌ Erreur chargement détails");
        }
      });
  }
}