import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bna_widgets.dart';

/// Simulation de devis instantanée — reproduit le formulaire et le calcul du site web.
/// Champs : Age, Valeur du bien, Type, (AUTO: Âge véhicule + Puissance CV), Formule.
/// Résultat : Prime annuelle, niveau de Risque, Plafond Max estimé, Garanties incluses.
class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _Garantie {
  final String nom;
  final num montant;
  const _Garantie(this.nom, this.montant);
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ageController = TextEditingController();
  final valeurController = TextEditingController();
  final vehiculeAgeController = TextEditingController();
  final puissanceController = TextEditingController();

  String type = 'AUTO';
  String formule = 'TOUS_RISQUES';

  // Résultats
  double? prime;
  double? plafond;
  String? risque;
  List<_Garantie> garanties = [];

  static const Map<String, String> _types = {
    'AUTO': 'Auto',
    'HABITATION': 'Habitation',
    'SANTE': 'Santé',
    'VIE': 'Vie',
  };
  static const Map<String, String> _formules = {
    'TIERS_SIMPLE': 'Tiers simple',
    'TIERS_ETENDU': 'Tiers étendu',
    'TOUS_RISQUES': 'Tous risques',
    'TOUS_RISQUES_PREMIUM': 'Tous risques premium',
  };
  static const Map<String, double> _tauxFormule = {
    'TIERS_SIMPLE': 0.02,
    'TIERS_ETENDU': 0.04,
    'TOUS_RISQUES': 0.075,
    'TOUS_RISQUES_PREMIUM': 0.095,
  };
  static const Map<String, double> _typeFactor = {
    'AUTO': 1.0,
    'HABITATION': 0.6,
    'SANTE': 0.5,
    'VIE': 0.4,
  };

  bool get _isAuto => type == 'AUTO';

  @override
  void dispose() {
    ageController.dispose();
    valeurController.dispose();
    vehiculeAgeController.dispose();
    puissanceController.dispose();
    super.dispose();
  }

  String _fmt(num n) {
    final s = n.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return b.toString();
  }

  void _simuler() {
    if (!_formKey.currentState!.validate()) return;

    final valeur = double.tryParse(valeurController.text.trim()) ?? 0;
    final vAge = double.tryParse(vehiculeAgeController.text.trim()) ?? 0;
    final cv = double.tryParse(puissanceController.text.trim()) ?? 0;

    // ----- Facteurs liés au profil du véhicule (AUTO) -----
    double facteurVehicule = 1.0;
    int scoreRisque = 0;
    if (_isAuto) {
      if (vAge > 10) {
        facteurVehicule += 0.15;
        scoreRisque += 1;
      }
      if (vAge > 20) {
        facteurVehicule += 0.15;
        scoreRisque += 1;
      }
      if (cv > 7) {
        facteurVehicule += 0.10;
        scoreRisque += 1;
      }
      if (cv > 11) {
        facteurVehicule += 0.15;
        scoreRisque += 1;
      }
    }

    final p = valeur *
        (_tauxFormule[formule] ?? 0.05) *
        (_typeFactor[type] ?? 1.0) *
        facteurVehicule;

    // ----- Niveau de risque (selon profil du véhicule) -----
    String r;
    if (scoreRisque == 0) {
      r = 'FAIBLE';
    } else if (scoreRisque <= 2) {
      r = 'MODÉRÉ';
    } else {
      r = 'ÉLEVÉ';
    }

    // ----- Garanties incluses + plafond max -----
    final List<_Garantie> g = [];
    double plaf;
    if (_isAuto) {
      g.add(const _Garantie('Responsabilité Civile', 1000000));
      g.add(const _Garantie('Défense et Recours', 5000));
      if (formule != 'TIERS_SIMPLE') {
        g.add(_Garantie('Bris de Glace', valeur * 0.05));
        g.add(_Garantie('Vol et Incendie', valeur * 0.65));
      }
      if (formule == 'TOUS_RISQUES' || formule == 'TOUS_RISQUES_PREMIUM') {
        g.add(_Garantie('Dommages Tous Accidents', valeur));
      }
      plaf = 1000000 + valeur;
    } else if (type == 'HABITATION') {
      g.add(_Garantie('Incendie & Explosion', valeur));
      g.add(_Garantie('Dégât des eaux', valeur * 0.5));
      g.add(_Garantie('Vol & Vandalisme', valeur * 0.4));
      g.add(const _Garantie('Responsabilité Civile', 500000));
      plaf = 500000 + valeur;
    } else if (type == 'SANTE') {
      g.add(const _Garantie('Hospitalisation', 50000));
      g.add(const _Garantie('Consultations & Soins', 5000));
      g.add(const _Garantie('Pharmacie', 3000));
      plaf = 58000;
    } else {
      g.add(_Garantie('Capital décès', valeur > 0 ? valeur : 100000));
      g.add(_Garantie('Invalidité permanente', (valeur > 0 ? valeur : 100000) * 0.5));
      plaf = (valeur > 0 ? valeur : 100000) + (valeur > 0 ? valeur : 100000) * 0.5;
    }

    setState(() {
      prime = p;
      plafond = plaf;
      risque = r;
      garanties = g;
    });
  }

