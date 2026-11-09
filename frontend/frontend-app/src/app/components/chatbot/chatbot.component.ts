import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService } from '../../services/chat.service';

interface Message {
  text: string;
  sender: 'user' | 'bot';
  time: Date;
}

@Component({
  selector: 'app-chatbot',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './chatbot.component.html',
  styleUrl: './chatbot.component.css'
})
export class ChatbotComponent {
  isOpen = false;
  userInput = '';
  sessionId = Math.random().toString(36).substring(7);
  messages: Message[] = [
    { text: 'Bonjour, je suis l\'assistant intelligent de Assurances. Comment puis-je vous accompagner dans vos démarches aujourd\'hui ?', sender: 'bot', time: new Date() }
  ];
  isLoading = false;

  constructor(private chatService: ChatService) { }

  toggleChat() {
    this.isOpen = !this.isOpen;
  }

  sendMessage() {
    if (!this.userInput.trim()) return;

    const userMsg = this.userInput;
    this.messages.push({ text: userMsg, sender: 'user', time: new Date() });
    this.userInput = '';
    this.isLoading = true;

    // Simulate typing delay
    setTimeout(() => {
      this.chatService.ask(userMsg, this.sessionId).subscribe({
        next: (res) => {
          this.messages.push({ text: res.response, sender: 'bot', time: new Date() });
          this.isLoading = false;
          this.scrollToBottom();
        },
        error: (err) => {
          console.error('Chat API Error:', err);
          this.messages.push({ 
            text: 'Je rencontre une difficulté de connexion. Veuillez vérifier votre accès internet ou réessayer dans quelques minutes.', 
            sender: 'bot', 
            time: new Date() 
          });
          this.isLoading = false;
        }
      });
    }, 400);
  }

  private scrollToBottom() {
    setTimeout(() => {
      const container = document.querySelector('.chat-messages');
      if (container) {
        container.scrollTop = container.scrollHeight;
      }
    }, 100);
  }

  quickAction(text: string) {
    this.userInput = text;
    this.sendMessage();
  }

  clearMessages() {
    this.messages = [
      { text: 'La session a été réinitialisée avec succès. Je suis à nouveau prêt à vous assister.', sender: 'bot', time: new Date() }
    ];
    this.sessionId = Math.random().toString(36).substring(7);
  }
}
