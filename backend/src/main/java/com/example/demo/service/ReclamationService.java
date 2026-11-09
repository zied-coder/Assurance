package com.example.demo.service;

import com.example.demo.model.Reclamation;
import com.example.demo.repository.ReclamationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Date;
import java.util.List;

@Service
public class ReclamationService {

    @Autowired
    private ReclamationRepository repository;

    // ================= CLIENT =================

    public Reclamation create(Reclamation r) {
        r.setDateCreation(new Date());
        r.setDateUpdate(new Date());
        r.setStatut("SUBMITTED");
        return repository.save(r);
    }

    public List<Reclamation> getByUser(String userId) {
        return repository.findByUserId(userId);
    }

    // ================= GESTIONNAIRE =================

    public List<Reclamation> getAll() {
        return repository.findAll();
    }

    public Reclamation getById(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Réclamation non trouvée avec ID: " + id));
    }

    /**
     * Met à jour le statut de la réclamation (UNDER_REVIEW, IN_PROGRESS, RESOLVED, REJECTED)
     */
    public Reclamation updateStatus(String id, String statut, String reponse) {
        Reclamation r = getById(id);
        
        r.setStatut(statut);
        if (reponse != null) {
            r.setReponse(reponse);
        }
        r.setDateUpdate(new Date());
        
        return repository.save(r);
    }

    public void delete(String id) {
        repository.deleteById(id);
    }
}