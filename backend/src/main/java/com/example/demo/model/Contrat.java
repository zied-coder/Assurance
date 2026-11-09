package com.example.demo.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.Date;

@Document(collection = "contrats")
public class Contrat {

    @Id
    private String id;

    // ================= 📄 INFOS CONTRAT =================
    private String numero;
    private String type;
    private String formule;
    private String statut;
    private String riskLevel;

    // ================= 📅 DATES =================
    private Date dateDebut;
    private Date dateFin;
    private Date createdAt;

    // ================= ⏳ DURÉE & FRÉQUENCE =================
    private int duree; // durée en années (ex: 1, 2)
    private String frequencePaiement; // MENSUEL, TRIMESTRIEL, SEMESTRIEL, ANNUEL

    // ================= 💰 FINANCE =================
    private double prime;
    private String modePaiement;
    private Date dateProchainPaiement;
    private String etatPaiement;

    // ================= 👤 CLIENT (🔥 CIN AU LIEU DE userId) =================
    private String cin;
    private String userId;

    // ================= CONSTRUCTEUR =================
    public Contrat() {
        this.createdAt = new Date();
        this.statut = "ACTIF";
        this.etatPaiement = "EN_ATTENTE";
        this.prime = 0.0;
    }

    // ================= GETTERS & SETTERS =================

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getFormule() { return formule; }
    public void setFormule(String formule) { this.formule = formule; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public Date getDateDebut() { return dateDebut; }
    public void setDateDebut(Date dateDebut) { this.dateDebut = dateDebut; }

    public Date getDateFin() { return dateFin; }
    public void setDateFin(Date dateFin) { this.dateFin = dateFin; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public double getPrime() { return prime; }
    public void setPrime(double prime) { this.prime = prime; }

    public String getModePaiement() { return modePaiement; }
    public void setModePaiement(String modePaiement) { this.modePaiement = modePaiement; }

    public Date getDateProchainPaiement() { return dateProchainPaiement; }
    public void setDateProchainPaiement(Date dateProchainPaiement) { this.dateProchainPaiement = dateProchainPaiement; }

    public String getEtatPaiement() { return etatPaiement; }
    public void setEtatPaiement(String etatPaiement) { this.etatPaiement = etatPaiement; }

    public int getDuree() { return duree; }
    public void setDuree(int duree) { this.duree = duree; }

    public String getFrequencePaiement() { return frequencePaiement; }
    public void setFrequencePaiement(String frequencePaiement) { this.frequencePaiement = frequencePaiement; }

    // 🔥 CIN
    public String getCin() { return cin; }
    public void setCin(String cin) { this.cin = cin; }
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }
}