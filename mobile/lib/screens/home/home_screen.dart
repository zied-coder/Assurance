import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../simulation/simulation_screen.dart';

/// Page d'accueil mobile reprenant le design du site web BNA :
/// header + hero "Futur Digital" + carte Protection 360° + solutions + footer.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOutCubic))
              .animate(a),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      // Bouton chatbot flottant (comme sur le web).
      floatingActionButton: BnaChatFab(
        onPressed: () => _go(context, const ChatbotScreen()),
      ),
      body: BnaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _hero(context),
                      const SizedBox(height: 22),
                      _protectionCard(),
                      const SizedBox(height: 44),
                      _solutions(context),
                      const SizedBox(height: 44),
                      _footer(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ================= Mon Espace chip =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
      child: Row(
        children: [
          const BnaLogo(size: 40),
          const SizedBox(width: 12),
          const Text(
            "BNA",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const Spacer(),
          // "Mon Espace" -> Login
          GestureDetector(
            onTap: () => _go(context, const LoginScreen()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassFill,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle_outlined,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text("Mon Espace",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== HERO =====================
  Widget _hero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BnaPill(text: "INNOVATION & CONFIANCE"),
        const SizedBox(height: 18),
        const Text(
          "Protégez votre",
          style: TextStyle(
            fontSize: 38,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              "Futur Digital",
              style: TextStyle(
                fontSize: 38,
                height: 1.05,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              ".",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "L'assurance nouvelle génération qui s'adapte à votre rythme de vie. "
          "Une gestion simplifiée, une protection maximale et une transparence totale.",
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 24),
        BnaGradientButton(
          label: "Démarrer ma simulation",
          icon: Icons.arrow_forward,
          onPressed: () => _go(context, const SimulationScreen()),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _go(context, const RegisterScreen()),
          child: const Text("Créer un compte"),
        ),
      ],
    );
  }

  // ===================== PROTECTION 360° =====================
  Widget _protectionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 18),
          const Text(
            "Protection 360°",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vos contrats et sinistres gérés en temps réel avec une sécurité de niveau bancaire.",
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              BnaPill(text: "Certifié BNA", color: AppColors.primary),
              BnaPill(text: "Disponible 24/7", color: AppColors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== SOLUTIONS =====================
  Widget _solutions(BuildContext context) {
    return Column(
      children: [
        const SectionTitle(
          title: "Des solutions adaptées\nà chaque besoin",
          align: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _solutionCard(
          context,
          icon: Icons.directions_car_filled,
          color: AppColors.primary,
          title: "Assurance Auto",
          desc:
              "De la protection urbaine au grand voyageur, choisissez la formule qui correspond à votre conduite.",
        ),
        const SizedBox(height: 16),
        _solutionCard(
          context,
          icon: Icons.home_rounded,
          color: AppColors.warning,
          title: "Home Premium",
          desc:
              "Protégez votre foyer avec des garanties étendues : bris de glace, dommages électriques et cyber-risques.",
        ),
        const SizedBox(height: 16),
        _solutionCard(
          context,
          icon: Icons.favorite_rounded,
          color: AppColors.danger,
          title: "Santé & Prévoyance",
          desc:
              "Assurez votre bien-être et celui de vos proches avec une couverture santé complète et réactive.",
        ),
      ],
    );
  }

  Widget _solutionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () => _go(context, const SimulationScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("En savoir plus",
                  style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_forward, size: 16, color: color),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== FOOTER =====================
  Widget _footer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.black.withOpacity(0.08)),
        const SizedBox(height: 20),
        Row(
          children: const [
            BnaLogo(size: 38),
            SizedBox(width: 10),
            Text("BNA",
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "L'expertise de la Banque Nationale Agricole au service de votre sécurité et de celle de vos biens depuis plus de 60 ans.",
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 26),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _footerColumn(
                "Produits",
                ["Automobile", "Habitation", "Santé", "Vie & Prévoyance"],
              ),
            ),
            Expanded(
              child: _footerColumn(
                "Assistance",
                [
                  "Déclarer un sinistre",
                  "Suivre mon dossier",
                  "Aide en ligne",
                  "Nous contacter"
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text("Suivez-nous",
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: [
            _social(Icons.facebook),
            const SizedBox(width: 12),
            _socialText("in"),
            const SizedBox(width: 12),
            _socialText("X"),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "© 2026 BNA. Tous droits réservés.",
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 12),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(e,
                style:
                    const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _social(IconData icon) => Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      );

  Widget _socialText(String t) => Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(t,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
      );
}
