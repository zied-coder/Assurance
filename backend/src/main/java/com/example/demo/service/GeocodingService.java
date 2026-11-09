package com.example.demo.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class GeocodingService {

    @Value("${google.maps.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public String getAddressFromCoordinates(Double latitude, Double longitude) {
        if (latitude == null || longitude == null) return null;

        try {
            String url = String.format(
                java.util.Locale.US,
                "https://maps.googleapis.com/maps/api/geocode/json?latlng=%.6f,%.6f&key=%s",
                latitude, longitude, apiKey
            );

            String response = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);

            if ("OK".equals(root.path("status").asText())) {
                JsonNode results = root.path("results");
                if (results.isArray() && results.size() > 0) {
                    // Chercher un résultat de type 'locality' pour avoir "Morneg" ou "Ezzahra"
                    for (JsonNode result : results) {
                        JsonNode types = result.path("types");
                        for (JsonNode type : types) {
                            String typeStr = type.asText();
                            if ("locality".equals(typeStr) || "sublocality".equals(typeStr) || "administrative_area_level_2".equals(typeStr)) {
                                return result.path("formatted_address").asText();
                            }
                        }
                    }
                    // Fallback sur le premier résultat
                    return results.get(0).path("formatted_address").asText();
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Error during backend geocoding: " + e.getMessage());
        }

        return String.format("%.6f, %.6f", latitude, longitude);
    }
}
