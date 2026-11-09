package com.example.demo.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Document(collection = "sinistres")
public class Sinistre {

    @Id
    private String id;

    // 🔥 IDENTIFIANT MÉTIER
    private String numero;

    // 🔥 INFOS SINISTRE
    private String titre;
    private String description;
    private Date date;
    private Date incidentDate;
    private Date declarationDate;
    private String adresse;
    private String userCin;

    // 🔥 GPS
    private Double latitude;
    private Double longitude;

    // 🔥 WORKFLOW
    private String statut;
    private String commentaire;

    // 🔥 EXPERT
    private String expertNom;
    private String expertTelephone;
    private String expertRendezVous;
    private String rapportExpert;

    // 🔥 LIENS
    private String userId;
    private String userEmail;
    private String contratId;

    // 🔥 🆕 CONTRAT COMPLET (NON STOCKÉ EN DB)
    @Transient
    private Contrat contrat;

    // 🔥 DOCUMENT
    private String document;

    // ----- CONSTRUCTEUR -----
    public Sinistre() {}

    public Sinistre(String titre, String description, Date incidentDate, String userId, String userEmail) {
        this.titre = titre;
        this.description = description;
        this.incidentDate = incidentDate;
        this.declarationDate = new Date();
        this.date = incidentDate;
        this.userId = userId;
        this.userEmail = userEmail;

        this.statut = "SUBMITTED";
        this.commentaire = "";
        this.document = "";
    }

    // ----- GETTERS / SETTERS -----

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getNumero() { return numero; }
    public void setNumero(String numero) { this.numero = numero; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getDate() { return date; }
    public void setDate(Date date) { this.date = date; }

    public Date getIncidentDate() { return incidentDate; }
    public void setIncidentDate(Date incidentDate) { this.incidentDate = incidentDate; }

    public Date getDeclarationDate() { return declarationDate; }
    public void setDeclarationDate(Date declarationDate) { this.declarationDate = declarationDate; }

    public Long getDelaiDeclaration() {
        if (declarationDate == null || incidentDate == null) {
            return null;
        }
        long diff = declarationDate.getTime() - incidentDate.getTime();
        return diff / (1000 * 60 * 60 * 24);
    }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getCommentaire() { return commentaire; }
    public void setCommentaire(String commentaire) { this.commentaire = commentaire; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getContratId() { return contratId; }
    public void setContratId(String contratId) { this.contratId = contratId; }

    public Contrat getContrat() { return contrat; }
    public void setContrat(Contrat contrat) { this.contrat = contrat; }

    public String getDocument() { return document; }
    public void setDocument(String document) { this.document = document; }

    public String getUserCin() { return userCin; }
    public void setUserCin(String userCin) { this.userCin = userCin; }

    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }

    public String getExpertNom() { return expertNom; }
    public void setExpertNom(String expertNom) { this.expertNom = expertNom; }

    public String getExpertTelephone() { return expertTelephone; }
    public void setExpertTelephone(String expertTelephone) { this.expertTelephone = expertTelephone; }

    public String getExpertRendezVous() { return expertRendezVous; }
    public void setExpertRendezVous(String expertRendezVous) { this.expertRendezVous = expertRendezVous; }

    public String getRapportExpert() { return rapportExpert; }
    public void setRapportExpert(String rapportExpert) { this.rapportExpert = rapportExpert; }

    public String getFileUrl() {
        if (document == null || document.isEmpty()) return null;
        return "/uploads/" + document;
    }
}