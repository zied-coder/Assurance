package com.example.demo.config;

import com.example.demo.model.ERole;
import com.example.demo.model.Role;
import com.example.demo.repository.RoleRepository;
import com.example.demo.repository.UserRepository;
import com.example.demo.model.User;
import com.example.demo.model.Sinistre;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import com.example.demo.repository.SinistreRepository;
import com.example.demo.repository.ContratRepository;
import com.example.demo.repository.ReclamationRepository;
import com.example.demo.model.Contrat;
import com.example.demo.model.Reclamation;
import com.example.demo.service.GeocodingService;
import java.util.Set;
import java.util.List;
import java.util.Date;
import java.util.concurrent.atomic.AtomicInteger;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initRoles(RoleRepository roleRepository, UserRepository userRepository, 
                                SinistreRepository sinistreRepository, ContratRepository contratRepository,
                                ReclamationRepository reclamationRepository,
                                GeocodingService geocodingService, PasswordEncoder passwordEncoder) {
        return args -> {
            // ... (roles init)
            for (ERole name : ERole.values()) {
                if (!roleRepository.findByName(name).isPresent()) {
                    Role role = new Role();
                    role.setName(name);
                    roleRepository.save(role);
                    System.out.println("✅ Role initialized: " + name);
                }
            }

            // ... (admin init)
            if (!userRepository.existsByUsername("admin")) {
                User admin = new User();
                admin.setUsername("admin");
                admin.setEmail("admin@bna.tn");
                admin.setPassword(passwordEncoder.encode("admin123"));
                Role adminRole = roleRepository.findByName(ERole.ROLE_ADMIN).get();
                admin.setRoles(Set.of(adminRole));
                userRepository.save(admin);
                System.out.println("✅ Default ADMIN created: admin / admin123");
            }

            // ... (user init)
            if (!userRepository.existsByUsername("user")) {
                User user = new User();
                user.setUsername("user");
                user.setEmail("user@bna.tn");
                user.setPassword(passwordEncoder.encode("user123"));
                user.setCin("00000001");
                Role userRole = roleRepository.findByName(ERole.ROLE_USER).get();
                user.setRoles(Set.of(userRole));
                userRepository.save(user);
                System.out.println("✅ Default USER created: user / user123");
            }

            // ... (manager init)
            if (!userRepository.existsByUsername("manager")) {
                User manager = new User();
                manager.setUsername("manager");
                manager.setEmail("manager@bna.tn");
                manager.setPassword(passwordEncoder.encode("manager123"));
                manager.setCin("00000002");
                Role managerRole = roleRepository.findByName(ERole.ROLE_GESTIONNAIRE).get();
                manager.setRoles(Set.of(managerRole));
                userRepository.save(manager);
                System.out.println("✅ Default MANAGER created: manager / manager123");
            }

            // 🔥 FIX EXISTING SINISTRES (Addresses, CIN & Dates)
            System.out.println("🔍 Checking for claims needing data fixes (Addresses, CIN & Dates)...");
            List<Sinistre> allSinistres = sinistreRepository.findAll();
            AtomicInteger fixedAddresses = new AtomicInteger(0);
            AtomicInteger fixedCin = new AtomicInteger(0);
            AtomicInteger fixedDates = new AtomicInteger(0);
            
            for (Sinistre s : allSinistres) {
                // 1. Fix addresses
                String val = s.getAdresse();
                if (val != null && val.matches("^-?\\d+[.,]\\d+,\\s*-?\\d+[.,]\\d+$")) {
                    String[] rawParts = val.split(",");
                    try {
                        Double lat = Double.parseDouble(rawParts[0].trim().replace(",", "."));
                        Double lng = Double.parseDouble(rawParts[1].trim().replace(",", "."));
                        
                        String address = geocodingService.getAddressFromCoordinates(lat, lng);
                        if (address != null) {
                            s.setAdresse(address);
                            fixedAddresses.incrementAndGet();
                        }
                    } catch (Exception e) {}
                }
                
                // 2. Fix missing CIN
                if (s.getUserCin() == null || s.getUserCin().isEmpty()) {
                    if (s.getUserId() != null) {
                        userRepository.findById(s.getUserId()).ifPresent(u -> {
                            if (u.getCin() != null) {
                                s.setUserCin(u.getCin());
                                fixedCin.incrementAndGet();
                            }
                        });
                    }
                }

                // 3. Fix missing incidentDate & declarationDate
                boolean dateFixed = false;
                if (s.getIncidentDate() == null) {
                    s.setIncidentDate(s.getDate() != null ? s.getDate() : new Date());
                    dateFixed = true;
                }
                if (s.getDeclarationDate() == null) {
                    s.setDeclarationDate(s.getDate() != null ? s.getDate() : new Date());
                    dateFixed = true;
                }
                if (dateFixed) {
                    s.setDate(s.getIncidentDate());
                    fixedDates.incrementAndGet();
                }
                
                sinistreRepository.save(s);
            }
            if (fixedAddresses.get() > 0) System.out.println("✅ Migrated " + fixedAddresses.get() + " coordinates to addresses.");
            if (fixedCin.get() > 0) System.out.println("✅ Fixed " + fixedCin.get() + " claims with missing CIN.");
            if (fixedDates.get() > 0) System.out.println("✅ Initialized incident/declaration dates for " + fixedDates.get() + " claims.");

            // 🔥 FIX EXISTING CONTRATS (CIN, Payment status & Date)
            List<Contrat> allContrats = contratRepository.findAll();
            AtomicInteger fixedContratCin = new AtomicInteger(0);
            AtomicInteger fixedContratPayment = new AtomicInteger(0);
            for (Contrat c : allContrats) {
                boolean modified = false;
                if (c.getCin() == null || c.getCin().isEmpty()) {
                    if (c.getUserId() != null) {
                        User u = userRepository.findById(c.getUserId()).orElse(null);
                        if (u != null && u.getCin() != null) {
                            c.setCin(u.getCin());
                            fixedContratCin.incrementAndGet();
                            modified = true;
                        }
                    }
                }
                if (c.getEtatPaiement() == null || c.getEtatPaiement().isEmpty()) {
                    c.setEtatPaiement("EN_ATTENTE");
                    modified = true;
                }
                if (c.getDateProchainPaiement() == null) {
                    Date refDate = c.getCreatedAt() != null ? c.getCreatedAt() : new Date();
                    c.setDateProchainPaiement(new Date(refDate.getTime() + 365L * 24 * 60 * 60 * 1000));
                    modified = true;
                }
                if (modified) {
                    contratRepository.save(c);
                    fixedContratPayment.incrementAndGet();
                }
            }
            if (fixedContratCin.get() > 0) System.out.println("✅ Fixed " + fixedContratCin.get() + " contracts with missing CIN.");
            if (fixedContratPayment.get() > 0) System.out.println("✅ Initialized payment info for " + fixedContratPayment.get() + " contracts.");

            // 🔥 FIX EXISTING RECLAMATIONS (CIN)
            List<Reclamation> allReclamations = reclamationRepository.findAll();
            AtomicInteger fixedReclCin = new AtomicInteger(0);
            for (Reclamation r : allReclamations) {
                if (r.getUserCin() == null || r.getUserCin().isEmpty()) {
                    if (r.getUserId() != null) {
                        userRepository.findById(r.getUserId()).ifPresent(u -> {
                            if (u.getCin() != null) {
                                r.setUserCin(u.getCin());
                                fixedReclCin.incrementAndGet();
                                reclamationRepository.save(r);
                            }
                        });
                    }
                }
            }
            if (fixedReclCin.get() > 0) System.out.println("✅ Fixed " + fixedReclCin.get() + " reclamations with missing CIN.");
        };
    }
}
