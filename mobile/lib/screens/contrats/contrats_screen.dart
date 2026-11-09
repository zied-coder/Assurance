import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../services/api_service.dart';
import '../../services/pdf_generator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';
import 'contrat_detail_screen.dart';

class ContratsScreen extends StatefulWidget {
  final String userId;
  const ContratsScreen({super.key, required this.userId});

  @override
  State<ContratsScreen> createState() => _ContratsScreenState();
}

class _ContratsScreenState extends State<ContratsScreen> {
  List contrats = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadContrats();
  }

  void loadContrats() async {
    final data = await ApiService.getContrats(widget.userId);
    if (!mounted) return;
    setState(() {
      contrats = data;
      loading = false;
    });
  }

  Future<void> _generatePDF(Map c) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Génération du PDF...')));
    try {
      final bytes = await ContratPdfGenerator.build(c);
      final directory = await getApplicationDocumentsDirectory();
      final name = (c["numero"] ?? c["id"] ?? "contrat").toString();
      final file = File('${directory.path}/Contrat_$name.pdf');
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BnaScaffold(
      title: "Mes Contrats",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : contrats.isEmpty
              ? const Center(
                  child: Text("Aucun contrat trouvé",
                      style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: contrats.length,
                  itemBuilder: (context, index) =>
                      _contratCard(contrats[index]),
                ),
    );
  }

  Widget _contratCard(Map c) {
    final reference = c["numero"] ?? "N/A";
    final type = (c["type"] ?? "PRODUIT").toString().toUpperCase();
    final prime = c["prime"]?.toString() ?? "0";
    final statut = (c["statut"] ?? "ACTIF").toString().toUpperCase();
    final riskLevel = (c["riskLevel"] ?? "FAIBLE").toString().toUpperCase();

    IconData iconData = Icons.description;
    Color accent = AppColors.primaryLight;
    if (type == "AUTO") {
      iconData = Icons.directions_car;
      accent = AppColors.primaryLight;
    } else if (type == "HABITATION") {
      iconData = Icons.home;
      accent = AppColors.warning;
    } else if (type == "SANTE") {
      iconData = Icons.health_and_safety;
      accent = AppColors.success;
    } else if (type == "VIE") {
      iconData = Icons.favorite;
      accent = AppColors.danger;
    }

    Color riskColor = AppColors.success;
    if (riskLevel.contains("MODÉRÉ") || riskLevel.contains("MOYEN")) {
      riskColor = AppColors.warning;
    } else if (riskLevel.contains("ÉLEVÉ") || riskLevel.contains("HAUT")) {
      riskColor = AppColors.danger;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reference,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(type,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: accent, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: BnaPill(text: statut, color: AppColors.success),
            ),
            const SizedBox(height: 18),
            _rowInfo("COTISATION ANNUELLE", "$prime TND"),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("PROFIL RISQUE",
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                BnaPill(text: riskLevel, color: riskColor),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContratDetailScreen(
                            contratId: c["id"].toString()),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Détails"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _generatePDF(c),
                      icon: const Icon(Icons.picture_as_pdf,
                          color: Colors.white, size: 18),
                      label: const Text("PDF",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
