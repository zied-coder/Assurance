import { Pipe, PipeTransform } from '@angular/core';
import { TranslationService } from '../services/translation.service';

@Pipe({
  name: 'translate',
  pure: false,
  standalone: true
})
export class TranslatePipe implements PipeTransform {
  constructor(private translationService: TranslationService) {}

  transform(key: string, params?: Record<string, string | number>): string {
    if (!key) return '';
    return this.translationService.getInstant(key, params);
  }
}
