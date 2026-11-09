package com.example.demo.controller;

import com.example.demo.dto.ChatRequest;
import com.example.demo.dto.ChatResponse;
import com.example.demo.service.ChatbotService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/chatbot")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatbotController {

    private final ChatbotService chatbotService;

    @PostMapping("/ask")
    public ResponseEntity<ChatResponse> ask(@RequestBody ChatRequest request) {
        String sessionId = request.getSessionId() != null ? request.getSessionId() : "default";
        String response = chatbotService.getResponse(request.getMessage(), sessionId);
        return ResponseEntity.ok(new ChatResponse(response));
    }
}
