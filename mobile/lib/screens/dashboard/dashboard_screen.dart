import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import '../../services/api_service.dart';
import '../contrats/contrats_screen.dart';
import '../sinistres/sinistres_screen.dart';
import '../reclamations/reclamations_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;
  String username = "Utilisateur";
  int contratCount = 0;
  int sinistreCount = 0;
  int reclamationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await ApiService.getUserProfile();
      if (profile != null) {
        setState(() {
          username = profile["username"] ?? profile["email"] ?? "Utilisateur";
        });
      }
      final contrats = await ApiService.getContrats(widget.userId);
      final sinistres = await ApiService.getSinistres();
      final reclamations = await ApiService.getReclamations();
      setState(() {
        contratCount = contrats.length;
        sinistreCount = sinistres.length;
        reclamationCount = reclamations.length;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading dashboard data: $e");
      setState(() => isLoading = false);
    }
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _logout(BuildContext context) {
    // Navigate all the way back to root (HomeScreen)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      body: BnaBackground(
        watermark: true,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            bottom: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 54, 22, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top navbar: Brand + User chip + Logout ──
                            Row(
                              children: [
                                // Grid icon + Title
                                const Icon(
                                  Icons.grid_view_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Tableau de Bord",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const Spacer(),
                                // Username chip
                                GestureDetector(
                                  onTap: () => _go(
                                    context,
                                    ProfileScreen(userId: widget.userId),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.25)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 26,
                                          width: 26,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Logout button
                                GestureDetector(
                                  onTap: () => _logout(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.25)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Déconnexion",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Bonjour,",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "$username 👋",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Votre compte est sécurisé et actif",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // KPI Metrics Grid
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _kpiCard(
                                title: "Contrats",
                                value: "$contratCount",
                                icon: Icons.description_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _kpiCard(
                                title: "Sinistres",
                                value: "$sinistreCount",
                                icon: Icons.warning_amber_rounded,
                                color: AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _kpiCard(
                                title: "Messages",
                                value: "$reclamationCount",
                                icon: Icons.forum_outlined,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Emergency Assistance Card
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.danger.withOpacity(0.15),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.danger.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 5,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.phone_in_talk_outlined,
                                        color: AppColors.danger,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Urgence & Assistance 24/7",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            "Panne ou sinistre ? Appelez notre assistance.",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        minimumSize: const Size(60, 36),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        "Appeler",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section Quick Actions
                      const Padding(
                        padding: EdgeInsets.fromLTRB(22, 24, 22, 12),
                        child: SectionTitle(
                          title: "Services & Outils",
                          subtitle: "Gérez votre protection en toute autonomie",
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: [
                            _menuCard(
                              context,
                              icon: Icons.description_outlined,
                              color: AppColors.primary,
                              title: "Mes contrats",
                              subtitle: "Consulter et télécharger vos contrats",
                              onTap: () => _go(
                                context,
                                ContratsScreen(userId: widget.userId),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _menuCard(
                              context,
                              icon: Icons.warning_amber_rounded,
                              color: AppColors.warning,
                              title: "Mes sinistres",
                              subtitle: "Déclarer et suivre vos sinistres",
                              onTap: () => _go(context, SinistresScreen()),
                            ),
                            const SizedBox(height: 12),
                            _menuCard(
                              context,
                              icon: Icons.mail_outline,
                              color: AppColors.success,
                              title: "Réclamations",
                              subtitle: "Adresser une demande au service client",
                              onTap: () => _go(context, ReclamationsScreen()),
                            ),

                          ],
                        ),
                      ),

                      // Standout Claim Status Card
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Votre Contrat Actif",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    height: 38,
                                    width: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Assurance Auto Premium",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          "Formule Tous Risques — N° BNA-99882",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      "ACTIF",
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
