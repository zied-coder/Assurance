package com.example.demo.service;

import com.example.demo.dto.SimulationRequest;
import com.example.demo.dto.SimulationResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class SimulationService {

    private final PricingService pricingService;

    public SimulationService(PricingService pricingService) {
        this.pricingService = pricingService;
    }

    public SimulationResponse simuler(SimulationRequest req) {
        double prix = 0;
        double couverture = 0;
        List<String> detailsGaranties = new ArrayList<>();
        String riskLevel = "FAIBLE";

        String type = req.typeAssurance != null ? req.typeAssurance.toUpperCase() : "";
        String formule = req.formule != null ? req.formule.toUpperCase() : "";

        if ("AUTO".equals(type)) {
            int ageV = req.ageVehicule != null ? req.ageVehicule : 0;
            int puissance = req.puissanceFiscale != null ? req.puissanceFiscale : (req.puissanceMoteur != null ? req.puissanceMoteur : 0);
            double valeur = req.valeur;

            riskLevel = pricingService.evaluateRiskAuto(valeur, ageV, puissance);
            prix = pricingService.calculerPrimeAuto(valeur, ageV, puissance, formule);

            detailsGaranties.add("✔️ Responsabilité Civile (1 000 000 DT)");

            if ("TIERS_SIMPLE".equals(formule)) {
                couverture = 1000000;
                detailsGaranties.add("✔️ Défense et Recours (5 000 DT)");
            } 
            else if ("TIERS_ETENDU".equals(formule)) {
                couverture = 1000000 + (valeur * 0.70); 
                detailsGaranties.add("✔️ Défense et Recours (5 000 DT)");
                detailsGaranties.add("✔️ Bris de Glace (" + Math.round(valeur * 0.05) + " DT)");
                detailsGaranties.add("✔️ Vol et Incendie (" + Math.round(valeur * 0.65) + " DT)");
            }
            else if ("TOUS_RISQUES".equals(formule) || "TOUS_RISQUES_PREMIUM".equals(formule)) {
                couverture = 1000000 + valeur;
                detailsGaranties.add("✔️ Défense et Recours (5 000 DT)");
                detailsGaranties.add("✔️ Bris de Glace (" + Math.round(valeur * 0.05) + " DT)");
                detailsGaranties.add("✔️ Vol et Incendie (" + Math.round(valeur * 0.65) + " DT)");
                
                if ("ÉLEVÉ".equals(riskLevel) || "ELEVÉ".equals(riskLevel)) {
                    detailsGaranties.add("❌ Dommages Tous Accidents (Refusé: Risque Élevé)");
                } else {
                    detailsGaranties.add("✔️ Dommages Tous Accidents (" + Math.round(valeur) + " DT)");
                }

                if ("TOUS_RISQUES_PREMIUM".equals(formule)) {
                    detailsGaranties.add("✔️ Assistance 24/7 0km");
                    if ("ÉLEVÉ".equals(riskLevel) || "ELEVÉ".equals(riskLevel)) detailsGaranties.add("❌ Garantie Conducteur (Refusé: Risque Élevé)");
                    else detailsGaranties.add("✔️ Garantie Conducteur (50 000 DT)");
                }
            }

        } else if ("HABITATION".equals(type)) {
            int ageB = req.ageBatiment != null ? req.ageBatiment : 0;
            String sec = req.niveauSecurite != null ? req.niveauSecurite : "BAS";
            String zone = req.zoneGeo != null ? req.zoneGeo : "URBAINE";
            
            riskLevel = pricingService.evaluateRiskHabitation(req.valeur, ageB, sec, zone);
            prix = pricingService.calculerPrimeHabitation(req.valeur, ageB, sec, zone, formule);
            couverture = req.valeur * 0.8;
            detailsGaranties.add("✔️ Incendie et Explosion");
            detailsGaranties.add("✔️ Dégâts des eaux");
            if (!riskLevel.contains("ÉLEVÉ")) detailsGaranties.add("✔️ Vol et Vandalisme");

        } else if ("SANTE".equals(type)) {
            int ageA = req.ageAssure != null ? req.ageAssure : 30;
            String ant = req.antecedentsMedicaux != null ? req.antecedentsMedicaux : "AUCUN";
            String prof = req.profession != null ? req.profession : "STANDARD";

            riskLevel = pricingService.evaluateRiskSante(ageA, ant, prof);
            prix = pricingService.calculerPrimeSante(ageA, ant, prof, formule, req.specialitesMedicales, req.couvertureHospitaliere != null && req.couvertureHospitaliere);
            double plafond = "PREMIUM".equals(formule) ? 10000 : 5000;
            couverture = plafond * 3;
            detailsGaranties.add("✔️ Hospitalisation");
            detailsGaranties.add("✔️ Soins Courants");
            if (!riskLevel.contains("ÉLEVÉ")) detailsGaranties.add("✔️ Dentaire & Optique");

        } else if ("VIE".equals(type)) {
            int ageA = req.ageAssure != null ? req.ageAssure : 30;
            String etat = req.etatSante != null ? req.etatSante : "BON";
            double cap = req.capitalAssure != null ? req.capitalAssure : 10000;

            riskLevel = pricingService.evaluateRiskVie(ageA, etat, cap);
            prix = pricingService.calculerPrimeVie(ageA, etat, cap, formule);
            couverture = cap;
            detailsGaranties.add("✔️ Capital Décès");
            if (!riskLevel.contains("ÉLEVÉ")) detailsGaranties.add("✔️ Invalidité Absolue");
        }

        SimulationResponse res = new SimulationResponse();
        res.prix = Math.round(prix * 100.0) / 100.0;
        res.couverture = Math.round(couverture * 100.0) / 100.0;
        res.detailsGaranties = detailsGaranties;
        res.riskLevel = riskLevel;
        res.message = "Risque évalué : " + riskLevel + " | Prime et garanties ajustées selon le profil du véhicule.";
        
        return res;
    }



    @Deprecated
    public double calculerPrix(String type, String formule, double valeur, int age) {
        SimulationRequest req = new SimulationRequest();
        req.typeAssurance = type;
        req.formule = formule;
        req.valeur = valeur;
        req.age = age;
        return simuler(req).prix;
    }
}