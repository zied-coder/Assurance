import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'completer_sinistre_screen.dart';

class SinistreDetailScreen extends StatefulWidget {
  final String sinistreId;

  const SinistreDetailScreen({super.key, required this.sinistreId});

  @override
  State<SinistreDetailScreen> createState() => _SinistreDetailScreenState();
}

class _SinistreDetailScreenState extends State<SinistreDetailScreen> {
  Map<String, dynamic>? sinistre;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  void loadDetail() async {
    final data = await ApiService.getSinistreById(widget.sinistreId);
    setState(() {
      sinistre = data;
      loading = false;
    });
  }

  String formatStatut(String statut) {
    switch (statut) {
      case 'SUBMITTED':
        return 'NOUVEAU';
      case 'UNDER_REVIEW':
        return 'EN EXAMEN';
      case 'ADDITIONAL_INFORMATION_REQUIRED':
        return 'INFOS MANQUANTES';
      case 'EXPERT_ASSIGNED':
        return 'EXPERT ASSIGNÉ';
      case 'UNDER_EXPERT_REVIEW':
        return 'EN EXPERTISE';
      case 'APPROVED':
        return 'APPROUVÉ';
      case 'REJECTED':
        return 'REJETÉ';
      case 'SETTLED':
        return 'PAYÉ / RÉGLÉ';
      default:
        return statut.replaceAll("_", " ");
    }
  }

