import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './admin-dashboard.component.html',
  styleUrl: './admin-dashboard.component.css'
})
export class AdminDashboardComponent {
  currentDate: string = '';

  constructor(private auth: AuthService, private router: Router) { 
    this.currentDate = new Intl.DateTimeFormat('fr-FR', { 
      weekday: 'long', 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric' 
    }).format(new Date());
    // Capitalize first letter
    this.currentDate = this.currentDate.charAt(0).toUpperCase() + this.currentDate.slice(1);
  }

  logout() {
    this.auth.logout();
    this.router.navigate(['/login/admin']);
  }

}