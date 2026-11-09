import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DemandeServiceService } from '../../services/demande-service.service';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-demandes-service-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './demandes-service-list.component.html',
  styleUrls: ['./demandes-service-list.component.css']
})
export class DemandesServiceListComponent implements OnInit {

  demandes: any[] = [];
  feedback: string = '';

  constructor(private demandeService: DemandeServiceService) { }

  ngOnInit(): void {
    this.loadDemandes();
  }

  loadDemandes() {
    this.demandeService.getPendingRequests().subscribe({
      next: (res) => this.demandes = res,
      error: (err) => console.error(err)
    });
  }

  process(id: string, status: string) {
    this.demandeService.processRequest(id, status, this.feedback).subscribe({
      next: () => {
        alert("Demande traitée : " + status);
        this.loadDemandes();
        this.feedback = '';
      },
      error: (err) => alert("Erreur lors du traitement")
    });
  }

  parsePayload(payload: string) {
    if (!payload) return null;
    try {
      return JSON.parse(payload);
    } catch (e) {
      return null;
    }
  }
}