  Color getStatusColor(String statut) {
    if (statut == 'APPROVED' || statut == 'SETTLED') return Colors.green;
    if (statut == 'REJECTED') return Colors.red;
    if (statut == 'ADDITIONAL_INFORMATION_REQUIRED') return Colors.orange;
    return Colors.blue;
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? Colors.blue[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String formatEnglishDate(String rawDate) {
    if (rawDate.isEmpty || rawDate == "N/A") return "N/A";
    try {
      final parts = rawDate.split('-');
      if (parts.length != 3) return rawDate;
      final year = parts[0];
      final monthNum = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final monthStr = (monthNum >= 1 && monthNum <= 12) ? months[monthNum - 1] : parts[1];
      return "$monthStr $day, $year";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Color(0xFFF7F9FC),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (sinistre == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF7F9FC),
        appBar: AppBar(title: Text("Erreur"), backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: Text("Impossible de charger les détails.")),
      );
    }

    final s = sinistre!;
    final contrat = s["contrat"] ?? {};
    final reference = s["numero"] ?? "N/A";
    final statutFormat = s["statut"]?.toString() ?? "SUBMITTED"; // Match exact web string
    final rawDate = s["date"] != null ? s["date"].toString().substring(0, 10) : "N/A";
    final formattedDate = formatEnglishDate(rawDate);
    final adresse = s["adresse"] ?? "N/A";
    final description = s["description"] ?? "";
    final commentaire = s["commentaire"] ?? "En attente de vérification initiale.";
    final email = s["userEmail"] ?? "N/A";
    final cin = s["userCin"] ?? "N/A";
    final contratRef = contrat["numero"] ?? "N/A";
    final contratProduit = "${contrat["type"] ?? "N/A"} • ${contrat["formule"] ?? "N/A"}";

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RÉFÉRENCE DOSSIER",
                      style: TextStyle(color: Colors.blue[600], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      reference,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        statutFormat,
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
             SizedBox(height: 24),

             if (statutFormat == "ADDITIONAL_INFORMATION_REQUIRED") ...[
               Container(
                 width: double.infinity,
                 padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.red[50],
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: Colors.red[200]!),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       children: [
                         Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 24),
                         SizedBox(width: 10),
                         Text(
                           "Action requise par l'assuré",
                           style: TextStyle(color: Colors.red[950], fontWeight: FontWeight.bold, fontSize: 14),
                         ),
                       ],
                     ),
                     SizedBox(height: 8),
                     Text(
                       "Message du gestionnaire :",
                       style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold, fontSize: 12),
                     ),
                     SizedBox(height: 4),
                     Text(
                       s["commentaire"] ?? "Veuillez fournir des informations complémentaires.",
                       style: TextStyle(color: Colors.red[900], fontSize: 13, fontWeight: FontWeight.w600),
                     ),
                   ],
                 ),
               ),
               SizedBox(height: 24),
             ],

             // Main Card (Détails de l'incident)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.description, color: Colors.blue[600], size: 20),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Détails de l'incident déclaré",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  Text("TITRE DE L'INCIDENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Text(s["titre"] ?? "Incident", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DATE DU SINISTRE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.blue[600]),
                                SizedBox(width: 6),
                                Expanded(child: Text(formattedDate, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87))),
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("LIEU & LOCALISATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.red),
                                SizedBox(width: 6),
                                Expanded(child: Text(adresse, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87))),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Text("DESCRIPTION CIRCONSTANCIÉE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(left: BorderSide(color: Colors.blue[600]!, width: 4)),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text("DERNIÈRE NOTE DE GESTION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, color: Colors.blue[800], size: 18),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            commentaire,
                            style: TextStyle(color: Colors.blue[900], fontSize: 13),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Sidebar Card (Souscripteur)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("SOUSCRIPTEUR & GARANTIES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  Divider(color: Colors.grey[200], height: 24, thickness: 1),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.person, color: Colors.blue[600], size: 24),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                          SizedBox(height: 2),
                          Text("CIN: $cin", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("RÉFÉRENCE CONTRAT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Text(contratRef, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[600])),
                        SizedBox(height: 4),
                        Text(contratProduit, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("CONTRAT ACTIF", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            if (s["expertNom"] != null) ...[
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("EXPERTISE TECHNIQUE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                    Divider(color: Colors.grey[200], height: 24, thickness: 1),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.engineering, color: Colors.cyan[700], size: 24),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s["expertNom"] ?? "", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                              SizedBox(height: 4),
                              Text("Tél: ${s['expertTelephone'] ?? 'N/A'}", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.cyan.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.cyan[700], size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s["expertRendezVous"] ?? "Rendez-vous à fixer",
                              style: TextStyle(color: Colors.cyan[800], fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                    if (s["rapportExpert"] != null && (s["rapportExpert"] as String).isNotEmpty) ...[
                      SizedBox(height: 16),
                      Text("Conclusion de l'expert :", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border(left: BorderSide(color: Colors.cyan[600]!, width: 4)),
                        ),
                        child: Text(
                          '"${s["rapportExpert"]}"',
                          style: TextStyle(color: Colors.black87, fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ],
            SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                if ((s["latitude"] != null && s["longitude"] != null) || (adresse.isNotEmpty && adresse != "N/A"))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Uri url;
                        if (s["latitude"] != null && s["longitude"] != null) {
                          url = Uri.parse("https://www.google.com/maps?q=${s['latitude']},${s['longitude']}");
                        } else {
                          url = Uri.parse("https://www.google.com/maps?q=${Uri.encodeComponent(adresse)}");
                        }
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrl(url, mode: LaunchMode.platformDefault);
                        }
                      },
                      icon: Icon(Icons.location_on, color: Colors.blue[600], size: 18),
                      label: Text("Localiser l'incident", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                if (s["document"] != null) ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse("http://10.0.2.2:8082/uploads/${s['document']}");
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrl(url, mode: LaunchMode.platformDefault);
                        }
                      },
                      icon: Icon(Icons.attach_file, color: Colors.blue[600], size: 18),
                      label: Text("Voir Justificatif", style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
                if (statutFormat == "ADDITIONAL_INFORMATION_REQUIRED") ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompleterSinistreScreen(sinistre: s),
                          ),
                        );
                        if (result == true) {
                          loadDetail();
                        }
                      },
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text("Compléter mon dossier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Fermer le dossier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
