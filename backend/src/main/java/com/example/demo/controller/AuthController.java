package com.example.demo.controller;

import com.example.demo.model.User;
import com.example.demo.payload.LoginRequest;
import com.example.demo.payload.SignupRequest;
import com.example.demo.service.UserService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserService userService;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    // 📝 REGISTER
    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequest request) {
        try {

            User user = userService.createUser(
                    request.getUsername(),
                    request.getEmail(),
                    request.getPassword(),
                    request.getRole(),
                    request.getCin(),
                    request.getPhone(),
                    request.getAddress()
            );

            return ResponseEntity.ok(Map.of(
                    "message", "Utilisateur créé avec succès",
                    "username", user.getUsername(),
                    "roles", user.getRoles()
            ));

        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 🔐 LOGIN
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            String token = userService.authenticateUser(
                    request.getUsername(),
                    request.getPassword()
            );

            return ResponseEntity.ok(Map.of("token", token));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // 👤 PROFILE (AJOUTÉ)
    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {

        String username = authentication.getName();

        User user = userService.getUserByUsername(username);

        return ResponseEntity.ok(user);
    }
}
