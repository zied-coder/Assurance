import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import 'sinistre_detail_screen.dart';
import 'declare_sinistre_screen.dart';

class SinistresScreen extends StatefulWidget {
  @override
  State<SinistresScreen> createState() => _SinistresScreenState();
}

class _SinistresScreenState extends State<SinistresScreen> {
  List sinistres = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSinistres();
  }

  void loadSinistres() async {
    final data = await ApiService.getSinistres();
    if (!mounted) return;
    setState(() {
      sinistres = data;
      loading = false;
    });
  }

  String formatStatut(String statut) {
    switch (statut) {
      case 'SUBMITTED': return 'NOUVEAU';
      case 'UNDER_REVIEW': return 'EN EXAMEN';
      case 'ADDITIONAL_INFORMATION_REQUIRED': return 'INFOS MANQUANTES';
      case 'EXPERT_ASSIGNED': return 'EXPERT ASSIGNÉ';
      case 'UNDER_EXPERT_REVIEW': return 'EN EXPERTISE';
      case 'APPROVED': return 'APPROUVÉ';
      case 'REJECTED': return 'REJETÉ';
      case 'SETTLED': return 'PAYÉ / RÉGLÉ';
      default: return statut.replaceAll("_", " ");
    }
  }

  Color getStatusColor(String statut) {
    if (statut == 'APPROVED' || statut == 'SETTLED') return AppColors.success;
    if (statut == 'REJECTED') return AppColors.danger;
    if (statut == 'ADDITIONAL_INFORMATION_REQUIRED') return AppColors.warning;
    if (statut == 'UNDER_REVIEW') return AppColors.warning;
    return AppColors.primaryLight;
  }

  Future<void> _openDetail(dynamic id) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => SinistreDetailScreen(sinistreId: id)));
    setState(() => loading = true);
    loadSinistres();
  }

  @override
  Widget build(BuildContext context) {
    final enCours = sinistres
        .where((s) =>
            !['APPROVED', 'REJECTED', 'SETTLED', 'CLOSED'].contains(s["statut"]))
        .toList();
    final historique = sinistres
        .where((s) =>
            ['APPROVED', 'REJECTED', 'SETTLED', 'CLOSED'].contains(s["statut"]))
        .toList();
    final indemnises =
        sinistres.where((s) => s["statut"] == 'SETTLED').toList();
    final alertes = sinistres
        .where((s) => s["statut"] == 'ADDITIONAL_INFORMATION_REQUIRED')
        .toList();

    return BnaScaffold(
      title: "Portail Sinistres",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gestion professionnelle des déclarations",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  BnaGradientButton(
                    label: "Déclarer un sinistre",
                    icon: Icons.add,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DeclareSinistreScreen()),
                      );
                      if (result == true) {
                        setState(() => loading = true);
                        loadSinistres();
                      }
                    },
                  ),
                  const SizedBox(height: 22),

                  // KPIs (grille 2x2 -> jamais coupés)
                  Row(
                    children: [
                      Expanded(
                          child: _kpi("TOTAL DOSSIERS", "${sinistres.length}",
                              Icons.folder, AppColors.primaryLight)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _kpi("EN COURS", "${enCours.length}",
                              Icons.access_time, AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _kpi("INDEMNISÉS", "${indemnises.length}",
                              Icons.check_circle, AppColors.success)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _kpi("ALERTES", "${alertes.length}",
                              Icons.warning, AppColors.danger)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  _sectionHeader(
                      Icons.folder_open, "À traiter & En cours", AppColors.primaryLight),
                  const SizedBox(height: 14),
                  if (enCours.isEmpty)
                    _emptyBox("Aucun dossier en cours.")
                  else
                    ...enCours.map(_enCoursItem),

                  const SizedBox(height: 30),
                  _sectionHeader(Icons.archive, "Historique & Décisions",
                      AppColors.textSecondary),
                  const SizedBox(height: 14),
                  if (historique.isEmpty)
                    _emptyBox("Aucun historique.")
                  else
                    ...historique.map(_historiqueItem),
                ],
              ),
            ),
    );
  }

  Widget _kpi(String title, String count, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(count,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _emptyBox(String txt) => GlassCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: Text(txt,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );

  Widget _enCoursItem(dynamic s) {
    final statut = s["statut"] ?? "SUBMITTED";
    final color = getStatusColor(statut);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(s["numero"] ?? "N/A",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: 8),
                      BnaPill(
                          text: formatStatut(statut),
                          color: color,
                          icon: Icons.search),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s["titre"] ?? "Incident",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(s["description"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(s["adresse"] ?? "N/A",
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _openDetail(s["id"]),
              icon: const Icon(Icons.remove_red_eye, color: AppColors.cyan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _historiqueItem(dynamic s) {
    final statut = s["statut"] ?? "REJECTED";
    final color = getStatusColor(statut);
    final statusIcon = statut == 'APPROVED'
        ? Icons.check_circle
        : statut == 'SETTLED'
            ? Icons.monetization_on
            : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(s["numero"] ?? "N/A",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary)),
                ),
                BnaPill(
                    text: formatStatut(statut),
                    color: color,
                    icon: statusIcon),
              ],
            ),
            const SizedBox(height: 8),
            Text(s["titre"] ?? "Incident",
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openDetail(s["id"]),
                icon: const Icon(Icons.insert_drive_file, size: 14),
                label: const Text("Consulter"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
