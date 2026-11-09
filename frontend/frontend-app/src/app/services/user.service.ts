import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class UserService {

  private apiUrl = "http://localhost:8082/api/users";

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  // 🔐 Headers sécurisés
  private getHeaders() {
    const token = this.authService.getToken();

    if (!token) {
      console.error("❌ Token introuvable !");
    }

    return {
      headers: new HttpHeaders({
        Authorization: `Bearer ${token}`
      })
    };
  }

  // 👥 GET USERS
  getUsers() {
    return this.http.get<any[]>(this.apiUrl, this.getHeaders());
  }

  // ➕ CREATE USER
  createUser(data: any) {
    return this.http.post(this.apiUrl, data, this.getHeaders());
  }

  // 🗑 DELETE USER
  deleteUser(id: string) {
    return this.http.delete(
      `${this.apiUrl}/${id}`,
      {
        ...this.getHeaders(),
        responseType: 'text'
      }
    );
  }

  // ✏ UPDATE USER
  updateUser(id: string, data: any) {
    return this.http.put(
      `${this.apiUrl}/${id}`,
      data,
      this.getHeaders()
    );
  }
}