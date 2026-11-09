package com.example.demo.controller;

import com.example.demo.model.ObjetAssure;
import com.example.demo.repository.ObjetAssureRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/objets")
@CrossOrigin("*")
public class ObjetAssureController {

    private final ObjetAssureRepository repo;

    public ObjetAssureController(ObjetAssureRepository repo) {
        this.repo = repo;
    }

    // créer objet assuré
    @PostMapping
    public ObjetAssure create(@RequestBody ObjetAssure obj) {
        return repo.save(obj);
    }

    // voir objets d’un contrat
    @GetMapping("/contrat/{id}")
    public List<ObjetAssure> getByContrat(@PathVariable String id) {
        return repo.findByContratId(id);
    }
}
