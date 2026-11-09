import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private API_URL = "http://localhost:8082/api/";

  // 🔥 état isolé par onglet
  private userSubject = new BehaviorSubject<any>(null);
  user$ = this.userSubject.asObservable();

  constructor(private http: HttpClient) {
    // 🔥 recharge user au démarrage de l’onglet
    this.userSubject.next(this.getUser());
  }

  // ================= AUTH =================
  login(data: any) {
    return this.http.post<any>(this.API_URL + "auth/login", data);
  }

  register(data: any) {
    return this.http.post<any>(this.API_URL + "auth/signup", data);
  }

  // ================= TOKEN =================
  saveToken(token: string) {
    sessionStorage.setItem("token", token);
  }

  getToken(): string {
    return sessionStorage.getItem("token") || '';
  }

  // ================= USER =================
  setUser(user: any) {
    sessionStorage.setItem("user", JSON.stringify(user));
    this.userSubject.next(user);
  }

  getUser(): any {
    const userStr = sessionStorage.getItem("user");
    return userStr ? JSON.parse(userStr) : null;
  }

  getCurrentUser() {
    return this.getUser();
  }

  // ================= ROLES =================
  getRoles(): string[] {
    const user = this.getUser();
    if (!user || !user.roles) return [];
    return user.roles.map((r: any) => r.name);
  }

  // ================= PROFILE =================
  getProfile() {
    const token = this.getToken();
    return this.http.get<any>(this.API_URL + "users/profile", {
      headers: { Authorization: "Bearer " + token }
    });
  }

  updateProfile(data: any) {
    const token = this.getToken();
    return this.http.put<any>(
      this.API_URL + "users/" + data.id,
      data,
      {
        headers: { Authorization: "Bearer " + token }
      }
    );
  }

  // ================= LOGOUT =================
  logout() {
    sessionStorage.clear();
    this.userSubject.next(null);
  }
}