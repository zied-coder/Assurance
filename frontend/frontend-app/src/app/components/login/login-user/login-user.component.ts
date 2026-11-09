import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { TranslationService } from '../../../services/translation.service';
import { TranslatePipe } from '../../../pipes/translate.pipe';

@Component({
  selector: 'app-login-user',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, TranslatePipe],
  templateUrl: './login-user.component.html',
  styleUrls: ['./login-user.component.css']
})
export class LoginUserComponent {

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

            console.log("USER PROFILE:", user);

            this.auth.setUser(user);

// Force synchro
setTimeout(() => {
  this.router.navigate(['/user']); 
}, 50);

            // USER SEULEMENT
            if (user.roles?.some((r: any) => r.name === 'ROLE_USER')) {

              this.router.navigate(['/user']);

            } else {

              // REFUSER ADMIN + MANAGER
              this.errorMessage = '❌ ' + this.translationService.getInstant('login.error_role_user');
              this.auth.logout(); 

            }

          },
          error: () => {
            this.errorMessage = '❌ ' + this.translationService.getInstant('login.error_profile');
          }
        });

      },
      error: () => {
        this.errorMessage = '❌ ' + this.translationService.getInstant('login.error_credentials');
      }
    });
  }

  goToSignup() {
    this.router.navigate(['/signup/user']);
  }
}