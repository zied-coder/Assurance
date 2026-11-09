package com.example.demo.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.Date;

@Document(collection = "demandes_service")
public class DemandeService {

    @Id
    private String id;
    private String contratId;
    private String userId;
    private String type; // RESILIATION, MODIFICATION
    private String status; // EN_ATTENTE, APPROUVEE, REJETEE
    private String description;
    private String updatePayload; // JSON string for modification data
    private Date createdAt;
    private Date processedAt;
    private String feedbackManager;

    public DemandeService() {
        this.createdAt = new Date();
        this.status = "EN_ATTENTE";
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getContratId() { return contratId; }
    public void setContratId(String contratId) { this.contratId = contratId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getUpdatePayload() { return updatePayload; }
    public void setUpdatePayload(String updatePayload) { this.updatePayload = updatePayload; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getProcessedAt() { return processedAt; }
    public void setProcessedAt(Date processedAt) { this.processedAt = processedAt; }
    public String getFeedbackManager() { return feedbackManager; }
    public void setFeedbackManager(String feedbackManager) { this.feedbackManager = feedbackManager; }
}
