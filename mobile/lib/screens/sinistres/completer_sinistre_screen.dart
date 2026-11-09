import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class CompleterSinistreScreen extends StatefulWidget {
  final Map<String, dynamic> sinistre;

  const CompleterSinistreScreen({required this.sinistre, Key? key}) : super(key: key);

  @override
  State<CompleterSinistreScreen> createState() => _CompleterSinistreScreenState();
}

class _CompleterSinistreScreenState extends State<CompleterSinistreScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String titre;
  late String description;
  XFile? selectedFile;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    titre = widget.sinistre["titre"] ?? "";
    description = widget.sinistre["description"] ?? "";
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedFile = image;
      });
    }
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      setState(() {
        isSubmitting = true;
      });

      Map<String, String> data = {
        'titre': titre,
        'description': description,
      };

      final success = await ApiService.completerSinistre(
        widget.sinistre["id"]?.toString() ?? "",
        data,
        filePath: selectedFile?.path,
      );
      
      setState(() {
        isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dossier complété avec succès.')));
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la complétion du dossier.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Color(0xFF1B2430),
        elevation: 0,
        title: Text("Compléter mon dossier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message from manager
              if (widget.sinistre["commentaire"] != null) ...[
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
                          Icon(Icons.chat_bubble_outline, color: Colors.red[700], size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Message du gestionnaire",
                            style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.sinistre["commentaire"] ?? "",
                        style: TextStyle(color: Colors.red[900], fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],

              Text("Informations complémentaires", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 16),

              // Titre
              TextFormField(
                initialValue: titre,
                decoration: InputDecoration(
                  labelText: "Intitulé du sinistre",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                ),
                validator: (val) => val!.isEmpty ? "Requis" : null,
                onSaved: (val) => titre = val!,
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                initialValue: description,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: "Description détaillée des faits",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                ),
                validator: (val) => val!.isEmpty ? "Requis" : null,
                onSaved: (val) => description = val!,
              ),
              SizedBox(height: 24),

              Text("Nouveaux Justificatifs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 12),
              
              InkWell(
                onTap: pickImage,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: Colors.blue[600], size: 40),
                      SizedBox(height: 8),
                      Text(
                        selectedFile != null ? "Fichier sélectionné : ${selectedFile!.name}" : "Télécharger une photo ou un document",
                        style: TextStyle(color: Colors.blue[600], fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E2225),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isSubmitting 
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text("Envoyer le complément", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
