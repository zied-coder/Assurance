package com.example.demo.controller;

import com.example.demo.model.DemandeService;
import com.example.demo.service.DemandeServiceService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/demandes-service")
@CrossOrigin("*")
public class DemandeServiceController {

    private final DemandeServiceService demandeServiceService;

    public DemandeServiceController(DemandeServiceService demandeServiceService) {
        this.demandeServiceService = demandeServiceService;
    }

    @PostMapping
    public ResponseEntity<DemandeService> create(@RequestBody DemandeService request) {
        return ResponseEntity.ok(demandeServiceService.createRequest(request));
    }

    @GetMapping("/pending")
    public ResponseEntity<List<DemandeService>> getPending() {
        return ResponseEntity.ok(demandeServiceService.getPendingRequests());
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<DemandeService>> getUserRequests(@PathVariable String userId) {
        return ResponseEntity.ok(demandeServiceService.getUserRequests(userId));
    }

    @PutMapping("/{id}/process")
    public ResponseEntity<DemandeService> process(
            @PathVariable String id,
            @RequestParam String status,
            @RequestParam(required = false) String feedback) {
        return ResponseEntity.ok(demandeServiceService.processRequest(id, status, feedback));
    }
}
