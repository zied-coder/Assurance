package com.example.demo.repository;

import com.example.demo.model.DemandeService;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface DemandeServiceRepository extends MongoRepository<DemandeService, String> {
    List<DemandeService> findByUserId(String userId);
    List<DemandeService> findByStatus(String status);
}
