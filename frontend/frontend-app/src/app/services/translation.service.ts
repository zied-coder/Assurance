import { Injectable, signal, effect, Inject, PLATFORM_ID } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { TRANSLATIONS } from '../i18n/translations';

@Injectable({
  providedIn: 'root'
})
export class TranslationService {
  currentLang = signal<string>('fr');

  constructor(@Inject(PLATFORM_ID) private platformId: Object) {
    if (isPlatformBrowser(this.platformId)) {
      const savedLang = localStorage.getItem('bna-lang') || 'fr';
      this.currentLang.set(savedLang);
    }

    // Effect triggers when currentLang changes
    effect(() => {
      const lang = this.currentLang();
      if (isPlatformBrowser(this.platformId)) {
        localStorage.setItem('bna-lang', lang);
        document.documentElement.lang = lang;
        if (lang === 'ar') {
          document.documentElement.dir = 'rtl';
        } else {
          document.documentElement.dir = 'ltr';
        }
      }
    });
  }

  setLanguage(lang: string) {
    if (['fr', 'en', 'ar'].includes(lang)) {
      this.currentLang.set(lang);
    }
  }

  getInstant(key: string, params?: Record<string, string | number>): string {
    const lang = this.currentLang();
    const keys = key.split('.');
    let translation: any = TRANSLATIONS[lang];

    for (const k of keys) {
      if (translation && translation[k] !== undefined) {
        translation = translation[k];
      } else {
        // Fallback to FR
        let fallback = TRANSLATIONS['fr'];
        for (const fk of keys) {
          if (fallback && fallback[fk] !== undefined) {
            fallback = fallback[fk];
          } else {
            return key;
          }
        }
        translation = fallback;
        break;
      }
    }

    if (typeof translation !== 'string') {
      return key;
    }

    let result = translation;
    if (params) {
      Object.keys(params).forEach(paramKey => {
        result = result.replace(new RegExp(`\\{\\{\\s*${paramKey}\\s*\\}\\}`, 'g'), String(params[paramKey]));
      });
    }
    return result;
  }
}
