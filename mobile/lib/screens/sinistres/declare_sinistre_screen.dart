import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';

class DeclareSinistreScreen extends StatefulWidget {
  @override
  State<DeclareSinistreScreen> createState() => _DeclareSinistreScreenState();
}

class _DeclareSinistreScreenState extends State<DeclareSinistreScreen> {
  final _formKey = GlobalKey<FormState>();

  String titre = '';
  String description = '';
  String adresse = '';
  String? contratId;
  double? latitude;
  double? longitude;
  XFile? selectedFile;
  DateTime dateIncident = DateTime.now();

  List contrats = [];
  bool isLoading = true;
  bool isSubmitting = false;

  final TextEditingController _adresseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContrats();
    _adresseController.addListener(() {
      if (_adresseController.text != adresse) {
        latitude = null;
        longitude = null;
      }
    });
  }

  void loadContrats() async {
    final data = await ApiService.getContrats();
    if (!mounted) return;
    setState(() {
      contrats = data;
      isLoading = false;
    });
  }

  int get _delaiJours => DateTime.now().difference(dateIncident).inDays;

  String _iso(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  String _fr(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dateIncident,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => dateIncident = picked);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedFile = image);
  }

  Future<void> determinePosition() async {
    setState(() => _adresseController.text = "Localisation en cours...");

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _adresseController.text = "");
      _snack('Les services de localisation sont désactivés.');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _adresseController.text = "");
        _snack('Permissions de localisation refusées.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _adresseController.text = "");
      _snack('Permissions refusées de façon permanente.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final lng = position.longitude;
      setState(() {
        latitude = lat;
        longitude = lng;
      });

      final apiKey = await ApiService.getMapKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        final url = Uri.parse(
            "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey");
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final results = resData['results'] as List?;
          if (results != null && results.isNotEmpty) {
            final cityResult = results.firstWhere(
              (r) {
                final types = r['types'] as List?;
                if (types == null) return false;
                return types.contains('locality') ||
                    types.contains('administrative_area_level_2') ||
                    types.contains('sublocality');
              },
              orElse: () => results.first,
            );
            setState(() {
              adresse = cityResult['formatted_address'] ?? "$lat, $lng";
              _adresseController.text = adresse;
            });
            return;
          }
        }
      }
      setState(() {
        adresse = "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
        _adresseController.text = adresse;
      });
    } catch (e) {
      setState(() => _adresseController.text = "");
      _snack('Erreur lors de la localisation.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (contratId == null) {
      _snack('Veuillez sélectionner un contrat.');
      return;
    }
    _formKey.currentState!.save();
    setState(() => isSubmitting = true);

    final data = <String, String>{
      'titre': titre,
      'description': description,
      'adresse': _adresseController.text,
      'contratId': contratId!,
      'dateIncident': _iso(dateIncident), // <-- NOUVEAU champ
    };
    if (latitude != null && longitude != null) {
      data['latitude'] = latitude.toString();
      data['longitude'] = longitude.toString();
    }

    final success =
        await ApiService.createSinistre(data, filePath: selectedFile?.path);

    if (!mounted) return;
    setState(() => isSubmitting = false);

    if (success) {
      _snack('Sinistre déclaré avec succès.');
      Navigator.pop(context, true);
    } else {
      _snack('Erreur lors de la déclaration du sinistre.');
    }
  }

  @override
  Widget build(BuildContext context) {
    const txt = TextStyle(color: AppColors.textPrimary);

    if (isLoading) {
      return const BnaScaffold(
        title: "Déclarer un sinistre",
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BnaScaffold(
      title: "Déclarer un sinistre",
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 86, 20, 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: "Informations sur l'incident",
                subtitle: "Renseignez les détails de votre déclaration.",
              ),
              const SizedBox(height: 18),
              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    // Contrat rattaché
                    DropdownButtonFormField<String>(
                      value: contratId,
                      dropdownColor: AppColors.surface,
                      style: txt,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Contrat rattaché",
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      items: contrats.map<DropdownMenuItem<String>>((c) {
                        return DropdownMenuItem<String>(
                          value: c['numero'],
                          child: Text("${c['numero']} - ${c['type']}",
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => contratId = val),
                      validator: (val) => val == null ? "Requis" : null,
                    ),
                    const SizedBox(height: 16),

                    // Titre
                    TextFormField(
                      style: txt,
                      decoration: const InputDecoration(
                        labelText: "Titre de l'incident",
                        hintText: "Ex: Accrochage sur le parking",
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Requis" : null,
                      onSaved: (v) => titre = v!,
                    ),
                    const SizedBox(height: 16),

                    // Date d'incident (NOUVEAU)
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Date de l'incident",
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        child: Text(_fr(dateIncident),
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bannière délai estimé
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.cyan.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.cyan, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Délai de déclaration estimé : $_delaiJours jour(s)",
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Text(
                                    _delaiJours == 0
                                        ? "Déclaration immédiate"
                                        : _delaiJours <= 5
                                            ? "Dans les délais"
                                            : "Déclaration tardive",
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      maxLines: 4,
                      style: txt,
                      decoration: const InputDecoration(
                        labelText: "Description circonstanciée",
                        hintText: "Détaillez les circonstances...",
                        alignLabelWithHint: true,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? "Requis" : null,
                      onSaved: (v) => description = v!,
                    ),
                    const SizedBox(height: 16),

                    // Adresse + Detect
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _adresseController,
                            style: txt,
                            decoration: const InputDecoration(
                              labelText: "Lieu & Localisation",
                              hintText: "Adresse exacte",
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? "Requis" : null,
                            onSaved: (v) => adresse = v!,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            tooltip: "Détecter ma position",
                            icon: const Icon(Icons.my_location,
                                color: Colors.white),
                            onPressed: determinePosition,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const SectionTitle(title: "Justificatifs (optionnel)"),
              const SizedBox(height: 12),
              InkWell(
                onTap: pickImage,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 26),
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_outlined,
                          color: AppColors.primaryLight, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        selectedFile != null
                            ? "Fichier : ${selectedFile!.name}"
                            : "Choisir un fichier (PNG, JPG, PDF)",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              BnaGradientButton(
                label: "Soumettre le dossier",
                icon: Icons.send,
                loading: isSubmitting,
                onPressed: submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
