import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpClientModule } from '@angular/common/http';

@Component({
  selector: 'app-simulation',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './simulation.component.html',
  styleUrls: ['./simulation.component.css']
})
export class SimulationComponent {

  data = {
    age: null as unknown as number,
    valeur: null as unknown as number,
    typeAssurance: '',
    formule: '',
    ageVehicule: null as unknown as number,
    puissanceMoteur: null as unknown as number
  };

  result: any;

  formulesDisponibles: string[] = [];

  constructor(private http: HttpClient) {}

  updateFormules() {

    if (this.data.typeAssurance === 'AUTO') {
      this.formulesDisponibles = ['TIERS_SIMPLE', 'TIERS_ETENDU', 'TOUS_RISQUES', 'TOUS_RISQUES_PREMIUM'];
    }

    else if (this.data.typeAssurance === 'HABITATION') {
      this.formulesDisponibles = ['BASIQUE', 'MOYENNE', 'PREMIUM'];
    }

    else if (this.data.typeAssurance === 'SANTE') {
      this.formulesDisponibles = ['BASIQUE', 'MOYENNE', 'PREMIUM'];
    }

    else if (this.data.typeAssurance === 'VIE') {
      this.formulesDisponibles = ['BASIQUE', 'MOYENNE', 'PREMIUM'];
    }

    this.data.formule = '';
  }

  simuler() {

    this.http.post(
      "http://localhost:8082/api/simulation/calcul",
      this.data
    ).subscribe(res => {
      this.result = res;
    });

  }
}