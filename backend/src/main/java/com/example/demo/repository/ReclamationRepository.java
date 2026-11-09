package com.example.demo.repository;

import com.example.demo.model.Reclamation;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface ReclamationRepository extends MongoRepository<Reclamation, String> {
    List<Reclamation> findByUserId(String userId);
}