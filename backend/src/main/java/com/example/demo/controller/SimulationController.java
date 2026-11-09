package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.service.SimulationService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/simulation")
@CrossOrigin("*")
public class SimulationController {

    private final SimulationService service;

    public SimulationController(SimulationService service) {
        this.service = service;
    }

    @PostMapping("/calcul")
    public SimulationResponse calcul(@RequestBody SimulationRequest req) {
        return service.simuler(req);
    }
}
