import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { TranslationService } from '../../../services/translation.service';
import { TranslatePipe } from '../../../pipes/translate.pipe';

@Component({
  selector: 'app-login-admin',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, TranslatePipe],
  templateUrl: './login-admin.component.html',
  styleUrls: ['./login-admin.component.css']
})
export class LoginAdminComponent {

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

    this.auth.login(data).subscribe({
      next: (res: any) => {

        this.auth.saveToken(res.token);

        this.auth.getProfile().subscribe({
          next: (user: any) => {

            console.log("USER PROFILE:", user); // DEBUG IMPORTANT

            this.auth.setUser(user);

            // CORRECTION PRINCIPALE ICI
            if (user.roles?.some((r: any) => r.name === 'ROLE_ADMIN')) {

              this.router.navigate(['/admin']);

            } else {

              this.errorMessage = this.translationService.getInstant('login.error_role_admin');

            }

          },
          error: () => {
            this.errorMessage = this.translationService.getInstant('login.error_profile');
          }
        });

      },
      error: () => {
        this.errorMessage = this.translationService.getInstant('login.error_credentials');
      }
    });

  }
}