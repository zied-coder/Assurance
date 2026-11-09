import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ReclamationService, Reclamation } from '../../services/reclamation.service';
import { SinistreService } from '../../services/sinistre.service';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-reclamations',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './reclamations.component.html'
})
export class ReclamationsComponent implements OnInit {

  reclamations: Reclamation[] = [];
  selectedReclamation: Reclamation | null = null;
  linkedSinistre: any = null;

  showForm = false;
  newRec: Partial<Reclamation> = {
    titre: '',
    description: '',
    type: 'DELAY',
    sinistreId: ''
  };

  userSinistres: any[] = [];
  
  isUser = false;
  isGestionnaire = false;
  token = '';

  constructor(
    private recService: ReclamationService,
    private sinistreService: SinistreService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    const user = this.authService.getUser();
    this.token = this.authService.getToken() || '';
    if (!user) return;

    this.isUser = user.roles.some((r: any) => r.name === 'ROLE_USER');
    this.isGestionnaire = user.roles.some((r: any) => r.name === 'ROLE_GESTIONNAIRE');

    this.loadReclamations();
    if (this.isUser) {
      this.loadUserSinistres();
    }
  }

  loadReclamations() {
    const obs = this.isUser 
      ? this.recService.getUserReclamations(this.token)
      : this.recService.getAllReclamations(this.token);
    
    obs.subscribe({
      next: (data) => this.reclamations = data,
      error: (err) => console.error(err)
    });
  }

  loadUserSinistres() {
    this.sinistreService.getUserSinistres(this.token).subscribe({
      next: (data) => this.userSinistres = data,
      error: (err) => console.error(err)
    });
  }

  createReclamation() {
    if (!this.newRec.titre || !this.newRec.description || !this.newRec.sinistreId) {
      alert("Veuillez remplir tous les champs obligatoires.");
      return;
    }

    this.recService.createReclamation(this.newRec, this.token).subscribe({
      next: () => {
        alert("✅ Réclamation soumise avec succès.");
        this.showForm = false;
        this.newRec = { titre: '', description: '', type: 'DELAY', sinistreId: '' };
        this.loadReclamations();
      },
      error: (err) => alert("❌ Erreur lors de la création.")
    });
  }

  viewDetails(r: Reclamation) {
    this.selectedReclamation = r;
    this.linkedSinistre = null;
    if (r.sinistreId) {
      this.sinistreService.getSinistreById(r.sinistreId, this.token).subscribe(s => this.linkedSinistre = s);
    }
  }

  // ================= MANAGER ACTIONS =================

  updateStatus(statut: string) {
    if (!this.selectedReclamation) return;
    
    let reponse = '';
    if (statut === 'RESOLVED' || statut === 'REJECTED' || statut === 'IN_PROGRESS') {
      const promptMsg = statut === 'REJECTED' ? "Motif du rejet :" : "Commentaire / Solution :";
      const res = prompt(promptMsg);
      if (res === null) return;
      reponse = res;
    }

    this.recService.updateStatus(this.selectedReclamation.id!, statut, this.token, reponse).subscribe({
      next: (updated) => {
        alert("Statut mis à jour : " + statut);
        this.selectedReclamation = updated;
        this.loadReclamations();
      },
      error: (err) => alert("Erreur lors de la mise à jour.")
    });
  }

  deleteRec(id: string) {
    if (confirm("Supprimer cette réclamation ?")) {
      this.recService.deleteReclamation(id, this.token).subscribe(() => {
        this.loadReclamations();
        this.selectedReclamation = null;
      });
    }
  }
  reclamationsParStatut(statuts: string[]): Reclamation[] {
    return this.reclamations.filter(r => r.statut && statuts.includes(r.statut));
  }

  reclamationsNonResolues(): Reclamation[] {
    return this.reclamations.filter(r => r.statut && r.statut !== 'RESOLVED' && r.statut !== 'REJECTED');
  }
  getUnprocessedSinistres() {
    return this.userSinistres.filter(s => 
      s.statut !== 'SETTLED' && s.statut !== 'REJECTED' && s.statut !== 'APPROVED'
    );
  }
}