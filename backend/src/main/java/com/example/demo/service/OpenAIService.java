package com.example.demo.service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.ConnectException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpConnectTimeoutException;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.channels.UnresolvedAddressException;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Service
public class OpenAIService {

    private static final Logger log = LoggerFactory.getLogger(OpenAIService.class);

    // Clé Groq : lue depuis GROQ_API_KEY, ou à défaut OPENAI_API_KEY
    // (application.properties ou variable d'environnement). Jamais écrite en dur dans le code.
    @Value("${GROQ_API_KEY:${OPENAI_API_KEY:}}")
    private String apiKey;

    @Value("${llm.base.url:https://api.groq.com/openai/v1}")
    private String baseUrl;

    @Value("${llm.model:openai/gpt-oss-120b}")
    private String model;

    // Client réutilisable (thread-safe) : inutile d'en recréer un à chaque requête
    private final HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    private static final String SYSTEM_PROMPT = """
            You are an intelligent virtual assistant for an insurance platform (BNA Assurance).

            Your role is to assist users ONLY with insurance-related services available in the application.

            You must strictly limit your responses to the following topics:
            - Claims (reporting a claim, tracking claim status)
            - Contracts (viewing and understanding insurance contracts)
            - Complaints (submitting and tracking complaints)
            - Quotes / Simulation (insurance pricing simulation)
            - User account and profile related to the insurance system

            Rules:
            - Do NOT answer questions outside the insurance domain.
            - If a user asks something unrelated, respond politely:
              "I'm sorry, I can only assist with insurance-related services such as claims, contracts, complaints, and quote simulations."
            - Reply in the same language as the user (French, English or Arabic).
            - Provide clear, simple, and professional answers.
            - Guide the user step-by-step when needed (e.g., how to declare a claim).
            - Use a helpful and professional tone, similar to a real insurance company assistant.
            - Prefer short and structured answers (not too long).

            Context:
            The application includes features such as:
            - Declaring a claim
            - Viewing contracts
            - Submitting complaints
            - Chatbot assistance
            - Insurance quote simulation

            Your goal is to improve user experience and help them navigate the platform efficiently.
            """;

    public String generateResponse(List<Map<String, String>> history) {
        String key = cleanKey();
        if (key.isEmpty() || key.equals("YOUR_LLM_API_KEY")) {
            log.error("Clé API manquante : définissez GROQ_API_KEY (ou OPENAI_API_KEY).");
            return "Désolé, mais la clé API LLM n'est pas configurée correctement.";
        }

        String endpoint = buildEndpoint();

        try {
            JSONObject payload = new JSONObject();
            payload.put("model", model.trim());
            payload.put("temperature", 0.7);
            payload.put("max_tokens", 2000); // marge pour le raisonnement interne des modèles gpt-oss

            JSONArray messages = new JSONArray();
            messages.put(new JSONObject().put("role", "system").put("content", SYSTEM_PROMPT));

            if (history != null) {
                for (Map<String, String> turn : history) {
                    String text = turn.get("text");

                    // Ignorer les tours contenant des erreurs techniques pour ne pas polluer le contexte
                    if (text == null || text.isBlank()
                            || text.contains("difficulté technique")
                            || text.contains("erreur de communication")) {
                        continue;
                    }

                    messages.put(new JSONObject()
                            .put("role", normalizeRole(turn.get("role")))
                            .put("content", text));
                }
            }
            payload.put("messages", messages);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(endpoint))
                    .timeout(Duration.ofSeconds(60))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + key)
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString()))
                    .build();

            log.info("Appel LLM : {} (modèle : {})", endpoint, model);

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                JSONObject json = new JSONObject(response.body());
                JSONArray choices = json.optJSONArray("choices");
                if (choices != null && choices.length() > 0) {
                    String content = choices.getJSONObject(0)
                            .getJSONObject("message")
                            .optString("content", "");
                    if (!content.isBlank()) {
                        return content;
                    }
                }
                return "Je n'ai pas reçu de réponse valide de mon moteur d'intelligence.";
            }

            // Erreur HTTP : on logge le détail pour le développeur (jamais la clé)
            log.error("Erreur API LLM - statut {} - corps : {}", response.statusCode(), response.body());

            return switch (response.statusCode()) {
                case 401 -> "Erreur d'authentification : Votre clé API LLM semble invalide.";
                case 429 -> "Le service est actuellement surchargé (Quota atteint). Veuillez réessayer dans un instant.";
                default -> "Je rencontre une difficulté technique avec mon moteur d'analyse (Code "
                        + response.statusCode() + ").";
            };

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Appel LLM interrompu", e);
            return "Une erreur de communication est survenue. Veuillez réessayer.";

        } catch (ConnectException | HttpConnectTimeoutException e) {
            // Cause fréquente : DNS, VPN, proxy, pare-feu ou URL incorrecte
            Throwable root = rootCause(e);
            String hint = (root instanceof UnresolvedAddressException)
                    ? "Le nom d'hôte est introuvable (DNS/VPN/URL incorrecte)."
                    : "Impossible de joindre le serveur (réseau/pare-feu/proxy).";
            log.error("Connexion au LLM impossible ({}). {} Vérifiez llm.base.url.", endpoint, hint);
            return "Une erreur de communication est survenue. Veuillez réessayer.";

        } catch (Exception e) {
            log.error("Erreur critique LLM : {}", e.getMessage(), e);
            return "Une erreur de communication est survenue. Veuillez réessayer.";
        }
    }

    /** Construit l'URL complète en nettoyant espaces et slashs finaux. */
    private String buildEndpoint() {
        String base = (baseUrl == null ? "" : baseUrl.trim());
        while (base.endsWith("/")) {
            base = base.substring(0, base.length() - 1);
        }
        return base + "/chat/completions";
    }

    /** Supprime tous les espaces et retours à la ligne (la clé collée contenait des espaces). */
    private String cleanKey() {
        return apiKey == null ? "" : apiKey.replaceAll("\\s+", "");
    }

    /** L'API n'accepte que system / user / assistant. */
    private String normalizeRole(String role) {
        if (role == null) {
            return "user";
        }
        return switch (role.trim().toLowerCase()) {
            case "assistant", "bot", "model", "ai" -> "assistant";
            case "system" -> "system";
            default -> "user";
        };
    }

    private Throwable rootCause(Throwable t) {
        Throwable cause = t;
        while (cause.getCause() != null && cause.getCause() != cause) {
            cause = cause.getCause();
        }
        return cause;
    }
}