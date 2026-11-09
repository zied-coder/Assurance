import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-user-profile',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './user-profile.component.html',
})
export class UserProfileComponent implements OnInit {

  user: any = {};

  oldPassword = '';
  newPassword = '';
  confirmPassword = '';
  passwordError = '';
  profileError = '';

  constructor(private auth: AuthService) {}

  ngOnInit() {
    this.loadProfile();
  }

  // 🔄 charger profil
  loadProfile(){
    this.auth.getProfile().subscribe({
      next: (data) => {
        console.log("USER DATA =", data);
        this.user = data;
      },
      error: () => {
        alert("❌ Erreur chargement profil");
      }
    });
  }

  // ✏️ modifier profil
  updateProfile() {
    this.passwordError = '';
    this.profileError = '';

    // ✅ Guard: at least one profile field must be filled
    const usernameEmpty = !this.user.username || !this.user.username.trim();
    const emailEmpty    = !this.user.email    || !this.user.email.trim();
    const phoneEmpty    = !this.user.phone    || !this.user.phone.trim();
    const cinEmpty      = !this.user.cin      || !this.user.cin.trim();

    if (usernameEmpty && emailEmpty && phoneEmpty && cinEmpty) {
      this.profileError = "Au moins un champ doit être renseigné pour mettre à jour le profil.";
      return;
    }

    // Si l'utilisateur essaie de changer le mot de passe
    if (this.newPassword || this.oldPassword || this.confirmPassword) {
      if (!this.oldPassword) {
        this.passwordError = 'Veuillez saisir votre mot de passe actuel pour des raisons de sécurité.';
        return;
      }
      if (this.newPassword !== this.confirmPassword) {
        this.passwordError = 'Les nouveaux mots de passe ne correspondent pas.';
        return;
      }
      if (this.newPassword.length < 6) {
        this.passwordError = 'Le nouveau mot de passe doit contenir au moins 6 caractères.';
        return;
      }

      this.user.oldPassword = this.oldPassword;
      this.user.password = this.newPassword;
    } else {
      // Nettoyer les champs de mot de passe si on ne veut pas les changer
      delete this.user.oldPassword;
      delete this.user.password;
    }

    this.auth.updateProfile(this.user).subscribe({
      next: () => {
        alert("✅ Profil modifié avec succès");

        this.oldPassword = '';
        this.newPassword = '';
        this.confirmPassword = '';
        this.passwordError = '';
        this.profileError = '';

        // recharge les données sans logout
        this.loadProfile();
      },
      error: (err) => {
        console.error(err);
        const msg = err.error?.message || err.error?.error;
        if (msg) {
          this.profileError = msg;
        } else if (err.status === 400 || err.status === 403 || err.status === 401) {
          this.passwordError = "Mot de passe actuel incorrect ou données invalides.";
        } else {
          alert("❌ Erreur lors de la modification du profil");
        }
      }
    });
  }
}