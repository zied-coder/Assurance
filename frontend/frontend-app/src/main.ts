import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter, Routes } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';

import { AppComponent } from './app/app.component';

// 🏦 HOME (NOUVEAU)
import { HomeComponent } from './app/pages/home/home.component';

// 🔹 Login
import { LoginUserComponent } from './app/components/login/login-user/login-user.component';
import { LoginManagerComponent } from './app/components/login/login-manager/login-manager.component';
import { LoginAdminComponent } from './app/components/login/login-admin/login-admin.component';

// 🔹 Signup
import { SignupUserComponent } from './app/components/signup/signup-user/signup-user.component';
import { SignupManagerComponent } from './app/components/signup/signup-manager/signup-manager.component';
import { SignupAdminComponent } from './app/components/signup/signup-admin/signup-admin.component';

// 🔹 Dashboards
import { AdminDashboardComponent } from './app/components/admin-dashboard/admin-dashboard.component';
import { ManagerDashboardComponent } from './app/components/manager-dashboard/manager-dashboard.component';
import { UserDashboardComponent } from './app/components/user-dashboard/user-dashboard.component';

// 🔹 Others
import { UserListComponent } from './app/components/user-list/user-list.component';
import { UserProfileComponent } from './app/components/user-profile/user-profile.component';
import { MesContratsComponent } from './app/components/mes-contrats/mes-contrats.component';
import { SinistresComponent } from './app/components/sinistres/sinistres.component';
import { ReclamationsComponent } from './app/components/reclamations/reclamations.component';
import { ContratDetailComponent } from './app/components/contrat-detail/contrat-detail.component';
import { CreateContratWizardComponent } from './app/components/create-contrat-wizard/create-contrat-wizard.component';
import { SimulationComponent } from './app/components/simulation/simulation.component';
import { DemandesServiceListComponent } from './app/components/demandes-service-list/demandes-service-list.component';

// 🔹 Guard
import { AuthGuard } from './app/guards/auth.guard';

const routes: Routes = [

  // 🏦 PAGE D'ACCUEIL (IMPORTANT)
  { path: '', component: HomeComponent },
 

  // LOGIN
  { path: 'login/user', component: LoginUserComponent },
  { path: 'login/manager', component: LoginManagerComponent },
  { path: 'login/admin', component: LoginAdminComponent },

  // SIGNUP
  { path: 'signup/user', component: SignupUserComponent },
  { path: 'signup/manager', component: SignupManagerComponent },
  { path: 'signup/admin', component: SignupAdminComponent },


  // DASHBOARDS
  {
    path: 'admin',
    component: AdminDashboardComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_ADMIN'] }
  },
  {
    path: 'manager',
    component: ManagerDashboardComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_GESTIONNAIRE'] }
  },
  {
    path: 'user',
    component: UserDashboardComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_USER'] }
  },

  // USERS
  {
    path: 'users',
    component: UserListComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_ADMIN'] }
  },

  // PROFILE / SERVICES
  {
    path: 'profile',
    component: UserProfileComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_USER'] }
  },
  {
    path: 'sinistres',
    component: SinistresComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_USER', 'ROLE_GESTIONNAIRE'] }
  },
  {
    path: 'reclamations',
    component: ReclamationsComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_USER', 'ROLE_GESTIONNAIRE'] }
  },

  // CONTRATS
  {
    path: 'mes-contrats',
    component: MesContratsComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_GESTIONNAIRE', 'ROLE_USER'] }
  },

  // DETAIL CONTRAT
  {
    path: 'contrat-detail',
    component: ContratDetailComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_USER', 'ROLE_GESTIONNAIRE'] }
  },

  // WIZARD CONTRAT
  {
    path: 'create-contrat',
    component: CreateContratWizardComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_GESTIONNAIRE'] }
  },
  {
    path: 'demandes-service',
    component: DemandesServiceListComponent,
    canActivate: [AuthGuard],
    data: { roles: ['ROLE_GESTIONNAIRE'] }
  },

  // 404
  { path: '**', redirectTo: '' }
];

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes),
    provideHttpClient()
  ]
});