import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import '../home/home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final telController = TextEditingController();
  final cinController = TextEditingController();
  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmPwController = TextEditingController();

  Map<String, dynamic>? profile;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telController.dispose();
    cinController.dispose();
    currentPwController.dispose();
    newPwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  String _pick(Map<String, dynamic> p, List<String> keys) {
    for (final k in keys) {
      final v = p[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return "";
  }

  void loadProfile() async {
    final data = await ApiService.getUserProfile();
    if (!mounted) return;
    if (data != null) {
      nomController.text = _pick(data, ["nom", "fullName", "username"]).isNotEmpty
          ? _pick(data, ["nom", "fullName", "username"])
          : "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();
      emailController.text = _pick(data, ["email"]);
      telController.text = _pick(data, ["telephone", "phone"]);
      cinController.text = _pick(data, ["cin", "numeroCin"]);
    }
    setState(() {
      profile = data;
      loading = false;
    });
  }

  void logout() {
    ApiService.token = null;
    ApiService.roles = [];
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation des mots de passe (uniquement si l'utilisateur veut les changer)
    final wantsPwChange = newPwController.text.isNotEmpty ||
        confirmPwController.text.isNotEmpty;
    if (wantsPwChange) {
      if (currentPwController.text.isEmpty) {
        _snack("Saisissez votre mot de passe actuel", AppColors.danger);
        return;
      }
      if (newPwController.text.length < 6) {
        _snack("Le nouveau mot de passe doit faire 6 caractères min.",
            AppColors.danger);
        return;
      }
      if (newPwController.text != confirmPwController.text) {
        _snack("Les mots de passe ne correspondent pas", AppColors.danger);
        return;
      }
    }

    setState(() => saving = true);

    final body = <String, dynamic>{
      "username": nomController.text.trim(),
      "email": emailController.text.trim(),
      "phone": telController.text.trim(),
      "cin": cinController.text.trim(),
    };
    if (wantsPwChange) {
      body["oldPassword"] = currentPwController.text;
      body["password"] = newPwController.text;
    }

    final ok = await ApiService.updateUserProfile(widget.userId, body);

    if (!mounted) return;
    setState(() => saving = false);

    if (ok) {
      currentPwController.clear();
      newPwController.clear();
      confirmPwController.clear();
      _snack("Modifications enregistrées avec succès", AppColors.success);
    } else {
      _snack("Échec de l'enregistrement. Vérifiez vos informations.",
          AppColors.danger);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final role = ApiService.roles.isNotEmpty ? ApiService.roles.first : "ROLE_USER";
    const txt = TextStyle(color: AppColors.textPrimary);

    return BnaScaffold(
      title: "Mon Profil",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 90, 20, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête
                    Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mon Profil",
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 2),
                              Text(
                                  "Gérez vos informations personnelles et de sécurité",
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Statut + Rôle
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("STATUT DU COMPTE",
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5)),
                                SizedBox(height: 10),
                                BnaPill(
                                    text: "Actif & Vérifié",
                                    color: AppColors.primary,
                                    icon: Icons.verified),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("RÔLE & ACCÈS",
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.badge,
                                        color: AppColors.cyan, size: 18),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(role,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Informations personnelles
                    _sectionLabel(Icons.info_outline, "Informations Personnelles"),
                    const SizedBox(height: 14),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nomController,
                            style: txt,
                            decoration: const InputDecoration(
                                labelText: "Nom complet",
                                prefixIcon: Icon(Icons.person_outline)),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "Nom requis"
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: emailController,
                            style: txt,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: "Adresse email",
                                prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "Email requis";
                              }
                              if (!RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$')
                                  .hasMatch(v.trim())) {
                                return "Email invalide";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: telController,
                            style: txt,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                labelText: "Numéro de téléphone",
                                prefixIcon: Icon(Icons.phone_outlined)),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: cinController,
                            style: txt,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Numéro de CIN",
                                prefixIcon: Icon(Icons.badge_outlined)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Sécurité
                    _sectionLabel(Icons.shield_outlined, "Sécurité"),
                    const SizedBox(height: 14),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: currentPwController,
                            style: txt,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: "Mot de passe actuel",
                                prefixIcon: Icon(Icons.key_outlined)),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: newPwController,
                            style: txt,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: "Nouveau mot de passe",
                                prefixIcon: Icon(Icons.lock_outline)),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: confirmPwController,
                            style: txt,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: "Confirmer le mot de passe",
                                prefixIcon: Icon(Icons.lock_outline)),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 16, color: AppColors.primaryLight),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Laissez ces champs vides si vous ne souhaitez modifier que vos informations personnelles.",
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    BnaGradientButton(
                      label: "Enregistrer les modifications",
                      icon: Icons.save_outlined,
                      loading: saving,
                      onPressed: save,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: const Text("Déconnexion",
                          style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryLight, size: 20),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: AppColors.primaryLight,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
