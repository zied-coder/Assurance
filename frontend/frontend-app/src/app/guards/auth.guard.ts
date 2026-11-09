import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {

  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  canActivate(route: ActivatedRouteSnapshot): boolean {

    console.log("🔐 AuthGuard déclenché");

    const token = this.authService.getToken();
    const user = this.authService.getUser();

    console.log("TOKEN:", token);
    console.log("USER:", user);
    console.log("ROLES:", this.authService.getRoles());

    // ❌ sécurité renforcée
    if (!token || !user) {
      console.log("❌ Pas connecté → redirect login");
      this.router.navigate(['/login/user']);
      return false;
    }

    const allowedRoles: string[] = route.data['roles'] || [];
    const userRoles: string[] = this.authService.getRoles();

    console.log("👤 User roles:", userRoles);
    console.log("🎯 Allowed roles:", allowedRoles);

    // ✅ SI PAS DE ROLES → accès libre
    if (allowedRoles.length === 0) {
      console.log("✅ Route libre accès");
      return true;
    }

    // 🔐 check accès
    const hasAccess = allowedRoles.some(role =>
      userRoles.includes(role)
    );

    if (!hasAccess) {

      console.log("⛔ Accès refusé");

      if (userRoles.includes('ROLE_ADMIN')) {
        this.router.navigate(['/admin']);
      }
      else if (userRoles.includes('ROLE_GESTIONNAIRE')) {
        this.router.navigate(['/manager']);
      }
      else if (userRoles.includes('ROLE_USER')) {
        this.router.navigate(['/user']);
      }
      else {
        this.router.navigate(['/login/user']);
      }

      return false;
    }

    console.log("✅ Accès autorisé");
    return true;
  }
}