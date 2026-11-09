import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import 'package:intl/intl.dart';

class ReclamationsScreen extends StatefulWidget {
  @override
  State<ReclamationsScreen> createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends State<ReclamationsScreen> {
  List reclamations = [];
  List sinistres = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final recData = await ApiService.getReclamations();
    final sinData = await ApiService.getSinistres();
    if (!mounted) return;
    setState(() {
      reclamations = recData;
      sinistres = sinData;
      loading = false;
    });
  }

  int get enCoursCount => reclamations
      .where((r) => r['statut'] != 'RESOLVED' && r['statut'] != 'REJECTED')
      .length;
  int get resolusCount =>
      reclamations.where((r) => r['statut'] == 'RESOLVED').length;

  void _showCreateBottomSheet() {
    String titre = '';
    String description = '';
    String type = 'DELAY';
    String? sinistreId;
    const txt = TextStyle(color: AppColors.textPrimary);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 18,
                right: 18,
                top: 22,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.glassBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text("Détails de votre demande",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 18),
                    TextField(
                      style: txt,
                      decoration:
                          const InputDecoration(labelText: "Objet de la réclamation"),
                      onChanged: (val) => titre = val,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: type,
                      dropdownColor: AppColors.surface,
                      style: txt,
                      decoration:
                          const InputDecoration(labelText: "Catégorie"),
                      items: const [
                        DropdownMenuItem(
                            value: 'DELAY', child: Text("Retard de traitement")),
                        DropdownMenuItem(
                            value: 'DISPUTE',
                            child: Text("Contestation de décision")),
                        DropdownMenuItem(
                            value: 'PAYMENT_ISSUE',
                            child: Text("Problème de règlement")),
                        DropdownMenuItem(
                            value: 'OTHER', child: Text("Autre motif")),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => type = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: sinistreId,
                      dropdownColor: AppColors.surface,
                      style: txt,
                      isExpanded: true,
                      decoration: const InputDecoration(
                          labelText: "Dossier Sinistre lié"),
                      items: sinistres.map<DropdownMenuItem<String>>((s) {
                        return DropdownMenuItem<String>(
                          value: s['id'],
                          child: Text("${s['numero']} - ${s['titre']}",
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => sinistreId = val),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      style: txt,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          labelText: "Explications détaillées"),
                      onChanged: (val) => description = val,
                    ),
                    const SizedBox(height: 22),
                    BnaGradientButton(
                      label: "Envoyer ma demande",
                      icon: Icons.send,
                      onPressed: () async {
                        if (titre.isEmpty || description.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Veuillez remplir tous les champs")));
                          return;
                        }
                        Navigator.pop(context);
                        setState(() => loading = true);
                        await ApiService.createReclamation({
                          "titre": titre,
                          "description": description,
                          "type": type,
                          "sinistreId": sinistreId,
                        });
                        loadData();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BnaScaffold(
      title: "Mes Réclamations",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBottomSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nouvelle",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _kpi("Soumis", reclamations.length.toString(),
                          AppColors.primaryLight),
                      const SizedBox(width: 12),
                      _kpi("En cours", enCoursCount.toString(),
                          AppColors.warning),
                      const SizedBox(width: 12),
                      _kpi("Résolus", resolusCount.toString(),
                          AppColors.success),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (reclamations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(
                          child: Text("Aucune réclamation trouvée",
                              style:
                                  TextStyle(color: AppColors.textSecondary))),
                    )
                  else
                    ...reclamations.map(_reclamationCard),
                ],
              ),
            ),
    );
  }

  Widget _kpi(String title, String value, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _reclamationCard(dynamic r) {
    final dateCreated = r['dateCreation'] != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(r['dateCreation']))
        : 'Inconnu';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(r["titre"] ?? "Réclamation",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary)),
                ),
                _statusBadge(r["statut"] ?? "Inconnu"),
              ],
            ),
            const SizedBox(height: 6),
            Text(r["userEmail"] ?? "",
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Catégorie : ${r['type'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                Text(dateCreated,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
              ],
            ),
            if (r['sinistreNumero'] != null) ...[
              const SizedBox(height: 8),
              Text("Réf. Sinistre : ${r['sinistreNumero']}",
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'SUBMITTED':
        color = AppColors.primaryLight;
        break;
      case 'UNDER_REVIEW':
      case 'IN_PROGRESS':
        color = AppColors.warning;
        break;
      case 'RESOLVED':
        color = AppColors.success;
        break;
      case 'REJECTED':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.textMuted;
    }
    return BnaPill(text: status, color: color);
  }
}
