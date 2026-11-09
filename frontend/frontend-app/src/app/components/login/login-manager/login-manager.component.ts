import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { TranslationService } from '../../../services/translation.service';
import { TranslatePipe } from '../../../pipes/translate.pipe';

@Component({
  selector: 'app-login-manager',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, TranslatePipe],
  templateUrl: './login-manager.component.html',
  styleUrls: ['./login-manager.component.css']
})
export class LoginManagerComponent {

  username = '';
  password = '';
  errorMessage = '';

  constructor(
    private auth: AuthService,
    private router: Router,
    private translationService: TranslationService
  ) {}

  login() {

    const data = {
      username: this.username,
      password: this.password
    };

    this.errorMessage = '';

    this.auth.login(data).subscribe({

      next: (res: any) => {

        // sauvegarder token
        this.auth.saveToken(res.token);

        // récupérer profil
        this.auth.getProfile().subscribe({

          next: (user: any) => {

            console.log("USER PROFILE:", user);

            const isManager = user.roles?.some(
              (r: any) => r.name === 'ROLE_GESTIONNAIRE'
            );

            // BLOQUER si pas gestionnaire
            if (!isManager) {
              this.errorMessage = '❌ ' + this.translationService.getInstant('login.error_role_manager');
              this.auth.logout(); 
              return;
            }

            // OK → enregistrer user
            this.auth.setUser(user);

            // redirection
            this.router.navigate(['/manager']);
          },

          error: () => {
            this.errorMessage = '❌ ' + this.translationService.getInstant('login.error_profile');
            this.auth.logout();
          }

        });

      },

      error: () => {
        this.errorMessage = '❌ ' + this.translationService.getInstant('login.error_credentials');
      }

    });

  }
}