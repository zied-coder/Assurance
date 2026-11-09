package com.example.demo.controller;

import com.example.demo.model.Contrat;
import com.example.demo.model.ObjetAssure;
import com.example.demo.service.ContratService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.Authentication;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/contrats")
@CrossOrigin(origins = "*")
public class ContratController {

    private final ContratService contratService;

    public ContratController(ContratService contratService) {
        this.contratService = contratService;
    }

    // ================= CREATE AVEC CIN =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PostMapping("/create/{cin}")
    public ResponseEntity<Contrat> create(
            @RequestBody Contrat contrat,
            @PathVariable String cin) {

        return ResponseEntity.ok(
                contratService.createContratWithCin(contrat, cin)
        );
    }

    // ================= ADD OBJET =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PostMapping("/{id}/objet")
    public ObjetAssure addObjet(@PathVariable String id,
                                @RequestBody ObjetAssure objet) {
        return contratService.addObjetToContrat(id, objet);
    }

    // ================= GET ALL =================
    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @GetMapping
    public List<Contrat> getAll() {
        return contratService.getAllContrats();
    }

    // ================= USER CONTRACTS =================
    @PreAuthorize("hasRole('USER')")
    @GetMapping("/my")
    public List<Contrat> getMyContrats(Authentication auth) {
        return contratService.getContratsByUser(auth.getName());
    }
    @PreAuthorize("hasAnyRole('GESTIONNAIRE')")
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteContrat(@PathVariable String id) {

        contratService.deleteContrat(id);

        return ResponseEntity.ok("Contrat supprimé avec succès");
    }

    // ================= FULL DETAILS =================
    @GetMapping("/full/{id}")
    public Map<String, Object> getFull(@PathVariable String id) {
        return contratService.getContratFull(id);
    }

    // ================= PAY CONTRACT =================
    @PreAuthorize("hasRole('USER')")
    @PostMapping("/{id}/pay")
    public ResponseEntity<Contrat> payContrat(@PathVariable String id, @RequestBody Map<String, String> paymentDetails) {
        return ResponseEntity.ok(contratService.payContrat(id, paymentDetails));
    }

    // ================= RECEIPT =================
    @GetMapping("/receipt/{id}")
    public ResponseEntity<byte[]> downloadReceipt(@PathVariable String id) {
        byte[] pdf = contratService.generateReceiptPdf(id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=recu_paiement_" + id + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    // ================= PDF CORRIGÉ =================
    @GetMapping("/pdf/{id}")
    public ResponseEntity<byte[]> downloadPdf(@PathVariable String id) {

        byte[] pdf = contratService.generatePdf(id);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=contrat_" + id + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }
}
