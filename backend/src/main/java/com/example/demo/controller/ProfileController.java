package com.example.demo.controller;

import com.example.demo.model.User;
import com.example.demo.payload.PasswordChangeRequest;
import com.example.demo.service.UserService;
import com.example.demo.security.services.UserDetailsImpl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/profile")
public class ProfileController {

    @Autowired
    private UserService userService;

    // 👤 GET PROFILE
    @GetMapping
    public ResponseEntity<User> getProfile(@AuthenticationPrincipal UserDetailsImpl userDetails) {

        String username = userDetails.getUsername();

        User user = userService.getUserByUsername(username);

        return ResponseEntity.ok(user);
    }

    // ✏️ UPDATE PROFILE
    @PutMapping
    public ResponseEntity<?> updateProfile(@AuthenticationPrincipal UserDetailsImpl userDetails,
                                           @RequestBody User updatedUser) {
        try {
            String username = userDetails.getUsername();
            User savedUser = userService.updateProfile(username, updatedUser);
            return ResponseEntity.ok(savedUser);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body("{\"message\": \"" + e.getMessage() + "\"}");
        }
    }

    // 🔐 CHANGE PASSWORD
    @PutMapping("/password")
    public ResponseEntity<String> changePassword(@AuthenticationPrincipal UserDetailsImpl userDetails,
                                                 @RequestBody PasswordChangeRequest request) {

        String username = userDetails.getUsername();

        userService.changePassword(username, request);

        return ResponseEntity.ok("Mot de passe modifié avec succès");
    }
}
