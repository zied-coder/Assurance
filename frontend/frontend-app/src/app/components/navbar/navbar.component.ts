import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { TranslationService } from '../../services/translation.service';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule, TranslatePipe],
  templateUrl: './navbar.component.html'
})
export class NavbarComponent {
  isLangDropdownOpen = false;

  constructor(
    public authService: AuthService,
    private router: Router,
    public translationService: TranslationService
  ) {}

  isLoggedIn(): boolean {
    return !!this.authService.getToken() && !!this.authService.getUser();
  }

  // Hide on all public pages (home, login, signup, simulation)
  shouldHideNavbar(): boolean {
    const publicPaths = [
      '/',
      '',
      '/login/user',
      '/login/manager',
      '/login/admin',
      '/signup/user',
      '/signup/manager',
      '/signup/admin',
      '/simulation'
    ];
    return publicPaths.includes(this.router.url) || !this.isLoggedIn();
  }

  logout() {
    const roles = this.authService.getRoles();
    let redirectPath = '/login/user';

    if (roles.includes('ROLE_ADMIN')) {
      redirectPath = '/login/admin';
    } else if (roles.includes('ROLE_GESTIONNAIRE')) {
      redirectPath = '/login/manager';
    }

    this.authService.logout();
    this.router.navigate([redirectPath]);
  }

  getDashboardLink(): string {
    const roles = this.authService.getRoles();

    if (roles.includes('ROLE_ADMIN')) return '/admin';
    if (roles.includes('ROLE_GESTIONNAIRE')) return '/manager';
    if (roles.includes('ROLE_USER')) return '/user';

    return '/login/user';
  }

  toggleLangDropdown() {
    this.isLangDropdownOpen = !this.isLangDropdownOpen;
  }

  selectLanguage(lang: string) {
    this.translationService.setLanguage(lang);
    this.isLangDropdownOpen = false;
  }

  getLanguageLabel(lang: string): string {
    if (lang === 'fr') return 'FR';
    if (lang === 'en') return 'EN';
    if (lang === 'ar') return 'AR';
    return 'FR';
  }
}