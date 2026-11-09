import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import '../dashboard/dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final res = await ApiService.login(
      usernameController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (res != null) {
      final profile = await ApiService.getUserProfile();
      final userId = profile != null ? profile["id"].toString() : res["id"].toString();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen(userId: userId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Identifiant ou mot de passe incorrect"),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BnaScaffold(
      showAppBar: false,
      watermark: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BnaLogo(size: 50),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BNA",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Bienvenue\nchez vous.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Protégez ce qui compte le plus avec BNA. Votre espace client — simple, rapide et sécurisé.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: const Border(
                      top: BorderSide(color: AppColors.primary, width: 4),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Se connecter",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Entrez vos identifiants pour accéder à votre espace",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Identifiant
                      const Text(
                        "IDENTIFIANT / EMAIL",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: usernameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: "Nom d'utilisateur ou email",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Champ requis"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Mot de passe
                      const Text(
                        "MOT DE PASSE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscure,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      BnaGradientButton(
                        label: "Accéder à mon espace",
                        loading: isLoading,
                        icon: Icons.arrow_forward,
                        onPressed: login,
                      ),
                      const SizedBox(height: 20),

                      // Signup Redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Pas encore client ?",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            ),
                            child: const Text(
                              "Créer un compte",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Return home
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        icon: const Icon(Icons.home_outlined, size: 16),
                        label: const Text(
                          "Retour à l'accueil",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
