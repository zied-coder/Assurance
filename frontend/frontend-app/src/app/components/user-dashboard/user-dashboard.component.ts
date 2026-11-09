import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';
import { ContratService } from '../../services/contrat.service';
import { SinistreService } from '../../services/sinistre.service';
import { DemandeServiceService } from '../../services/demande-service.service';
import { Router, RouterModule } from '@angular/router';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-user-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, TranslatePipe],
  templateUrl: './user-dashboard.component.html'
})
export class UserDashboardComponent implements OnInit {

  contratCount: number = 0;
  sinistreCount: number = 0;
  demandeCount: number = 0;

  constructor(
    private auth: AuthService, 
    private router: Router,
    private contratService: ContratService,
    private sinistreService: SinistreService,
    private demandeService: DemandeServiceService
  ) {}

  ngOnInit(): void {
    const token = this.auth.getToken();
    const user = this.auth.getUser();
    if (token && user) {
      this.contratService.getMyContrats(token).subscribe((res: any[]) => this.contratCount = res.length);
      this.sinistreService.getUserSinistres(token).subscribe((res: any[]) => this.sinistreCount = res.length);
      this.demandeService.getUserRequests(user.id).subscribe((res: any[]) => this.demandeCount = res.length);
    }
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/login/user']);
  }
}