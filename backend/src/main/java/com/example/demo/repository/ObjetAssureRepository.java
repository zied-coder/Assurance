package com.example.demo.repository;

import com.example.demo.model.ObjetAssure;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ObjetAssureRepository extends MongoRepository<ObjetAssure, String> {

    // 🔍 Récupérer objets d’un contrat
    List<ObjetAssure> findByContratId(String contratId);

    // 🗑 Supprimer objets d’un contrat
    void deleteByContratId(String contratId);
}