import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../services/api_service.dart';

class ContratDetailScreen extends StatefulWidget {
  final String contratId;

  const ContratDetailScreen({Key? key, required this.contratId}) : super(key: key);

  @override
  _ContratDetailScreenState createState() => _ContratDetailScreenState();
}

class _ContratDetailScreenState extends State<ContratDetailScreen> {
  Map<String, dynamic>? contratFull;
  bool isLoading = true;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadContratDetails();
  }

  Future<void> _loadContratDetails() async {
    final data = await ApiService.getContratFull(widget.contratId);
    setState(() {
      contratFull = data;
      isLoading = false;
    });
  }

  Future<void> _downloadPDF() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final response = await ApiService.downloadPdf(widget.contratId);
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/Contrat_${widget.contratId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  bool isPaying = false;
  bool isReceiptDownloading = false;

  Future<void> _downloadReceipt() async {
    setState(() {
      isReceiptDownloading = true;
    });

    try {
      final response = await ApiService.downloadReceipt(widget.contratId);
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/Recu_${widget.contratId}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du téléchargement du reçu.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        isReceiptDownloading = false;
      });
    }
  }

  void _openPaymentBottomSheet(String primeFormatted) {
    final holderController = TextEditingController();
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    bool localPaying = false;
    bool localSuccess = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            if (localSuccess) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(height: 16),
                    Text(
                      "Paiement Réussi !",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green[800]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Votre contrat est désormais à jour.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Montant réglé", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600])),
                          Text("$primeFormatted TND", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue[800])),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context); // close modal
                        await _downloadReceipt();
                      },
                      icon: Icon(Icons.download, color: Colors.white),
                      label: Text("Télécharger le reçu (PDF)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Fermer"),
                    )
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Paiement Sécurisé",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 12),
                  // Cotisation summary
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Cotisation à régler", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900])),
                        Text("$primeFormatted TND", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.blue[900])),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: holderController,
                    decoration: InputDecoration(
                      labelText: "Nom du titulaire",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Numéro de carte",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.credit_card),
                      hintText: "XXXX XXXX XXXX XXXX",
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: expiryController,
                          decoration: InputDecoration(
                            labelText: "Expiration",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            hintText: "MM/AA",
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: cvvController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Code CVV",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            hintText: "123",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: localPaying
                          ? null
                          : () async {
                              if (holderController.text.isEmpty ||
                                  numberController.text.isEmpty ||
                                  expiryController.text.isEmpty ||
                                  cvvController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Veuillez remplir tous les champs.")),
                                );
                                return;
                              }

                              setModalState(() {
                                localPaying = true;
                              });

                              final payload = {
                                "cardHolder": holderController.text,
                                "cardNumber": numberController.text,
                                "cardExpiry": expiryController.text,
                                "cardCvv": cvvController.text,
                              };

                              final res = await ApiService.payContrat(widget.contratId, payload);
                              if (res != null) {
                                setModalState(() {
                                  localPaying = false;
                                  localSuccess = true;
                                });
                                // Refresh outer detail screen
                                _loadContratDetails();
                              } else {
                                setModalState(() {
                                  localPaying = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erreur de transaction.")),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: localPaying
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Confirmer le paiement",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text("Connexion SSL 256 bits sécurisée", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentStatusBlock(Map<String, dynamic> contratObj, String primeFormatted) {
    final rawEtat = contratObj["etatPaiement"] ?? "EN_ATTENTE";
    final isPaid = rawEtat == "A_JOUR" || rawEtat == "A JOUR";
    final isManager = ApiService.roles.contains("ROLE_GESTIONNAIRE");
    final isClient = !isManager;

    if (isPaid) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[200]!),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text(
                  "COTISATION RÉGLÉE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green[800]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              isClient 
                ? "Votre reçu officiel de paiement est disponible au téléchargement."
                : "La cotisation annuelle a été payée en ligne avec succès par l'assuré.",
              style: TextStyle(color: Colors.green[900], fontSize: 13),
            ),
            if (isClient) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isReceiptDownloading ? null : _downloadReceipt,
                  icon: isReceiptDownloading 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.green[800], strokeWidth: 2))
                      : Icon(Icons.file_download, color: Colors.white),
                  label: Text("Télécharger le reçu (PDF)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber[200]!),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.amber[800], size: 24),
                SizedBox(width: 8),
                Text(
                  "RÈGLEMENT EN ATTENTE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber[900]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              isClient 
                ? "Veuillez régler votre cotisation annuelle pour maintenir vos garanties actives."
                : "Le paiement de la cotisation par le client est actuellement en attente de règlement.",
              style: TextStyle(color: Colors.amber[900], fontSize: 13),
            ),
            if (isClient) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _openPaymentBottomSheet(primeFormatted),
                  icon: Icon(Icons.credit_card, color: Colors.white),
                  label: Text("Régler ma cotisation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: isBlue ? Colors.blue[700] : Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (contratFull == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Erreur")),
        body: Center(child: Text("Impossible de charger les détails.")),
      );
    }

    final contratObj = contratFull!["contrat"] ?? {};
    final reference = contratObj["numero"] ?? "N/A";
    final type = contratObj["type"] ?? "N/A";
    final formule = contratObj["formule"] ?? "";
    final produit = formule.isNotEmpty ? "$type • $formule" : type;
    
    final email = contratFull!["userEmail"] ?? "N/A";
    final cin = contratFull!["userCin"] ?? "N/A";
    
    // Formatting helper
    String formatDate(dynamic rawDate) {
      if (rawDate == null) return "N/A";
      final str = rawDate.toString().substring(0, 10);
      final parts = str.split('-');
      if (parts.length == 3) {
        return "${parts[2]}/${parts[1]}/${parts[0]}";
      }
      return str;
    }

    final dateEffetRaw = contratObj["dateDebut"] ?? contratObj["createdAt"];
    final dateEffet = formatDate(dateEffetRaw);
    
    dynamic computedDateFin = contratObj["dateFin"];
    if (computedDateFin == null && dateEffetRaw != null) {
      try {
        DateTime parsedDebut = DateTime.parse(dateEffetRaw.toString());
        computedDateFin = DateTime(parsedDebut.year + 1, parsedDebut.month, parsedDebut.day).toIso8601String();
      } catch (e) {}
    }
    final dateFin = formatDate(computedDateFin);

    final modePaiement = contratObj["modePaiement"] ?? "PRÉLÈVEMENT BANCAIRE";
    final etatPaiement = (contratObj["etatPaiement"] ?? "A JOUR").toString().replaceAll("_", " ");
    
    final primeRaw = contratObj["prime"]?.toString() ?? "0";
    String primeFormatted = primeRaw;
    try {
      double p = double.parse(primeRaw);
      String pStr = p.toStringAsFixed(2);
      final parts = pStr.split('.');
      final whole = parts[0].replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      primeFormatted = "$whole.${parts[1]}";
    } catch (e) {}
    
    final garanties = contratFull!["garanties"] as List? ?? [];
    final objets = contratFull!["objets"] as List? ?? [];

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "DÉTAILS DU CONTRAT",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
              ),
            ),
            SizedBox(height: 12),
            // Header Reference
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                children: [
                  TextSpan(text: "Référence : "),
                  TextSpan(text: reference, style: TextStyle(color: Colors.blue[600])),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Main Info Block
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 4))],
              ),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoRow("PRODUIT", produit),
                  Divider(color: Colors.grey[100]),
                  _buildInfoRow("SOUSCRIPTEUR", email),
                  Divider(color: Colors.grey[100]),
                  _buildInfoRow("CIN", cin, isBlue: true),
                  Divider(color: Colors.grey[100]),
                  _buildInfoRow("PÉRIODE", "$dateEffet au $dateFin"),
                  Divider(color: Colors.grey[100]),
                  _buildInfoRow("PAIEMENT", modePaiement),
                  Divider(color: Colors.grey[100]),
                  _buildInfoRow("STATUT PAIEMENT", etatPaiement),
                  if (contratObj["dateProchainPaiement"] != null) ...[
                    Divider(color: Colors.grey[100]),
                    _buildInfoRow("ÉCHÉANCE PAIEMENT", formatDate(contratObj["dateProchainPaiement"])),
                  ],
                  SizedBox(height: 20),
                  // Prime Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9), // Light green
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "COTISATION TOTALE TTC",
                          style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w900),
                            children: [
                              TextSpan(text: "$primeFormatted ", style: TextStyle(fontSize: 32)),
                              TextSpan(text: "TND", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildPaymentStatusBlock(contratObj, primeFormatted),
            SizedBox(height: 24),

            // Coverage & Guarantees Header
            Row(
              children: [
                Icon(Icons.security, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  "PÉRIMÈTRE DE COUVERTURE & GARANTIES",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Guarantees List
            if (garanties.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: garanties.map((g) {
                    final nomGarantie = g["nom"]?.toString().toUpperCase() ?? "GARANTIE";
                    final rawPlafond = g["plafond"]?.toString() ?? "0";
                    String plafondFormatted = rawPlafond;
                    try {
                      double p = double.parse(rawPlafond);
                      String pStr = p.toStringAsFixed(0);
                      plafondFormatted = pStr.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
                    } catch (e) {}

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              nomGarantie,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                              children: [
                                TextSpan(text: plafondFormatted, style: TextStyle(color: Colors.blue[700])),
                                TextSpan(text: " TND", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            SizedBox(height: 24),
            // Patrimoine Assure
            if (objets.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.inventory_2, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "PATRIMOINE ASSURÉ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...objets.map((o) {
                final marque = o["marque"] ?? "N/A";
                final modele = o["modele"] ?? "";
                final immat = o["immatriculation"] ?? "";
                final val = o["valeurVehicule"] ?? o["valeurBien"] ?? "0";
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_car, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text("$marque $modele".toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(immat, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                          Text("$val TND", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                );
              }).toList(),
            ],
            
            SizedBox(height: 40),
            // Download Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isDownloading ? null : _downloadPDF,
                icon: isDownloading 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  isDownloading ? "Téléchargement..." : "Télécharger l'Attestation Officielle",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E2225),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
