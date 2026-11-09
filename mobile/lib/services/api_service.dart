import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://10.0.2.2:8082/api";
  static String? token;
  static List<String> roles = [];

  // ================= LOGIN =================
  static Future<Map<String, dynamic>?> login(
      String username,
      String password,
  ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    print("LOGIN STATUS: ${response.statusCode}");
    print("LOGIN BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["accessToken"] != null) {
        token = data["accessToken"];
      } else if (data["token"] != null) {
        token = data["token"];
      }
      if (data["roles"] != null) {
        roles = List<String>.from(data["roles"]);
      }
      return data;
    }

    return null;
  }


  // ================= REGISTER =================
  static Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String phone = "",
    String cin = "",
    String adresse = "",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": email, // We can use email as username since mobile app doesn't request a username
        "email": email,
        "password": password,
        "phone": phone,
        "cin": cin,
        "address": adresse, // Map to backend property 'address'
        "role": "ROLE_USER",
      }),
    );
    print("REGISTER STATUS: ${response.statusCode}");
    print("REGISTER BODY: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ================= UPDATE PROFILE =================
  // ⚠️ Endpoint à créer côté Spring si absent (PUT /users/{id}).
  //    Laisse les champs mot de passe vides pour ne modifier que les infos.
  static Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: _getAuthHeaders(),
      body: jsonEncode(data),
    );
    print("UPDATE PROFILE STATUS: ${response.statusCode}");
    print("UPDATE PROFILE BODY: ${response.body}");
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Map<String, String> _getAuthHeaders() {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ================= CONTRATS =================
  static Future<List> getContrats([String? userId]) async {
    final response = await http.get(
      Uri.parse("$baseUrl/contrats/my"),
      headers: _getAuthHeaders(),
    );

    print("CONTRATS STATUS: ${response.statusCode}");
    print("CONTRATS BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getContratFull(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/contrats/full/$id"),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<http.Response> downloadPdf(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/contrats/pdf/$id"),
      headers: _getAuthHeaders(),
    );
    return response;
  }

  static Future<Map<String, dynamic>?> payContrat(String id, Map<String, String> cardDetails) async {
    final response = await http.post(
      Uri.parse("$baseUrl/contrats/$id/pay"),
      headers: _getAuthHeaders(),
      body: jsonEncode(cardDetails),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<http.Response> downloadReceipt(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/contrats/receipt/$id"),
      headers: _getAuthHeaders(),
    );
    return response;
  }

  // ================= SINISTRES =================
  static Future<List> getSinistres() async {
    final response = await http.get(
      Uri.parse("$baseUrl/sinistres/user"),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getSinistreById(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/sinistres/$id"),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  static Future<bool> createSinistre(Map<String, String> data, {String? filePath}) async {
    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/sinistres/upload"));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<String?> getMapKey() async {
    final response = await http.get(
      Uri.parse("$baseUrl/sinistres/config/map-key"),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["key"];
    }
    return null;
  }

  static Future<bool> completerSinistre(String id, Map<String, String> data, {String? filePath}) async {
    var request = http.MultipartRequest("PUT", Uri.parse("$baseUrl/sinistres/completer/$id"));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (filePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ================= RECLAMATIONS =================
  static Future<List> getReclamations() async {
    final response = await http.get(
      Uri.parse("$baseUrl/reclamations/user"),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> createReclamation(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reclamations"),
      headers: _getAuthHeaders(),
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ================= USER PROFILE =================
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/profile"),
      headers: _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // ================= CHATBOT =================
  static Future<String> sendChatMessage(String message, String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chatbot/ask"),
        headers: _getAuthHeaders(),
        body: jsonEncode({
          "message": message,
          "sessionId": sessionId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"] ?? "Pas de réponse";
      }
    } catch (e) {
      print("Chat Error: $e");
    }
    return "Erreur de communication avec le chatbot.";
  }
}
