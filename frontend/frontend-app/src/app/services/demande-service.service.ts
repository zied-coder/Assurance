import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DemandeServiceService {

  private apiUrl = 'http://localhost:8082/api/demandes-service';

  constructor(private http: HttpClient) { }

  private getHeaders(): HttpHeaders {
    const token = sessionStorage.getItem('token');
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  createRequest(request: any): Observable<any> {
    return this.http.post(this.apiUrl, request, { headers: this.getHeaders() });
  }

  getPendingRequests(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/pending`, { headers: this.getHeaders() });
  }

  getUserRequests(userId: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/user/${userId}`, { headers: this.getHeaders() });
  }

  processRequest(id: string, status: string, feedback: string): Observable<any> {
    return this.http.put(`${this.apiUrl}/${id}/process?status=${status}&feedback=${feedback}`, {}, { headers: this.getHeaders() });
  }
}
