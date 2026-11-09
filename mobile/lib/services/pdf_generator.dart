import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Génère un PDF de contrat BNA propre et structuré (côté client).
/// Requiert la dépendance `pdf` dans pubspec.yaml (déjà présente).
class ContratPdfGenerator {
  // NB: PdfColor.fromInt n'est PAS const -> on utilise `final`.
  static final PdfColor _navy = PdfColor.fromInt(0xFF0A1424);
  static final PdfColor _blue = PdfColor.fromInt(0xFF2F6BFF);
  static final PdfColor _grey = PdfColor.fromInt(0xFF6B7C93);
  static final PdfColor _line = PdfColor.fromInt(0xFFE2E8F0);
  static final PdfColor _soft = PdfColor.fromInt(0xFFF4F6FB);
  static final PdfColor _subtle = PdfColor.fromInt(0xFF9FB3C8);

  static Future<Uint8List> build(Map contrat) async {
    final doc = pw.Document();

    final numero = (contrat['numero'] ?? 'N/A').toString();
    final type = (contrat['type'] ?? 'PRODUIT').toString();
    final prime = (contrat['prime'] ?? '0').toString();
    final statut = (contrat['statut'] ?? 'ACTIF').toString();
    final risk = (contrat['riskLevel'] ?? 'FAIBLE').toString();
    final now = DateTime.now();
    final date =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (ctx) => [
          // ===== En-tête =====
          pw.Container(
            width: double.infinity,
            padding: pw.EdgeInsets.all(28),
            color: _navy,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("BNA ASSURANCES",
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text("Attestation de contrat d'assurance",
                        style: pw.TextStyle(color: _subtle, fontSize: 12)),
                  ],
                ),
                pw.Container(
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                      color: _blue,
                      borderRadius: pw.BorderRadius.circular(6)),
                  child: pw.Text(statut.toUpperCase(),
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          ),

          // ===== Corps =====
          pw.Padding(
            padding: pw.EdgeInsets.all(28),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Référence du contrat",
                    style: pw.TextStyle(color: _grey, fontSize: 10)),
                pw.SizedBox(height: 2),
                pw.Text(numero,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 22),

                _table([
                  ["Type d'assurance", type],
                  ["Statut", statut],
                  ["Cotisation annuelle", "$prime TND"],
                  ["Profil de risque", risk],
                  ["Date d'édition", date],
                ]),

                pw.SizedBox(height: 26),
                pw.Text("Garanties & conditions",
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _navy)),
                pw.SizedBox(height: 8),
                pw.Bullet(
                    text:
                        "Le présent document atteste de la souscription du contrat ci-dessus auprès de BNA."),
                pw.Bullet(
                    text:
                        "Les garanties s'appliquent selon les conditions générales et particulières remises au souscripteur."),
                pw.Bullet(
                    text:
                        "En cas de sinistre, contactez votre espace client ou l'assistance disponible 24/7."),

                pw.SizedBox(height: 34),
                pw.Divider(color: _line),
                pw.SizedBox(height: 6),
                pw.Text(
                    "Document généré électroniquement - BNA © ${now.year}. Sans valeur d'engagement contractuel hors conditions signées.",
                    style: pw.TextStyle(color: _grey, fontSize: 9)),
              ],
            ),
          ),
        ],
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: pw.EdgeInsets.only(right: 28, bottom: 12),
          child: pw.Text("Page ${ctx.pageNumber}/${ctx.pagesCount}",
              style: pw.TextStyle(color: _grey, fontSize: 9)),
        ),
      ),
    );

    return doc.save();
  }

  static pw.Widget _table(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: _line, width: 0.5),
      columnWidths: {
        0: pw.FlexColumnWidth(1.2),
        1: pw.FlexColumnWidth(2),
      },
      children: rows
          .map(
            (r) => pw.TableRow(children: [
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                color: _soft,
                child: pw.Text(r[0],
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                child: pw.Text(r[1], style: pw.TextStyle(fontSize: 11)),
              ),
            ]),
          )
          .toList(),
    );
  }
}
