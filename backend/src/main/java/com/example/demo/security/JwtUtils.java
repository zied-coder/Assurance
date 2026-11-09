package com.example.demo.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtils {

    private static final String SECRET = "monSecretUltraSecretttttPourJwt1234567890!@#$%^&*()";
    private static final long EXPIRATION_MS = 3600000;
    private static final Key key = Keys.hmacShaKeyFor(SECRET.getBytes());

    // Génération du token
    public String generateJwtToken(Authentication authentication) {
        String username = authentication.getName();

        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(new Date().getTime() + EXPIRATION_MS))
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    // Lire username depuis token
    public String getUsernameFromJwt(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    // Validation token
    public boolean validateJwtToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            System.out.println("Token invalide: " + e.getMessage());
        }
        return false;
    }
}