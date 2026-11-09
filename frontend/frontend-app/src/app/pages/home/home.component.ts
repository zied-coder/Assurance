import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { SimulationComponent } from '../../components/simulation/simulation.component';
import { ChatbotComponent } from '../../components/chatbot/chatbot.component';
import { TranslationService } from '../../services/translation.service';
import { TranslatePipe } from '../../pipes/translate.pipe';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, RouterModule, SimulationComponent, ChatbotComponent, TranslatePipe],
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent {

  selectedInfo: any = null;
  showSimulation = false;
  isLangDropdownOpen = false;

  constructor(public translationService: TranslationService) {}

  openSimulation() {
    this.showSimulation = true;
  }

  closeSimulation() {
    this.showSimulation = false;
  }

  showInfo(type: string) {

    const data: any = {
      auto: {
        title: this.translationService.getInstant('home.auto_popup_title'),
        icon: "🚗",
        text: this.translationService.getInstant('home.auto_popup_text')
      },
      habitation: {
        title: this.translationService.getInstant('home.habitation_popup_title'),
        icon: "🏠",
        text: this.translationService.getInstant('home.habitation_popup_text')
      },
      sante: {
        title: this.translationService.getInstant('home.sante_popup_title'),
        icon: "❤️",
        text: this.translationService.getInstant('home.sante_popup_text')
      }
    };

    this.selectedInfo = data[type];
  }

  closePopup() {
    this.selectedInfo = null;
  }

  toggleLangDropdown() {
    this.isLangDropdownOpen = !this.isLangDropdownOpen;
  }

  selectLanguage(lang: string) {
    this.translationService.setLanguage(lang);
    this.isLangDropdownOpen = false;
  }

  getLanguageLabel(lang: string): string {
    if (lang === 'fr') return 'FR';
    if (lang === 'en') return 'EN';
    if (lang === 'ar') return 'AR';
    return 'FR';
  }
}