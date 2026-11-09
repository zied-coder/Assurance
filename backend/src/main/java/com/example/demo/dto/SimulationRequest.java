package com.example.demo.dto;

public class SimulationRequest {

    public int age;
    public double valeur;
    public String typeAssurance;
    public String formule;
    public Integer ageVehicule;
    public Integer puissanceMoteur;
    public Integer puissanceFiscale;

    // Habitation
    public Integer ageBatiment;
    public String niveauSecurite;
    public String zoneGeo;

    // Sante / Vie
    public Integer ageAssure;
    public String antecedentsMedicaux;
    public String profession;
    public String etatSante;
    public Double capitalAssure;
    public java.util.List<String> specialitesMedicales;
    public Boolean couvertureHospitaliere;
}