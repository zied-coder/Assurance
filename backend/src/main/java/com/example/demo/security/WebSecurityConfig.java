package com.example.demo.security;

import com.example.demo.security.services.UserDetailsServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableMethodSecurity
public class WebSecurityConfig {

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtAuthFilter jwtAuthFilter;

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder);
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .csrf(csrf -> csrf.disable())

                .authorizeHttpRequests(auth -> auth

                        // ================= PUBLIC =================
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/uploads/**").permitAll()
                        .requestMatchers("/api/simulation/**").permitAll()
                        .requestMatchers("/api/chatbot/**").permitAll()

                        // ================= USERS =================
                        .requestMatchers("/api/users/profile").authenticated()
                        .requestMatchers("/api/users/**").authenticated()
                        // ================= CONTRATS (🔥 FIX IMPORTANT) =================
                        .requestMatchers("/api/contrats/**")
                        .hasAnyRole("USER", "GESTIONNAIRE")
                        // ================= SINISTRES =================
                        .requestMatchers("/api/sinistres/upload").hasAnyRole("USER", "GESTIONNAIRE")
                        .requestMatchers("/api/sinistres/user/**").hasAnyRole("USER", "GESTIONNAIRE")
                        .requestMatchers("/api/sinistres/**").hasAnyRole("USER", "GESTIONNAIRE")

                        // ================= RECLAMATIONS (FIX 403) =================
                        .requestMatchers("/api/reclamations/**")
                        .hasAnyRole("USER", "GESTIONNAIRE")

                        // fallback
                        .anyRequest().authenticated()
                )

                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
                .authenticationProvider(authenticationProvider()) // 🔥 FORCE PROVIDER
                .formLogin(form -> form.disable())
                .httpBasic(httpBasic -> httpBasic.disable());

        return http.build();
    }
}