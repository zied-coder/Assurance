package com.example.demo.repository;

import com.example.demo.model.Contrat;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface ContratRepository extends MongoRepository<Contrat, String> {

    // ================= USER =================

    // 🔥 Contrats par CIN (UTILISATEUR ASSURANCE)
    List<Contrat> findByCin(String cin);

    // ⚠️ À garder seulement si tu utilises userId dans d'autres modules
    List<Contrat> findByUserId(String userId);

    // ================= NUMERO CONTRAT =================

    Optional<Contrat> findByNumero(String numero);

    // 🔥 Dernier contrat créé (par numéro)
    Optional<Contrat> findTopByOrderByNumeroDesc();

    // 🔥 Dernier contrat créé (par date)
    Optional<Contrat> findTopByOrderByCreatedAtDesc();
}