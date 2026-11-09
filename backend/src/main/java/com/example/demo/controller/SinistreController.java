package com.example.demo.controller;

import com.example.demo.model.Sinistre;
import com.example.demo.model.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.SinistreService;
import com.example.demo.service.GeocodingService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Date;
import java.util.List;

import com.example.demo.repository.ContratRepository;
import com.example.demo.model.Contrat;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/sinistres")
@CrossOrigin(origins = "*")
public class SinistreController {

    @Value("${google.maps.api.key}")
    private String googleMapsKey;

    @Autowired
    private ContratRepository contratRepository;

    @Autowired
    private SinistreService sinistreService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GeocodingService geocodingService;

    private final String UPLOAD_DIR = "uploads/";

    // ================= CREATE =================
    @PostMapping("/upload")
    public Sinistre createSinistre(
            @RequestParam("titre") String titre,
            @RequestParam("description") String description,
            @RequestParam("adresse") String adresse,
            @RequestParam("contratId") String contratIdOrNumero,
            @RequestParam(value = "incidentDate", required = false) @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd") Date incidentDate,
            @RequestParam(value = "latitude", required = false) Double latitude,
            @RequestParam(value = "longitude", required = false) Double longitude,
            Authentication authentication,
            @RequestParam(value = "file", required = false) MultipartFile file
    ) throws IOException {

        String username = authentication.getName();
        String resolvedContratId = contratIdOrNumero;

        // 🔥 Support CNT-XXXX-XXXX format
        if (contratIdOrNumero != null && contratIdOrNumero.startsWith("CNT-")) {
            Contrat c = contratRepository.findByNumero(contratIdOrNumero)
                    .orElseThrow(() -> new RuntimeException("Contrat introuvable: " + contratIdOrNumero));
            resolvedContratId = c.getId();
        }

        // ✅ FIX IMPORTANT
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        Sinistre s = new Sinistre();
        // 🔥 BACKEND GEOCODING FALLBACK
        String finalAdresse = adresse;
        if (latitude != null && longitude != null && (adresse == null || adresse.isEmpty() || adresse.contains(","))) {
            String resolvedAddress = geocodingService.getAddressFromCoordinates(latitude, longitude);
            if (resolvedAddress != null) {
                finalAdresse = resolvedAddress;
            }
        }

        s.setTitre(titre);
        s.setDescription(description);
        s.setAdresse(finalAdresse);
        s.setLatitude(latitude);
        s.setLongitude(longitude);
        s.setContratId(resolvedContratId);
        s.setIncidentDate(incidentDate != null ? incidentDate : new Date());
        s.setDeclarationDate(new Date());
        s.setDate(s.getIncidentDate());

        // 🔥 IMPORTANT FIX ICI
        s.setUserId(user.getId());
        s.setUserEmail(user.getEmail());
        s.setUserCin(user.getCin());

        s.setStatut("EN_ATTENTE");
        s.setCommentaire("");

        // FILE
        if (file != null && !file.isEmpty()) {
            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = Paths.get(UPLOAD_DIR + fileName);

            Files.createDirectories(path.getParent());
            Files.write(path, file.getBytes());

            s.setDocument(fileName);
        }

        return sinistreService.create(s);
    }

    // ================= USER SINISTRES =================
    @GetMapping("/user")
    public List<Sinistre> getUserSinistres(Authentication authentication) {

        String username = authentication.getName();

        // ✅ FIX IMPORTANT
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return sinistreService.getByUser(user.getId());
    }

    // ================= EN COURS =================
    @GetMapping("/user/en-cours")
    public List<Sinistre> getUserEnCours(Authentication authentication) {

        String username = authentication.getName();

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return sinistreService.getByUserEnCours(user.getId());
    }

    // ================= DETAIL =================
    @PreAuthorize("hasRole('USER') or hasRole('GESTIONNAIRE')")
    @GetMapping("/{id}")
    public Sinistre getById(@PathVariable String id) {
        return sinistreService.getSinistreById(id);
    }

    // ================= ALL =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @GetMapping
    public List<Sinistre> getAll() {
        return sinistreService.getAll();
    }

    // ================= UPDATE STATUS (Workflow Initial) =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PutMapping("/{id}/status")
    public Sinistre updateStatus(
            @PathVariable String id,
            @RequestParam String statut,
            @RequestParam(required = false) String commentaire
    ) {
        return sinistreService.updateStatus(id, statut, commentaire);
    }

    // ================= DEMANDE INFO =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PutMapping("/{id}/demander-info")
    public Sinistre demanderInfo(@PathVariable String id, @RequestParam String commentaire) {
        return sinistreService.demanderInfo(id, commentaire);
    }

    // ================= ASSIGN EXPERT =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PutMapping("/{id}/assigner-expert")
    public Sinistre assignExpert(
            @PathVariable String id,
            @RequestParam String expertNom,
            @RequestParam String expertTelephone,
            @RequestParam String expertRendezVous
    ) {
        return sinistreService.assignExpert(id, expertNom, expertTelephone, expertRendezVous);
    }

    // ================= RAPPORT EXPERT =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PutMapping("/{id}/rapport-expert")
    public Sinistre submitExpertReport(@PathVariable String id, @RequestParam String rapportExpert) {
        return sinistreService.submitExpertReport(id, rapportExpert);
    }

    // ================= DECISION FINALE =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PutMapping("/{id}/decision-finale")
    public Sinistre finalDecision(
            @PathVariable String id,
            @RequestParam String statut,
            @RequestParam String commentaire
    ) {
        return sinistreService.finalDecision(id, statut, commentaire);
    }

    // ================= COMPLETE =================
    @PreAuthorize("hasRole('USER')")
    @PutMapping("/completer/{id}")
    public Sinistre completerSinistre(
            @PathVariable String id,
            @RequestParam(required = false) String titre,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String adresse,
            @RequestParam(required = false) @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd") Date incidentDate,
            @RequestParam(required = false) MultipartFile file
    ) throws IOException {

        Sinistre s = sinistreService.getSinistreById(id);

        if (titre != null) s.setTitre(titre);
        if (description != null) s.setDescription(description);
        if (adresse != null) s.setAdresse(adresse);
        if (incidentDate != null) {
            s.setIncidentDate(incidentDate);
            s.setDate(incidentDate);
        }

        if (file != null && !file.isEmpty()) {
            String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = Paths.get(UPLOAD_DIR + fileName);

            Files.createDirectories(path.getParent());
            Files.write(path, file.getBytes());

            s.setDocument(fileName);
        }

        s.setStatut("EN_ATTENTE");
        s.setCommentaire("");

        return sinistreService.updateSinistre(id, s);
    }

    // ================= DELETE =================
    @PreAuthorize("hasRole('GESTIONNAIRE') or hasRole('USER')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        sinistreService.deleteSinistre(id);
    }

    // ================= CONFIG =================
    @GetMapping("/config/map-key")
    public ResponseEntity<?> getMapKey() {
        Map<String, String> config = new HashMap<>();
        config.put("key", googleMapsKey);
        return ResponseEntity.ok(config);
    }
}
