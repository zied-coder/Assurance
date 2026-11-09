package com.example.demo.service;

import com.example.demo.model.ObjetAssure;
import org.springframework.stereotype.Service;

@Service
public class PricingService {

    public double calculerPrimeAuto(double valeur, int age, int puissance, String formule) {
        String riskLevel = evaluateRiskAuto(valeur, age, puissance);

        // 💰 Base Premium = Vehicle Value × 2.5% (Professional base)
        double basePremium = valeur * 0.025;

        // 🧾 Plan-Based Pricing Adjustment (Steeper progression)
        double planAdjustment = 0;
        if (formule != null) {
            switch(formule.toUpperCase()) {
                case "TIERS_SIMPLE": case "THIRD_PARTY": planAdjustment = 0; break;
                case "TIERS_ETENDU": case "EXTENDED_THIRD_PARTY": planAdjustment = 500; break;
                case "TOUS_RISQUES": case "COMPREHENSIVE": planAdjustment = 1500; break;
                case "TOUS_RISQUES_PREMIUM": case "PREMIUM": planAdjustment = 3000; break;
            }
        }

        // ⚖️ Risk Adjustment Factor (Highly visible correlation)
        double riskFactor = 1.0;
        switch(riskLevel) {
            case "FAIBLE": riskFactor = 1.0; break;
            case "MODÉRÉ": riskFactor = 2.0; break; // Double for moderate
            case "ÉLEVÉ": riskFactor = 3.5; break;  // Heavy penalty for high risk
        }

        // 🧮 Final Premium = (Base Premium + Plan Adjustment) × Risk Factor
        return Math.round((basePremium + planAdjustment) * riskFactor);
    }

    public String evaluateRiskAuto(double valeur, int age, int puissance) {
        int riskScore = 0;

        // Vehicle value above 50,000 TND → +2 points
        if (valeur > 50000) riskScore += 2;

        // Engine power above 7 HP → +1 point
        if (puissance > 7) riskScore += 1;

        // Vehicle age less than 5 years → +1 point
        if (age < 5) riskScore += 1;

        // Urban usage (assumed by default for this simplified model or can be added as a field)
        riskScore += 1; // +1 point for urban traffic zones

        if (riskScore >= 4) return "ÉLEVÉ";
        else if (riskScore >= 2) return "MODÉRÉ";
        else return "FAIBLE";
    }

    // ================= HABITATION =================
    public double calculerPrimeHabitation(double valeur, int ageBatiment, String securite, String zone, String formule) {
        String riskLevel = evaluateRiskHabitation(valeur, ageBatiment, securite, zone);

        // 💰 Base Premium = Property Value × 0.4%
        double basePremium = valeur * 0.004;

        // 🧾 Plan-Based Pricing Adjustment
        double planAdjustment = 0;
        if (formule != null) {
            switch(formule.toUpperCase()) {
                case "BASIQUE": case "BASIC": planAdjustment = 0; break;
                case "MOYENNE": case "MOYEN": case "STANDARD": planAdjustment = 200; break;
                case "PREMIUM": planAdjustment = 600; break;
            }
        }

        // ⚖️ Risk Adjustment Factor
        double riskFactor = 1.0;
        switch(riskLevel) {
            case "FAIBLE": riskFactor = 1.0; break;
            case "MODÉRÉ": riskFactor = 1.5; break;
            case "ÉLEVÉ": riskFactor = 2.5; break;
        }

        // 🧮 Final Premium = (Base Premium + Plan Adjustment) × Risk Factor
        return Math.round((basePremium + planAdjustment) * riskFactor);
    }

    public String evaluateRiskHabitation(double valeur, int ageBatiment, String securite, String zone) {
        int score = 0;

        // Property value above 100,000 TND → +2 points
        if (valeur > 100000) score += 2;

        // Urban location (high exposure area) → +1 point
        if ("URBAINE".equalsIgnoreCase(zone)) score += 1;

        // Old property (aging infrastructure) → +1 point (assuming > 20 years)
        if (ageBatiment > 20) score += 1;

        // Absence of security systems → +1 point
        if ("BAS".equalsIgnoreCase(securite) || "NONE".equalsIgnoreCase(securite)) score += 1;

        if (score >= 4) return "ÉLEVÉ";
        if (score >= 2) return "MODÉRÉ";
        return "FAIBLE";
    }

