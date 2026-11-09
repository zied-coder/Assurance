import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SinistreService {

  private baseUrl = 'http://localhost:8082/api/sinistres';

  constructor(private http: HttpClient) {}

  // ================= HEADERS (JSON ONLY) =================
  private jsonHeaders(token: string) {
    return {
      headers: new HttpHeaders({
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json'
      })
    };
  }

  // ================= HEADERS (MULTIPART SAFE) =================
  private authHeaders(token: string) {
    return {
      headers: new HttpHeaders({
        Authorization: `Bearer ${token}`
      })
    };
  }

  // ================= GET =================
  getUserSinistres(token: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/user`, this.authHeaders(token));
  }

  getAllSinistres(token: string): Observable<any[]> {
    return this.http.get<any[]>(this.baseUrl, this.authHeaders(token));
  }

  getSinistreById(id: string, token: string): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/${id}`, this.authHeaders(token));
  }

  // ================= CREATE (UPLOAD FIXED) =================
  createSinistreWithFile(formData: FormData, token: string) {
    return this.http.post(
      `${this.baseUrl}/upload`,
      formData,
      this.authHeaders(token)
    );
  }

  // ================= WORKFLOW ACTIONS =================
  
  updateStatus(id: string, statut: string, token: string, commentaire: string = ''): Observable<any> {
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    return this.http.put(`${this.baseUrl}/${id}/status`, null, { 
      headers,
      params: { statut, commentaire }
    });
  }

  demanderInfo(id: string, commentaire: string, token: string): Observable<any> {
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    return this.http.put(`${this.baseUrl}/${id}/demander-info`, null, {
      headers,
      params: { commentaire }
    });
  }

  assignExpert(id: string, expertNom: string, expertTelephone: string, expertRendezVous: string, token: string): Observable<any> {
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    return this.http.put(`${this.baseUrl}/${id}/assigner-expert`, null, {
      headers,
      params: { expertNom, expertTelephone, expertRendezVous }
    });
  }

  submitExpertReport(id: string, rapportExpert: string, token: string): Observable<any> {
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    return this.http.put(`${this.baseUrl}/${id}/rapport-expert`, null, {
      headers,
      params: { rapportExpert }
    });
  }

  finalDecision(id: string, statut: string, commentaire: string, token: string): Observable<any> {
    const headers = new HttpHeaders().set('Authorization', `Bearer ${token}`);
    return this.http.put(`${this.baseUrl}/${id}/decision-finale`, null, {
      headers,
      params: { statut, commentaire }
    });
  }

  // ================= USER ACTIONS =================

  completerSinistre(id: string, formData: FormData, token: string): Observable<any> {
    return this.http.put(
      `${this.baseUrl}/completer/${id}`,
      formData,
      this.authHeaders(token)
    );
  }

  // ================= DELETE =================
  deleteSinistre(id: string, token: string): Observable<any> {
    return this.http.delete(
      `${this.baseUrl}/${id}`,
      this.authHeaders(token)
    );
  }

  // ================= CONFIG =================
  getMapKey(token: string): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/config/map-key`, this.authHeaders(token));
  }
}