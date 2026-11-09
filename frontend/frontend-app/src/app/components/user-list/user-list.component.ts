import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { UserService } from '../../services/user.service';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-user-list',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './user-list.component.html'
})
export class UserListComponent implements OnInit {

  users: any[] = [];
  isAdmin = false;
  selectedUser: any = {};
  showEditForm = false;
  showCreateForm = false;

  newManager: any = {
    username: '',
    email: '',
    password: 'manager123',
    role: 'ROLE_GESTIONNAIRE',
    cin: '',
    address: ''
  };

  constructor(
    private userService: UserService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.loadUsers();
    this.checkRole();
  }

  checkRole() {
    const roles = this.authService.getRoles();
    this.isAdmin = roles.includes('ROLE_ADMIN');
  }

  loadUsers() {
    this.userService.getUsers().subscribe({
      next: (res: any) => {
        this.users = res;
      },
      error: (err) => {
        console.error(err);
      }
    });
  }

  deleteUser(id: string) {
    if (!confirm("Supprimer cet utilisateur ?")) return;
    this.userService.deleteUser(id).subscribe({
      next: () => {
        this.users = this.users.filter(u => u.id !== id);
      },
      error: (err) => {
        console.error(err);
      }
    });
  }

  editUser(user: any) {
    this.selectedUser = { ...user };
    this.showEditForm = true;
    this.showCreateForm = false;
  }

  updateUser() {
    this.userService.updateUser(this.selectedUser.id, this.selectedUser)
      .subscribe({
        next: () => {
          alert("Gestionnaire mis à jour !");
          this.showEditForm = false;
          this.loadUsers();
        },
        error: (err) => {
          console.error(err);
        }
      });
  }

  createManager() {
    if (!this.newManager.username || !this.newManager.email || !this.newManager.cin || !this.newManager.address) {
      alert("Veuillez remplir Nom, Email, CIN et Adresse");
      return;
    }

    this.authService.register(this.newManager).subscribe({
      next: () => {
        alert("Gestionnaire créé !");
        this.showCreateForm = false;
        this.loadUsers();
        this.newManager = { username: '', email: '', password: 'manager123', role: 'ROLE_GESTIONNAIRE', cin: '', address: '' };
      },
      error: (err) => {
        alert("Erreur: " + (err.error?.error || err.error?.message || "Vérifiez les données"));
      }
    });
  }
}
