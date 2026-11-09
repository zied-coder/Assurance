import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Reclamation {
  id?: string;
  userId?: string;
  userEmail?: string;
  userCin?: string;
  titre?: string;
  description?: string;
  type?: string; // DELAY, DISPUTE, PAYMENT_ISSUE, OTHER
  statut?: string; // SUBMITTED, UNDER_REVIEW, IN_PROGRESS, RESOLVED, REJECTED
  reponse?: string;
  dateCreation?: string;
  dateUpdate?: string;
  sinistreId?: string;
  sinistreNumero?: string;
  document?: string;
}

@Injectable({
  providedIn: 'root'
})
export class ReclamationService {

  private apiUrl = 'http://localhost:8082/api/reclamations';

  constructor(private http: HttpClient) {}

  private getHeaders(token: string) {
    return new HttpHeaders().set('Authorization', `Bearer ${token}`);
  }

  // ================= CLIENT =================

  createReclamation(reclamation: Partial<Reclamation>, token: string): Observable<Reclamation> {
    return this.http.post<Reclamation>(this.apiUrl, reclamation, { headers: this.getHeaders(token) });
  }

  getUserReclamations(token: string): Observable<Reclamation[]> {
    return this.http.get<Reclamation[]>(`${this.apiUrl}/user`, { headers: this.getHeaders(token) });
  }

  // ================= GESTIONNAIRE =================

  getAllReclamations(token: string): Observable<Reclamation[]> {
    return this.http.get<Reclamation[]>(this.apiUrl, { headers: this.getHeaders(token) });
  }

  getReclamationById(id: string, token: string): Observable<Reclamation> {
    return this.http.get<Reclamation>(`${this.apiUrl}/${id}`, { headers: this.getHeaders(token) });
  }

  updateStatus(id: string, statut: string, token: string, reponse?: string): Observable<Reclamation> {
    let params = new HttpParams().set('statut', statut);
    if (reponse) {
      params = params.set('reponse', reponse);
    }
    return this.http.put<Reclamation>(`${this.apiUrl}/${id}/status`, null, { 
      headers: this.getHeaders(token),
      params: params
    });
  }

  deleteReclamation(id: string, token: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/${id}`, { headers: this.getHeaders(token) });
  }
}