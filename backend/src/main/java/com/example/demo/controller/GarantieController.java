package com.example.demo.controller;

import com.example.demo.model.Garantie;
import com.example.demo.repository.GarantieRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/garanties")
@CrossOrigin("*")
public class GarantieController {

    private final GarantieRepository repo;

    public GarantieController(GarantieRepository repo) {
        this.repo = repo;
    }

    // 1. créer garantie
    @PostMapping
    public Garantie create(@RequestBody Garantie g) {
        return repo.save(g);
    }

    // 2. voir toutes les garanties
    @GetMapping
    public List<Garantie> getAll() {
        return repo.findAll();
    }
}
