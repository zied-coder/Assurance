package com.example.demo.controller;

import com.example.demo.model.User;
import com.example.demo.payload.SignupRequest;
import com.example.demo.service.UserService;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    // 🔹 ADMIN + GESTIONNAIRE : voir tous les utilisateurs
    @GetMapping
    @PreAuthorize("hasRole('ADMIN') or hasRole('GESTIONNAIRE')")
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    // 🔹 ADMIN : GET USER PAR ID
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<User> getUser(@PathVariable String id) {
        return ResponseEntity.ok(
                userService.getUserById(id)
                        .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"))
        );
    }

    // 🔥 PROFILE USER CONNECTÉ (JWT)
    @GetMapping("/profile")
    public ResponseEntity<User> getProfile(Authentication authentication) {
        String username = authentication.getName(); // JWT -> username
        User user = userService.getUserByUsername(username);
        return ResponseEntity.ok(user);
    }

    // 🔹 DELETE USER (ADMIN)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return ResponseEntity.ok("Utilisateur supprimé");
    }

    // 🔥 UPDATE USER (ADMIN + USER + GESTIONNAIRE)
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') or hasRole('USER') or hasRole('GESTIONNAIRE')")
    public ResponseEntity<?> updateUser(@PathVariable String id,
                                           @RequestBody SignupRequest update) {
        try {
            User user = userService.updateUser(
                    id,
                    update.getUsername(),
                    update.getEmail(),
                    update.getPhone(),
                    update.getCin(),
                    update.getAddress(),
                    update.getPassword(),
                    update.getOldPassword()
            );
            return ResponseEntity.ok(user);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("{\"message\": \"" + e.getMessage() + "\"}");
        }
    }

}
