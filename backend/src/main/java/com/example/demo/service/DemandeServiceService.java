package com.example.demo.service;

import com.example.demo.model.Contrat;
import com.example.demo.model.DemandeService;
import com.example.demo.model.ObjetAssure;
import com.example.demo.repository.ContratRepository;
import com.example.demo.repository.DemandeServiceRepository;
import com.example.demo.repository.ObjetAssureRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class DemandeServiceService {

    private final DemandeServiceRepository demandeServiceRepository;
    private final ContratRepository contratRepository;
    private final ObjetAssureRepository objetAssureRepository;
    private final ContratService contratService;
    private final ObjectMapper objectMapper;

    public DemandeServiceService(DemandeServiceRepository demandeServiceRepository, 
                                 ContratRepository contratRepository,
                                 ObjetAssureRepository objetAssureRepository,
                                 ContratService contratService,
                                 ObjectMapper objectMapper) {
        this.demandeServiceRepository = demandeServiceRepository;
        this.contratRepository = contratRepository;
        this.objetAssureRepository = objetAssureRepository;
        this.contratService = contratService;
        this.objectMapper = objectMapper;
    }

    public DemandeService createRequest(DemandeService request) {
        request.setCreatedAt(new Date());
        request.setStatus("EN_ATTENTE");
        return demandeServiceRepository.save(request);
    }

    public List<DemandeService> getPendingRequests() {
        return demandeServiceRepository.findByStatus("EN_ATTENTE");
    }

    public List<DemandeService> getUserRequests(String userId) {
        return demandeServiceRepository.findByUserId(userId);
    }

    public DemandeService processRequest(String id, String status, String feedback) {
        DemandeService request = demandeServiceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Demande non trouvée"));

        request.setStatus(status);
        request.setFeedbackManager(feedback);
        request.setProcessedAt(new Date());

        if ("APPROUVEE".equals(status)) {
            Contrat contrat = contratRepository.findById(request.getContratId())
                    .orElseThrow(() -> new RuntimeException("Contrat non trouvé"));

            if ("RESILIATION".equals(request.getType())) {
                contrat.setStatut("RESILIE");
                contratRepository.save(contrat);
            } else if ("MODIFICATION".equals(request.getType())) {
                try {
                    // 1. Parse proposed changes
                    Map<String, Object> updates = objectMapper.readValue(request.getUpdatePayload(), Map.class);
                    
                    // 2. Update the linked object
                    List<ObjetAssure> objets = objetAssureRepository.findByContratId(contrat.getId());
                    if (!objets.isEmpty()) {
                        ObjetAssure o = objets.get(0);
                        // AUTO
                        if (updates.get("valeurVehicule") != null) o.setValeurVehicule(Double.parseDouble(updates.get("valeurVehicule").toString()));
                        if (updates.get("ageVehicule") != null) o.setAgeVehicule(Integer.parseInt(updates.get("ageVehicule").toString()));
                        if (updates.get("puissanceFiscale") != null) o.setPuissanceFiscale(Integer.parseInt(updates.get("puissanceFiscale").toString()));
                        if (updates.get("marque") != null) o.setMarque(updates.get("marque").toString());
                        if (updates.get("modele") != null) o.setModele(updates.get("modele").toString());
                        if (updates.get("immatriculation") != null) o.setImmatriculation(updates.get("immatriculation").toString());
                        
                        // Handle Contract Plan/Formula change
                        if (updates.get("formule") != null) {
                            contrat.setFormule(updates.get("formule").toString());
                            contratRepository.save(contrat);
                        }
                        
                        // HABITATION
                        if (updates.get("valeurBien") != null) o.setValeurBien(Double.parseDouble(updates.get("valeurBien").toString()));
                        if (updates.get("ageBatiment") != null) o.setAgeBatiment(Integer.parseInt(updates.get("ageBatiment").toString()));
                        if (updates.get("niveauSecurite") != null) o.setNiveauSecurite(updates.get("niveauSecurite").toString());
                        if (updates.get("zoneGeo") != null) o.setZoneGeo(updates.get("zoneGeo").toString());
                        
                        // SANTE / VIE
                        if (updates.get("ageAssure") != null) o.setAgeAssure(Integer.parseInt(updates.get("ageAssure").toString()));
                        if (updates.get("antecedentsMedicaux") != null) o.setAntecedentsMedicaux(updates.get("antecedentsMedicaux").toString());
                        if (updates.get("profession") != null) o.setProfession(updates.get("profession").toString());
                        if (updates.get("etatSante") != null) o.setEtatSante(updates.get("etatSante").toString());
                        if (updates.get("capitalAssure") != null) o.setCapitalAssure(Double.parseDouble(updates.get("capitalAssure").toString()));
                        
                        objetAssureRepository.save(o);

                        // 3. Recalculate (using ContratService logic)
                        // Note: addObjetToContrat actually handles recalculation and guarantee regeneration
                        contratService.addObjetToContrat(contrat.getId(), o);
                    }
                } catch (Exception e) {
                    throw new RuntimeException("Erreur lors de l'application de la modification: " + e.getMessage());
                }
            }
        }

        return demandeServiceRepository.save(request);
    }
}
