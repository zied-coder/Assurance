package com.example.demo.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "objets_assures")
public class ObjetAssure {

    @Id
    private String id;

    private String type; // AUTO ou HABITATION

    // ================= AUTO =================
    private String marque;
    private String modele;
    private String immatriculation;
    private String registrationType; // TU, FCR, RS, CD

    private int ageVehicule;
    private int puissanceFiscale;
    private int puissanceMoteur;
    private double valeurVehicule;

    // ================= HABITATION =================
    private String adresseBien;
    private double valeurBien;
    private int ageBatiment;
    private String niveauSecurite; // BAS, MOYEN, HAUT
    private String zoneGeo; // URBAINE, RURALE, RISQUE

    // ================= PERSONNE (SANTE / VIE) =================
    private int ageAssure;
    private String antecedentsMedicaux; // AUCUN, CHRONIQUE, GRAVE
    private String profession; // RISQUE, STANDARD
    private String etatSante; // BON, FRAGILE
    private double capitalAssure;

    private java.util.List<String> specialitesMedicales;
    private boolean couvertureHospitaliere;

    private String contratId;

    public ObjetAssure() {}

    // ================= GETTERS & SETTERS =================

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getMarque() { return marque; }
    public void setMarque(String marque) { this.marque = marque; }

    public String getModele() { return modele; }
    public void setModele(String modele) { this.modele = modele; }

    public String getImmatriculation() { return immatriculation; }
    public void setImmatriculation(String immatriculation) { this.immatriculation = immatriculation; }

    public String getRegistrationType() { return registrationType; }
    public void setRegistrationType(String registrationType) { this.registrationType = registrationType; }

    public int getAgeVehicule() { return ageVehicule; }
    public void setAgeVehicule(int ageVehicule) { this.ageVehicule = ageVehicule; }

    public int getPuissanceFiscale() { return puissanceFiscale; }
    public void setPuissanceFiscale(int puissanceFiscale) { this.puissanceFiscale = puissanceFiscale; }

    public int getPuissanceMoteur() { return puissanceMoteur; }
    public void setPuissanceMoteur(int puissanceMoteur) { this.puissanceMoteur = puissanceMoteur; }

    public double getValeurVehicule() { return valeurVehicule; }
    public void setValeurVehicule(double valeurVehicule) { this.valeurVehicule = valeurVehicule; }

    public String getAdresseBien() { return adresseBien; }
    public void setAdresseBien(String adresseBien) { this.adresseBien = adresseBien; }

    public double getValeurBien() { return valeurBien; }
    public void setValeurBien(double valeurBien) { this.valeurBien = valeurBien; }

    public int getAgeBatiment() { return ageBatiment; }
    public void setAgeBatiment(int ageBatiment) { this.ageBatiment = ageBatiment; }

    public String getNiveauSecurite() { return niveauSecurite; }
    public void setNiveauSecurite(String niveauSecurite) { this.niveauSecurite = niveauSecurite; }

    public String getZoneGeo() { return zoneGeo; }
    public void setZoneGeo(String zoneGeo) { this.zoneGeo = zoneGeo; }

    public int getAgeAssure() { return ageAssure; }
    public void setAgeAssure(int ageAssure) { this.ageAssure = ageAssure; }

    public String getAntecedentsMedicaux() { return antecedentsMedicaux; }
    public void setAntecedentsMedicaux(String antecedentsMedicaux) { this.antecedentsMedicaux = antecedentsMedicaux; }

    public String getProfession() { return profession; }
    public void setProfession(String profession) { this.profession = profession; }

    public String getEtatSante() { return etatSante; }
    public void setEtatSante(String etatSante) { this.etatSante = etatSante; }

    public double getCapitalAssure() { return capitalAssure; }
    public void setCapitalAssure(double capitalAssure) { this.capitalAssure = capitalAssure; }

    public java.util.List<String> getSpecialitesMedicales() { return specialitesMedicales; }
    public void setSpecialitesMedicales(java.util.List<String> specialitesMedicales) { this.specialitesMedicales = specialitesMedicales; }

    public boolean isCouvertureHospitaliere() { return couvertureHospitaliere; }
    public void setCouvertureHospitaliere(boolean couvertureHospitaliere) { this.couvertureHospitaliere = couvertureHospitaliere; }

    public String getContratId() { return contratId; }
    public void setContratId(String contratId) { this.contratId = contratId; }
}