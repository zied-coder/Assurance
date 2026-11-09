package com.example.demo.repository;

import com.example.demo.model.Sinistre;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface SinistreRepository extends MongoRepository<Sinistre, String> {

    // ================= USER =================

    // 🔹 Tous les sinistres d’un utilisateur
    List<Sinistre> findByUserId(String userId);

    // 🔹 Sinistres en attente (EN_ATTENTE)
    List<Sinistre> findByUserIdAndStatut(String userId, String statut);

    // ================= STATUT =================

    // 🔹 Tous les sinistres par statut (gestionnaire)
    List<Sinistre> findByStatut(String statut);

    // 🔹 Sinistres en attente d'information
    List<Sinistre> findByStatutAndUserId(String statut, String userId);

    // ================= CONTRAT =================

    // 🔥 IMPORTANT assurance (filtrer par contrat)
    List<Sinistre> findByContratId(String contratId);

    // 🔹 Sinistres d’un contrat + statut
    List<Sinistre> findByContratIdAndStatut(String contratId, String statut);
}