    // ================= SANTE =================
    public double calculerPrimeSante(int age, String antecedents, String profession, String formule, java.util.List<String> specialites, boolean hospit) {
        String riskLevel = evaluateRiskSante(age, antecedents, profession);
        
        // 💰 Base Premium
        double basePremium = 200;

        // 🩺 Medical Specialties Cost (Dynamic addition)
        double specialtiesCost = 0;
        if (specialites != null) {
            specialtiesCost = specialites.size() * 100; // 100 TND per specialty
        }

        // 🏥 Hospitalization/Surgical Impact (Highest impact)
        double hospitalImpact = hospit ? 1200 : 0;

        // 🧾 Formula Adjustment
        double formulaAdjustment = 0;
        if (formule != null) {
            switch(formule.toUpperCase()) {
                case "BASIQUE": formulaAdjustment = 0; break;
                case "MOYENNE": case "MOYEN": formulaAdjustment = 400; break;
                case "PREMIUM": formulaAdjustment = 1000; break;
            }
        }

        double subTotal = basePremium + specialtiesCost + hospitalImpact + formulaAdjustment;
        
        // ⚖️ Risk Adjustment Factor
        double riskFactor = 1.0;
        switch(riskLevel) {
            case "FAIBLE": riskFactor = 1.0; break;
            case "MODÉRÉ": riskFactor = 1.6; break;
            case "ÉLEVÉ": riskFactor = 3.0; break;
        }

        return Math.round(subTotal * riskFactor);
    }

    public String evaluateRiskSante(int age, String antecedents, String profession) {
        int score = 0;
        if (age > 60) score += 3; else if (age > 40) score += 1;
        if ("GRAVE".equalsIgnoreCase(antecedents)) score += 4; else if ("CHRONIQUE".equalsIgnoreCase(antecedents)) score += 2;
        if ("RISQUE".equalsIgnoreCase(profession)) score += 2;

        if (score >= 5) return "ÉLEVÉ";
        if (score >= 2) return "MODÉRÉ";
        return "FAIBLE";
    }

    // ================= VIE =================
    public double calculerPrimeVie(int age, String etatSante, double capital, String formule) {
        String riskLevel = evaluateRiskVie(age, etatSante, capital);
        double basePremium = capital * 0.001;

        double formulaAdjustment = 0;
        if (formule != null) {
            switch(formule.toUpperCase()) {
                case "BASIQUE": formulaAdjustment = 200; break;
                case "MOYENNE": case "MOYEN": formulaAdjustment = 600; break;
                case "PREMIUM": formulaAdjustment = 1500; break;
            }
        }

        double subTotal = basePremium + formulaAdjustment;
        double riskAdjustment = 0;
        switch(riskLevel) {
            case "FAIBLE": riskAdjustment = 0; break;
            case "MODÉRÉ": riskAdjustment = subTotal * 0.9; break;
            case "ÉLEVÉ": riskAdjustment = subTotal * 3.0; break;
        }
        return Math.round(subTotal + riskAdjustment);
    }

    public String evaluateRiskVie(int age, String etatSante, double capital) {
        int score = 0;
        if (age > 65) score += 3; else if (age > 50) score += 1;
        if ("FRAGILE".equalsIgnoreCase(etatSante)) score += 3;
        if (capital > 200000) score += 2;

        if (score >= 5) return "ÉLEVÉ";
        if (score >= 2) return "MODÉRÉ";
        return "FAIBLE";
    }

    @Deprecated
    public double calculerPrime(ObjetAssure obj, String formule) {
        if ("AUTO".equalsIgnoreCase(obj.getType())) {
            return calculerPrimeAuto(obj.getValeurVehicule(), obj.getAgeVehicule(), obj.getPuissanceFiscale(), formule);
        } else if ("HABITATION".equalsIgnoreCase(obj.getType())) {
            return calculerPrimeHabitation(obj.getValeurBien(), obj.getAgeBatiment(), obj.getNiveauSecurite(), obj.getZoneGeo(), formule);
        }
        return 0;
    }
}