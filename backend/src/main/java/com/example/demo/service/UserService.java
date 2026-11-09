package com.example.demo.service;

import com.example.demo.model.ERole;
import com.example.demo.model.Role;
import com.example.demo.model.User;
import com.example.demo.repository.RoleRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.security.JwtUtils;
import com.example.demo.payload.PasswordChangeRequest;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;

    public UserService(UserRepository userRepository,
                       RoleRepository roleRepository,
                       PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager,
                       JwtUtils jwtUtils) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtUtils = jwtUtils;
    }

    // ---------------- SIGNUP ----------------
    public User createUser(String username, String email, String password, String roleStr, String cin, String phone, String address) {

        // ✅ Determine role first (used for validation logic below)
        ERole roleEnum;
        if ("ROLE_ADMIN".equalsIgnoreCase(roleStr)) {
            roleEnum = ERole.ROLE_ADMIN;
        } else if ("ROLE_GESTIONNAIRE".equalsIgnoreCase(roleStr)) {
            roleEnum = ERole.ROLE_GESTIONNAIRE;
        } else {
            roleEnum = ERole.ROLE_USER;
        }

        // 1. Validate required base fields
        if (username == null || username.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            throw new RuntimeException("Tous les champs obligatoires doivent être remplis");
        }

        // 2. Role-specific required fields
        if (roleEnum == ERole.ROLE_GESTIONNAIRE) {
            if (cin == null || cin.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {
                throw new RuntimeException("Les champs CIN et Adresse sont obligatoires");
            }
        } else if (roleEnum == ERole.ROLE_USER) {
            if (cin == null || cin.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                address == null || address.trim().isEmpty()) {
                throw new RuntimeException("Tous les champs (CIN, Téléphone, Adresse) sont obligatoires");
            }
        }

        // 4. Email uniqueness — global for both managers and clients
        if (userRepository.existsByEmail(email.trim())) {
            throw new RuntimeException("Cet email est déjà utilisé");
        }

        // 5. CIN uniqueness — global for both managers and clients
        if (cin != null && !cin.trim().isEmpty()) {
            if (userRepository.findByCin(cin.trim()).isPresent()) {
                throw new RuntimeException("Ce CIN est déjà utilisé");
            }
        }

        // 6. Build and save user
        User user = new User();
        user.setUsername(username.trim());
        user.setEmail(email.trim());
        user.setPassword(passwordEncoder.encode(password));
        if (cin != null) user.setCin(cin.trim());
        if (phone != null) user.setPhone(phone.trim());
        if (address != null) user.setAddress(address.trim());

        Role role = roleRepository.findByName(roleEnum)
                .orElseThrow(() -> new RuntimeException("Role non trouvé"));
        user.setRoles(Set.of(role));

        return userRepository.save(user);
    }

    // ---------------- LOGIN ----------------
    public String authenticateUser(String username, String password) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(username, password)
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);
            return jwtUtils.generateJwtToken(authentication);
        } catch (Exception e) {
            System.err.println("❌ Auth Failure for " + username + ": " + e.getMessage());
            throw new RuntimeException("Username ou password incorrect");
        }
    }

    // ---------------- GET USER BY USERNAME ----------------
    public User getUserByUsername(String username) {
        return userRepository.findFirstByUsername(username)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé: " + username));
    }

    // ---------------- USERS CRUD ----------------
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public Optional<User> getUserById(String id) {
        return userRepository.findById(id);
    }

    public void deleteUser(String id) {
        userRepository.deleteById(id);
    }

    public User updateUser(String id, String username, String email, String phone, String cin, String address, String newPassword, String oldPassword) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (username != null) user.setUsername(username);
        if (email != null) user.setEmail(email);
        if (phone != null) user.setPhone(phone);
        if (cin != null) user.setCin(cin);
        if (address != null) user.setAddress(address);

        if (newPassword != null && !newPassword.trim().isEmpty()) {
            if (oldPassword == null || oldPassword.isEmpty()) {
                // Bypass for admin-initiated password reset
                user.setPassword(passwordEncoder.encode(newPassword));
            } else {
                if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
                    throw new RuntimeException("Ancien mot de passe incorrect");
                }
                user.setPassword(passwordEncoder.encode(newPassword));
            }
        }

        return userRepository.save(user);
    }

    // ---------------- PROFILE UPDATE ----------------
    // Fails only if ALL updatable fields are empty/null (at least one must be filled)
    public User updateProfile(String username, User updatedUser) {
        User user = userRepository.findFirstByUsername(username)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        boolean allEmpty =
            (updatedUser.getUsername() == null || updatedUser.getUsername().trim().isEmpty()) &&
            (updatedUser.getEmail()    == null || updatedUser.getEmail().trim().isEmpty())    &&
            (updatedUser.getPhone()    == null || updatedUser.getPhone().trim().isEmpty())    &&
            (updatedUser.getCin()      == null || updatedUser.getCin().trim().isEmpty());

        if (allEmpty) {
            throw new RuntimeException("Au moins un champ doit être renseigné pour mettre à jour le profil");
        }

        if (updatedUser.getUsername() != null && !updatedUser.getUsername().trim().isEmpty())
            user.setUsername(updatedUser.getUsername().trim());
        if (updatedUser.getEmail() != null && !updatedUser.getEmail().trim().isEmpty())
            user.setEmail(updatedUser.getEmail().trim());
        if (updatedUser.getPhone() != null && !updatedUser.getPhone().trim().isEmpty())
            user.setPhone(updatedUser.getPhone().trim());
        if (updatedUser.getCin() != null && !updatedUser.getCin().trim().isEmpty())
            user.setCin(updatedUser.getCin().trim());

        return userRepository.save(user);
    }

    // ---------------- CHANGE PASSWORD ----------------
    public void changePassword(String username, PasswordChangeRequest request) {
        User user = userRepository.findFirstByUsername(username)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("Ancien mot de passe incorrect");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public User save(User user) {
        return userRepository.save(user);
    }

    // ---------------- HELPER ----------------
    private boolean hasRole(User user, ERole roleName) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream().anyMatch(r -> roleName.equals(r.getName()));
    }
}