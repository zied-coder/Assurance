package com.example.demo.model;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "garanties")
public class Garantie {

    @Id
    private String id;

    private String nom;
    private String description;
    private double plafond;

    private String contratId;

    public Garantie() {}

    // ================= GETTERS & SETTERS =================

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getPlafond() {
        return plafond;
    }

    public void setPlafond(double plafond) {
        this.plafond = plafond;
    }

    public String getContratId() {
        return contratId;
    }

    public void setContratId(String contratId) {
        this.contratId = contratId;
    }
}