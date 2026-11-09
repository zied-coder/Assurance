package com.example.demo.controller;

import com.example.demo.model.Reclamation;
import com.example.demo.model.Sinistre;
import com.example.demo.model.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.ReclamationService;
import com.example.demo.service.SinistreService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/reclamations")
public class ReclamationController {

    @Autowired
    private ReclamationService service;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SinistreService sinistreService;

    // ================= CLIENT =================

    @PreAuthorize("hasRole('USER')")
    @PostMapping
    public Reclamation create(@RequestBody Reclamation r, Authentication authentication) {
        String username = authentication.getName();
        
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        r.setUserId(user.getId());
        r.setUserEmail(user.getEmail());
        r.setUserCin(user.getCin());

        // Verification du lien avec le sinistre
        if (r.getSinistreId() != null) {
            Sinistre s = sinistreService.getSinistreById(r.getSinistreId());
            r.setSinistreNumero(s.getNumero());
        }

        return service.create(r);
    }

    @PreAuthorize("hasRole('USER')")
    @GetMapping("/user")
    public List<Reclamation> getByUser(Authentication authentication) {
        String username = authentication.getName();
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return service.getByUser(user.getId());
    }

    // ================= GESTIONNAIRE =================

    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @GetMapping
    public List<Reclamation> getAll() {
        return service.getAll();
    }

    @PreAuthorize("hasRole('GESTIONNAIRE') or hasRole('USER')")
    @GetMapping("/{id}")
    public Reclamation getById(@PathVariable String id) {
        return service.getById(id);
    }

    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @PutMapping("/{id}/status")
    public Reclamation updateStatus(
            @PathVariable String id, 
            @RequestParam String statut, 
            @RequestParam(required = false) String reponse) {
        return service.updateStatus(id, statut, reponse);
    }

    @PreAuthorize("hasRole('GESTIONNAIRE')")
    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        service.delete(id);
    }
}
