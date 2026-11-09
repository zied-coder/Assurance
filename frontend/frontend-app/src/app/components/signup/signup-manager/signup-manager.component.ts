import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { TranslationService } from '../../../services/translation.service';
import { TranslatePipe } from '../../../pipes/translate.pipe';

@Component({
  selector: 'app-signup-manager',
  standalone: true,
  imports: [CommonModule, FormsModule, TranslatePipe],
  templateUrl: './signup-manager.component.html',
  styleUrls: ['./signup-manager.component.css']
})
export class SignupManagerComponent {

  username = '';
  email = '';
  password = '';

  // nouveaux champs
  cin = '';
  phone = '';
  address = '';

  errorMessage = '';

  constructor(
    private auth: AuthService,
    private router: Router,
    private translationService: TranslationService
  ) {}

  signup() {

    this.errorMessage = '';

    if (!this.username || !this.username.trim() ||
        !this.email || !this.email.trim() ||
        !this.password || !this.password.trim() ||
        !this.cin || !this.cin.trim() ||
        !this.phone || !this.phone.trim() ||
        !this.address || !this.address.trim()) {
      this.errorMessage = this.translationService.getInstant('signup.error_fields') || "Tous les champs sont obligatoires.";
      return;
    }

    const data = {
      username: this.username.trim(),
      email: this.email.trim(),
      password: this.password,

      // champs ajoutés
      cin: this.cin.trim(),
      phone: this.phone.trim(),
      address: this.address.trim(),

      role: 'ROLE_GESTIONNAIRE'
    };

    this.auth.register(data).subscribe({
      next: (res: any) => {

        console.log("SUCCESS:", res);

        alert(res.message || this.translationService.getInstant('signup.success_message'));
        this.router.navigate(['/login/manager']);
      },

      error: (err) => {

        console.log("ERROR:", err);

        this.errorMessage =
          err.error?.error ||
          err.error?.message ||
          this.translationService.getInstant('signup.error_api');
      }
    });
  }
}