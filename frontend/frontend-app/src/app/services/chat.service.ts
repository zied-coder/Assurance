import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ChatService {
  private apiUrl = 'http://localhost:8082/api/chatbot';

  constructor(private http: HttpClient) { }

  ask(message: string, sessionId: string): Observable<{ response: string }> {
    return this.http.post<{ response: string }>(`${this.apiUrl}/ask`, { message, sessionId });
  }
}
