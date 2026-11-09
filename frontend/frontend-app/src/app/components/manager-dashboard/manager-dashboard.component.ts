import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';
import { ContratService } from '../../services/contrat.service';
import { SinistreService } from '../../services/sinistre.service';
import { ReclamationService } from '../../services/reclamation.service';
import { Router, RouterModule } from '@angular/router';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-manager-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, TranslatePipe],
  templateUrl: './manager-dashboard.component.html'
})
export class ManagerDashboardComponent implements OnInit {

  contratCount: number = 0;
  sinistreCount: number = 0;
  reclamationCount: number = 0;

  constructor(
    private auth: AuthService, 
    private router: Router,
    private contratService: ContratService,
    private sinistreService: SinistreService,
    private reclamationService: ReclamationService
  ) {}

  ngOnInit(): void {
    const token = this.auth.getToken();
    if (token) {
      this.contratService.getAllContrats(token).subscribe(res => this.contratCount = res.length);
      this.sinistreService.getAllSinistres(token).subscribe(res => this.sinistreCount = res.length);
      this.reclamationService.getAllReclamations(token).subscribe(res => this.reclamationCount = res.length);
    }
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/login/manager']);
  }
}