  Color get _risqueColor {
    switch (risque) {
      case 'MODÉRÉ':
        return AppColors.warning;
      case 'ÉLEVÉ':
        return AppColors.danger;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    const txt = TextStyle(color: AppColors.textPrimary);
    return BnaScaffold(
      title: "Simulation Devis",
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 86, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Text("💰  ",
                    style: TextStyle(fontSize: 20)),
                Text("Devis instantané",
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text("Estimez votre cotisation en quelques secondes.",
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 22),

            // ---------- Formulaire ----------
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: ageController,
                      style: txt,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Âge du client",
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Âge requis";
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 18 || n > 99) {
                          return "Âge entre 18 et 99";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: valeurController,
                      style: txt,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Valeur du bien (DT)",
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Valeur requise";
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return "Montant invalide";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: type,
                      dropdownColor: AppColors.surface,
                      style: txt,
                      decoration: const InputDecoration(
                        labelText: "Type assurance",
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _types.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        type = v!;
                        prime = null; // reset résultat si on change de type
                      }),
                    ),

                    // Champs spécifiques AUTO (comme le web)
                    if (_isAuto) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: vehiculeAgeController,
                        style: txt,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Âge du véhicule (années)",
                          prefixIcon: Icon(Icons.directions_car_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: puissanceController,
                        style: txt,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Puissance moteur (CV)",
                          prefixIcon: Icon(Icons.speed_outlined),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: formule,
                      dropdownColor: AppColors.surface,
                      style: txt,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: "Formule",
                        prefixIcon: Icon(Icons.workspace_premium_outlined),
                      ),
                      items: _formules.entries
                          .map((e) => DropdownMenuItem(
                              value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => formule = v!),
                    ),
                    const SizedBox(height: 22),
                    BnaGradientButton(
                      label: "Simuler",
                      icon: Icons.calculate_outlined,
                      onPressed: _simuler,
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Résultat ----------
            if (prime != null) ...[
              const SizedBox(height: 18),
              _resultCard(),
            ],

            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text("Quitter la simulation"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard() {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderColor: AppColors.primary.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prime + Risque
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text("💰 ", style: TextStyle(fontSize: 15)),
                        Text("Prime annuelle",
                            style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${_fmt(prime!)} DT",
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.w900)),
                    Text("≈ ${_fmt(prime! / 12)} DT / mois",
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Risque",
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 6),
                  BnaPill(text: risque ?? "FAIBLE", color: _risqueColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 14),

          // Plafond
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.cyan, size: 20),
              const SizedBox(width: 8),
              const Text("Plafond Max. estimé",
                  style: TextStyle(color: AppColors.textSecondary)),
              const Spacer(),
              Text("${_fmt(plafond ?? 0)} DT",
                  style: const TextStyle(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 18),

          // Garanties incluses
          const Text("Garanties incluses",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 10),
          ...garanties.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(g.nom,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  Text("${_fmt(g.montant)} DT",
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Risque évalué : ${risque ?? 'FAIBLE'} • Prime et garanties ajustées selon le profil.",
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
