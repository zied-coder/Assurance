package com.example.demo.repository;

import com.example.demo.model.Garantie;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface GarantieRepository extends MongoRepository<Garantie, String> {

    // 🔍 Récupérer garanties d’un contrat
    List<Garantie> findByContratId(String contratId);

    // 🗑 Supprimer garanties d’un contrat
    void deleteByContratId(String contratId);
}