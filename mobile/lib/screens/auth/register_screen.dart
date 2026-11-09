import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final cinController = TextEditingController();
  final adresseController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    cinController.dispose();
    adresseController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Email requis";
    final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(v.trim())) return "Format d'email invalide";
    return null;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final ok = await ApiService.register(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim(),
      cin: cinController.text.trim(),
      adresse: adresseController.text.trim(),
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte cree avec succes. Connectez-vous."),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Echec de la creation du compte. Reessayez."),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(labelText: label, prefixIcon: Icon(icon), suffixIcon: suffix);

  @override
  Widget build(BuildContext context) {
    const txt = TextStyle(color: AppColors.textPrimary);
    return BnaScaffold(
      title: "Creer un compte",
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BnaLogo(size: 64)),
              const SizedBox(height: 18),
              const Text("Rejoignez BNA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text("Votre espace assurance en quelques secondes",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 26),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextFormField(
                      controller: fullNameController,
                      style: txt,
                      textInputAction: TextInputAction.next,
                      decoration: _dec("Nom complet", Icons.person_outline),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Nom requis" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      style: txt,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _dec("Email", Icons.email_outlined),
                      validator: _emailValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: cinController,
                      style: txt,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: _dec("Numero CIN", Icons.badge_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "CIN requis";
                        if (!RegExp(r'^[0-9]{6,12}$').hasMatch(v.trim())) {
                          return "CIN invalide";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: adresseController,
                      style: txt,
                      textInputAction: TextInputAction.next,
                      decoration: _dec("Adresse", Icons.location_on_outlined),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? "Adresse requise"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      style: txt,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration:
                          _dec("Telephone (optionnel)", Icons.phone_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (!RegExp(r'^\+?[0-9]{6,15}$').hasMatch(v.trim())) {
                          return "Numero invalide";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      style: txt,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      decoration: _dec("Mot de passe", Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          )),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Mot de passe requis";
                        if (v.length < 6) return "Au moins 6 caracteres";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmController,
                      style: txt,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      decoration: _dec(
                          "Confirmer le mot de passe", Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.textSecondary),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          )),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Veuillez confirmer";
                        if (v != passwordController.text) {
                          return "Les mots de passe ne correspondent pas";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BnaGradientButton(
                label: "Creer mon compte",
                loading: isLoading,
                onPressed: register,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Vous avez deja un compte ?",
                      style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Connexion"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
