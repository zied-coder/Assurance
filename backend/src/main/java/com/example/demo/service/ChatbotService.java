package com.example.demo.service;

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ChatbotService {

    private final OpenAIService openAIService;

    
    // Memory store: sessionId -> list of conversation turns
    private final Map<String, List<Map<String, String>>> chatHistory = new ConcurrentHashMap<>();

    // Constructor for dependency injection
    public ChatbotService(OpenAIService openAIService) {
        this.openAIService = openAIService;
    }

    public String getResponse(String message, String sessionId) {
        
        List<Map<String, String>> history = chatHistory.getOrDefault(sessionId, new ArrayList<>());
        
        // Add User Message
        Map<String, String> userTurn = new HashMap<>();
        userTurn.put("role", "user");
        userTurn.put("text", message);
        history.add(userTurn);
        
        // Context window management
        if (history.size() > 10) {
            int start = history.size() - 10;
            if (history.get(start).get("role").equals("assistant")) {
                start++;
            }
            history = new ArrayList<>(history.subList(start, history.size()));
        }

        String aiResponse = null;

        // LAYER 1: Try LLM
        try {
            aiResponse = openAIService.generateResponse(history);
            if (isError(aiResponse)) {
                aiResponse = null; // Trigger fallback
            }
        } catch (Exception e) {
            System.err.println("LLM failed: " + e.getMessage());
        }

        // Ensure a response is always provided
        if (aiResponse == null) {
            aiResponse = "Désolé, une erreur s'est produite lors du traitement de votre demande.";
        }

        // Add Final Response to History
        Map<String, String> assistantTurn = new HashMap<>();
        assistantTurn.put("role", "assistant");
        assistantTurn.put("text", aiResponse);
        history.add(assistantTurn);
        
        chatHistory.put(sessionId, history);

        return aiResponse;
    }

    private boolean isError(String response) {
        if (response == null) return true;
        String lower = response.toLowerCase();
        return lower.contains("quota atteint") || 
               lower.contains("difficulté technique") || 
               lower.contains("erreur d'authentification") ||
               lower.contains("perturbation technique") ||
               lower.contains("erreur de communication") ||
               lower.contains("invalide ou expirée");
    }
}