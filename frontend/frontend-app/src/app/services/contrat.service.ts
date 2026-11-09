import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ContratService {

  private API_URL = "http://localhost:8082/api/contrats";
  private API_USERS = "http://localhost:8082/api/users";

  constructor(private http: HttpClient) {}

  // ================= HEADERS =================
  private getHeaders(token: string) {
    return {
      headers: new HttpHeaders({
        Authorization: `Bearer ${token}`
      })
    };
  }

  // ================= USER =================
  getMyContrats(token: string): Observable<any[]> {
    return this.http.get<any[]>(
      `${this.API_URL}/my`,
      this.getHeaders(token)
    );
  }

  // ================= GESTIONNAIRE =================
  getAllContrats(token: string): Observable<any[]> {
    return this.http.get<any[]>(
      this.API_URL,
      this.getHeaders(token)
    );
  }

  getContratById(id: string, token: string): Observable<any> {
    return this.http.get(
      `${this.API_URL}/${id}`,
      this.getHeaders(token)
    );
  }

  // ================= CREATE =================
  addContrat(contrat: any, token: string): Observable<any> {
    return this.http.post(
      `${this.API_URL}/create/${contrat.cin}`,
      contrat,
      this.getHeaders(token)
    );
  }

  // ================= UPDATE =================
  updateContrat(id: string, contrat: any, token: string): Observable<any> {
    return this.http.put(
      `${this.API_URL}/${id}`,
      contrat,
      this.getHeaders(token)
    );
  }

  // ================= DELETE (FIX FINAL) =================
  deleteContrat(id: string, token: string): Observable<any> {

    console.log("🗑 DELETE CALL =>", `${this.API_URL}/${id}`);

    if (!id) {
      console.error("❌ ID manquant pour suppression");
    }

    return this.http.delete(
      `${this.API_URL}/${id}`,
      this.getHeaders(token)
    );
  }

  // ================= USERS =================
  getAllUsers(token: string): Observable<any[]> {
    return this.http.get<any[]>(
      this.API_USERS,
      this.getHeaders(token)
    );
  }

  // ================= FULL CONTRACT =================
  getContratFull(id: string, token: string): Observable<any> {
    return this.http.get(
      `${this.API_URL}/full/${id}`,
      this.getHeaders(token)
    );
  }

  // ================= OBJET =================
  addObjet(id: string, obj: any, token: string): Observable<any> {
    return this.http.post(
      `${this.API_URL}/${id}/objet`,
      obj,
      this.getHeaders(token)
    );
  }

  // ================= PDF =================
  downloadPdf(id: string, token: string): Observable<Blob> {
    return this.http.get(
      `${this.API_URL}/pdf/${id}`,
      {
        headers: new HttpHeaders({
          Authorization: `Bearer ${token}`
        }),
        responseType: 'blob'
      }
    );
  }

  // ================= PAYMENT =================
  payContrat(id: string, payload: any, token: string): Observable<any> {
    return this.http.post(
      `${this.API_URL}/${id}/pay`,
      payload,
      this.getHeaders(token)
    );
  }

  // ================= RECEIPT =================
  downloadReceipt(id: string, token: string): Observable<Blob> {
    return this.http.get(
      `${this.API_URL}/${id}/receipt`,
      {
        headers: new HttpHeaders({
          Authorization: `Bearer ${token}`
        }),
        responseType: 'blob'
      }
    );
  }
}