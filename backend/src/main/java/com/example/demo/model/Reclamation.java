package com.example.demo.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.Date;

@Document(collection = "reclamations")
public class Reclamation {

    @Id
    private String id;
    private String userId;
    private String userEmail;
    private String userCin;
    
    private String titre;
    private String description;
    private String type; // DELAY, DISPUTE, PAYMENT_ISSUE, OTHER
    
    // Status Flow: SUBMITTED -> UNDER_REVIEW -> IN_PROGRESS -> RESOLVED / REJECTED
    private String statut; 
    
    private String reponse; // Commentaire du gestionnaire
    private Date dateCreation;
    private Date dateUpdate;
    
    // Link to Claim
    private String sinistreId;
    private String sinistreNumero; // SIN-XXXX for quick display
    
    private String document; // Optional attachment filename

    // ===== Getters & Setters =====
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserCin() { return userCin; }
    public void setUserCin(String userCin) { this.userCin = userCin; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getReponse() { return reponse; }
    public void setReponse(String reponse) { this.reponse = reponse; }

    public Date getDateCreation() { return dateCreation; }
    public void setDateCreation(Date dateCreation) { this.dateCreation = dateCreation; }

    public Date getDateUpdate() { return dateUpdate; }
    public void setDateUpdate(Date dateUpdate) { this.dateUpdate = dateUpdate; }

    public String getSinistreId() { return sinistreId; }
    public void setSinistreId(String sinistreId) { this.sinistreId = sinistreId; }

    public String getSinistreNumero() { return sinistreNumero; }
    public void setSinistreNumero(String sinistreNumero) { this.sinistreNumero = sinistreNumero; }

    public String getDocument() { return document; }
    public void setDocument(String document) { this.document = document; }
}