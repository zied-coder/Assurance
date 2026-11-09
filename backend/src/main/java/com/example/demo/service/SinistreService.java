package com.example.demo.service;

import com.example.demo.model.Contrat;
import com.example.demo.model.Sinistre;
import com.example.demo.repository.ContratRepository;
import com.example.demo.repository.SinistreRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class SinistreService {

    @Autowired
    private SinistreRepository repository;

    @Autowired
    private ContratRepository contratRepository;

    // ================= 🔥 ENRICHIR CONTRAT =================
    public Sinistre enrichirContrat(Sinistre s) {

        if (s.getContratId() != null) {
            contratRepository.findById(s.getContratId())
                    .ifPresent(s::setContrat);
        }

        return s;
    }

    // ================= GENERATION NUMERO =================
    public String generateNumero() {
        long count = repository.count() + 1;
        return "SIN-" + String.format("%04d", count);
    }

    // ================= CREATE =================
    public Sinistre create(Sinistre s) {
        if (s.getIncidentDate() == null) {
            s.setIncidentDate(new Date());
        }

        Date declarationDate = new Date(); // toujours générée automatiquement
        s.setDeclarationDate(declarationDate);
        s.setDate(s.getIncidentDate());

        // ============ Validation : délai max de déclaration = 5 jours ============
        long diffMs = declarationDate.getTime() - s.getIncidentDate().getTime();
        long diffJours = diffMs / (1000L * 60 * 60 * 24);

        if (diffJours > 5) {
            throw new RuntimeException(
                "DÉLAI_DÉPASSÉ: Le sinistre ne peut pas être déclaré après un délai de 5 jours suivant l'incident. " +
                "Incident le : " + s.getIncidentDate() + ". Déclaration le : " + declarationDate + " (" + diffJours + " jours de retard)."
            );
        }

        s.setNumero(generateNumero());
        s.setStatut("SUBMITTED");
        s.setCommentaire("En attente de vérification initiale.");

        return repository.save(s);
    }

    // ================= USER =================
    public List<Sinistre> getByUser(String userId) {
        return repository.findByUserId(userId)
                .stream()
                .map(this::enrichirContrat)
                .toList();
    }

    public List<Sinistre> getByUserEnCours(String userId) {
        return repository.findByUserIdAndStatut(userId, "EN_ATTENTE")
                .stream()
                .map(this::enrichirContrat)
                .toList();
    }

    // ================= ALL =================
    public List<Sinistre> getAll() {
        return repository.findAll()
                .stream()
                .map(this::enrichirContrat)
                .toList();
    }

    // ================= BY ID =================
    public Sinistre getSinistreById(String id) {
        Sinistre s = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Sinistre non trouvé"));

        return enrichirContrat(s);
    }

    // ================= UPDATE STATUS =================
    public Sinistre updateStatus(String id, String statut, String commentaire) {
        Sinistre s = getSinistreById(id);
        s.setStatut(statut);
        s.setCommentaire(commentaire);
        return repository.save(s);
    }

    // ================= UPDATE SINISTRE =================
    public Sinistre updateSinistre(String id, Sinistre sDetails) {

        Sinistre s = getSinistreById(id);

        if (sDetails.getTitre() != null) s.setTitre(sDetails.getTitre());
        if (sDetails.getDescription() != null) s.setDescription(sDetails.getDescription());
        if (sDetails.getIncidentDate() != null) {
            s.setIncidentDate(sDetails.getIncidentDate());
            s.setDate(sDetails.getIncidentDate());
        } else if (sDetails.getDate() != null) {
            s.setDate(sDetails.getDate());
            s.setIncidentDate(sDetails.getDate());
        }
        if (sDetails.getAdresse() != null) s.setAdresse(sDetails.getAdresse());
        if (sDetails.getDocument() != null) s.setDocument(sDetails.getDocument());

        s.setStatut("SUBMITTED");
        s.setCommentaire("Dossier complété par l'assuré.");

        return repository.save(s);
    }

    // ================= DELETE =================
    public void deleteSinistre(String id) {
        repository.deleteById(id);
    }

    // ================= DEMANDE INFO =================
    public Sinistre demanderInfo(String id, String commentaire) {
        Sinistre s = getSinistreById(id);
        s.setStatut("ADDITIONAL_INFORMATION_REQUIRED");
        s.setCommentaire(commentaire);
        return repository.save(s);
    }

    // ================= EXPERT =================
    public Sinistre assignExpert(String id, String nom, String tel, String rdv) {
        Sinistre s = getSinistreById(id);
        s.setExpertNom(nom);
        s.setExpertTelephone(tel);
        s.setExpertRendezVous(rdv);
        s.setStatut("EXPERT_ASSIGNED");
        return repository.save(s);
    }

    public Sinistre submitExpertReport(String id, String rapport) {
        Sinistre s = getSinistreById(id);
        s.setRapportExpert(rapport);
        s.setStatut("UNDER_EXPERT_REVIEW");
        return repository.save(s);
    }

    public Sinistre finalDecision(String id, String statut, String commentaire) {
        Sinistre s = getSinistreById(id);
        s.setStatut(statut);
        s.setCommentaire(commentaire);
        return repository.save(s);
    }
}