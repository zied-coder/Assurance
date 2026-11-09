package com.example.demo.service;

import com.example.demo.model.*;
import com.example.demo.repository.*;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.Year;
import java.util.*;

@Service
public class ContratService {

    private final ContratRepository contratRepository;
    private final GarantieRepository garantieRepository;
    private final ObjetAssureRepository objetAssureRepository;
    private final UserRepository userRepository;
    private final PricingService pricingService;

    public ContratService(
            ContratRepository contratRepository,
            GarantieRepository garantieRepository,
            ObjetAssureRepository objetAssureRepository,
            UserRepository userRepository,
            PricingService pricingService
    ) {
        this.contratRepository = contratRepository;
        this.garantieRepository = garantieRepository;
        this.objetAssureRepository = objetAssureRepository;
        this.userRepository = userRepository;
        this.pricingService = pricingService;
    }

    // ================= NUMERO =================
    public String generateNumeroContrat() {

        Optional<Contrat> last = contratRepository.findTopByOrderByNumeroDesc();
        int next = 1;

        if (last.isPresent() && last.get().getNumero() != null) {
            try {
                String[] parts = last.get().getNumero().split("-");
                next = Integer.parseInt(parts[2]) + 1;
            } catch (Exception ignored) {}
        }

        return "CNT-" + Year.now().getValue() + "-" + String.format("%04d", next);
    }

    // ================= UTILS: calcul mois selon fréquence =================
    private int getMoisFrequence(String frequence) {
        if (frequence == null) return 12;
        switch (frequence.toUpperCase()) {
            case "MENSUEL":       return 1;
            case "TRIMESTRIEL":   return 3;
            case "SEMESTRIEL":    return 6;
            case "ANNUEL":
            default:              return 12;
        }
    }

    // ================= CREATE =================
    public Contrat createContratWithCin(Contrat contrat, String cin) {

        User user = userRepository.findByCin(cin)
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        contrat.setUserId(user.getId());
        contrat.setCin(cin);
        contrat.setNumero(generateNumeroContrat());
        contrat.setCreatedAt(new Date());

        // ============ Dates dynamiques selon durée et fréquence ============
        Date today = new Date();
        Calendar cal = Calendar.getInstance();
        cal.setTime(today);

        // Durée du contrat : 1 an par défaut
        int duree = contrat.getDuree() > 0 ? contrat.getDuree() : 1;
        cal.add(Calendar.YEAR, duree);
        Date dateFin = cal.getTime();

        // Prochaine échéance selon fréquence de paiement
        cal.setTime(today);
        int moisFrequence = getMoisFrequence(contrat.getFrequencePaiement());
        cal.add(Calendar.MONTH, moisFrequence);
        Date dateProchainPaiement = cal.getTime();

        contrat.setDateDebut(today);
        contrat.setDateFin(dateFin);
        contrat.setModePaiement(contrat.getModePaiement() != null ? contrat.getModePaiement() : "PRÉLÈVEMENT BANCAIRE");
        contrat.setDateProchainPaiement(dateProchainPaiement);
        contrat.setEtatPaiement(contrat.getEtatPaiement() != null ? contrat.getEtatPaiement() : "A_JOUR");

        Contrat saved = contratRepository.save(contrat);

        if (!"AUTO".equalsIgnoreCase(contrat.getType()) && !"HABITATION".equalsIgnoreCase(contrat.getType())) {
            // Pour SANTE / VIE (sans objet)
            saveGaranties(saved);
        }

        return saved;
    }

    // ================= CALCUL PRIX =================
    public double calculerPrix(Contrat contrat) {
        double total = 0;

        List<ObjetAssure> objets = objetAssureRepository.findByContratId(contrat.getId());

        if ("AUTO".equalsIgnoreCase(contrat.getType())) {
            for (ObjetAssure o : objets) {
                total += pricingService.calculerPrimeAuto(o.getValeurVehicule(), o.getAgeVehicule(), o.getPuissanceFiscale(), contrat.getFormule());
            }
        } else if ("HABITATION".equalsIgnoreCase(contrat.getType())) {
            for (ObjetAssure o : objets) {
                total += pricingService.calculerPrimeHabitation(o.getValeurBien(), o.getAgeBatiment(), o.getNiveauSecurite(), o.getZoneGeo(), contrat.getFormule());
            }
        } else if ("SANTE".equalsIgnoreCase(contrat.getType())) {
            for (ObjetAssure o : objets) {
                total += pricingService.calculerPrimeSante(o.getAgeAssure(), o.getAntecedentsMedicaux(), o.getProfession(), contrat.getFormule(), o.getSpecialitesMedicales(), o.isCouvertureHospitaliere());
            }
        } else if ("VIE".equalsIgnoreCase(contrat.getType())) {
            for (ObjetAssure o : objets) {
                total += pricingService.calculerPrimeVie(o.getAgeAssure(), o.getEtatSante(), o.getCapitalAssure(), contrat.getFormule());
            }
        }

        return Math.round(total);
    }

    // ================= ADD OBJET =================
    public ObjetAssure addObjetToContrat(String id, ObjetAssure objet) {

        Contrat contrat = getContratById(id);

        objet.setContratId(id);
        ObjetAssure saved = objetAssureRepository.save(objet);

        // 🔥 Générer ou mettre à jour les garanties de façon DYNAMIQUE avec le risque
        regenerateGarantiesWithRisk(contrat, saved);

        // 🔥 recalcul du prix après ajout
        double prix = calculerPrix(contrat);
        contrat.setPrime(prix);
        contratRepository.save(contrat);

        return saved;
    }

    private void regenerateGarantiesWithRisk(Contrat contrat, ObjetAssure objet) {
        List<Garantie> toDelete = garantieRepository.findByContratId(contrat.getId());
        garantieRepository.deleteAll(toDelete);

        List<Garantie> list = new ArrayList<>();
        String type = Optional.ofNullable(contrat.getType()).orElse("").toUpperCase();
        String formule = Optional.ofNullable(contrat.getFormule()).orElse("").toUpperCase();
        String riskLevel = "FAIBLE";

        if ("AUTO".equalsIgnoreCase(type)) {
            riskLevel = pricingService.evaluateRiskAuto(objet.getValeurVehicule(), objet.getAgeVehicule(), objet.getPuissanceFiscale());
            double valeur = objet.getValeurVehicule();
            
            // 🟢 TIERS (Essentiel)
            list.add(createGarantie("RESPONSABILITÉ CIVILE", 1000000));
            list.add(createGarantie("DÉFENSE ET RECOURS", 5000));
            
            // 🟡 TIERS ÉTENDU
            if ("TIERS_ETENDU".equals(formule) || "EXTENDED_THIRD_PARTY".equals(formule)) {
                list.add(createGarantie("BRIS DE GLACE", Math.round(valeur * 0.05)));
                list.add(createGarantie("VOL ET INCENDIE", Math.round(valeur * 0.65)));
            }
            
            // 🔵 TOUS RISQUES
            if ("TOUS_RISQUES".equals(formule) || "COMPREHENSIVE".equals(formule)) {
                list.add(createGarantie("BRIS DE GLACE", Math.round(valeur * 0.10)));
                list.add(createGarantie("VOL ET INCENDIE", Math.round(valeur * 0.75)));
                list.add(createGarantie("DOMMAGES COLLISION", Math.round(valeur * 0.90)));
            }
            
            // 🔴 PREMIUM
            if ("TOUS_RISQUES_PREMIUM".equals(formule) || "PREMIUM".equals(formule)) {
                list.add(createGarantie("BRIS DE GLACE (INTÉGRAL)", Math.round(valeur * 0.20)));
                list.add(createGarantie("VOL ET INCENDIE (INTÉGRAL)", Math.round(valeur * 0.95)));
                list.add(createGarantie("DOMMAGES TOUS ACCIDENTS", valeur));
                list.add(createGarantie("ASSISTANCE 24/7 0KM", 10000));
                list.add(createGarantie("PROTECTION DU CONDUCTEUR", 150000));
                list.add(createGarantie("VÉHICULE DE REMPLACEMENT", 5000));
            }
        } 
        else if ("HABITATION".equalsIgnoreCase(type)) {
            riskLevel = pricingService.evaluateRiskHabitation(objet.getValeurBien(), objet.getAgeBatiment(), objet.getNiveauSecurite(), objet.getZoneGeo());
            double valeur = objet.getValeurBien();
            
            // 🟢 BASIQUE
            list.add(createGarantie("INCENDIE ET EXPLOSION", Math.round(valeur * 0.8)));
            
            // 🟡 STANDARD
            if ("MOYEN".equals(formule) || "STANDARD".equals(formule) || "MOYENNE".equals(formule)) {
                list.add(createGarantie("DÉGÂTS DES EAUX", Math.round(valeur * 0.2)));
                list.add(createGarantie("VOL", Math.round(valeur * 0.1)));
            }
            
            // 🔵 PREMIUM
            if ("PREMIUM".equals(formule)) {
                // Override/Add for Premium
                list.removeIf(g -> g.getNom().equals("DÉGÂTS DES EAUX") || g.getNom().equals("VOL"));
                list.add(createGarantie("DÉGÂTS DES EAUX", Math.round(valeur * 0.3)));
                list.add(createGarantie("VOL", Math.round(valeur * 0.2)));
                list.add(createGarantie("VANDALISME", Math.round(valeur * 0.1)));
                list.add(createGarantie("RESPONSABILITÉ CIVILE OCCUPANT", 500000));
            }
        }
        else if ("SANTE".equalsIgnoreCase(type)) {
            riskLevel = pricingService.evaluateRiskSante(objet.getAgeAssure(), objet.getAntecedentsMedicaux(), objet.getProfession());
            double plafondBase = "PREMIUM".equals(formule) ? 10000 : ("MOYEN".equals(formule) || "MOYENNE".equals(formule) ? 5000 : 2000);
            
            // 🩺 Selected Specialties
            if (objet.getSpecialitesMedicales() != null) {
                for (String spec : objet.getSpecialitesMedicales()) {
                    list.add(createGarantie("SOINS : " + spec.toUpperCase(), plafondBase));
                }
            } else {
                list.add(createGarantie("SOINS COURANTS", plafondBase));
            }

            // 🏥 Hospitalization / Surgical
            if (objet.isCouvertureHospitaliere()) {
                list.add(createGarantie("HOSPITALISATION & SÉJOUR", plafondBase * 5));
                list.add(createGarantie("INTERVENTIONS CHIRURGICALES", plafondBase * 10));
            }
        }
        else if ("VIE".equalsIgnoreCase(type)) {
            riskLevel = pricingService.evaluateRiskVie(objet.getAgeAssure(), objet.getEtatSante(), objet.getCapitalAssure());
            double cap = objet.getCapitalAssure();
            list.add(createGarantie("DÉCÈS TOUTES CAUSES", cap));
            if (!"BASIQUE".equals(formule)) {
                list.add(createGarantie("INVALIDITÉ PARTIELLE", cap * 0.3));
            }
            if ("PREMIUM".equals(formule)) {
                list.add(createGarantie("RENTE ÉDUCATION", 20000));
                if (!riskLevel.contains("ÉLEVÉ")) {
                    list.add(createGarantie("INVALIDITÉ ABSOLUE ET DÉFINITIVE", cap * 0.8));
                }
            }
        }

        contrat.setRiskLevel(riskLevel);
        for (Garantie g : list) {
            g.setContratId(contrat.getId());
        }
        garantieRepository.saveAll(list);
    }

    // ================= GARANTIES =================
    private void saveGaranties(Contrat contrat) {

        List<Garantie> garanties = buildGaranties(contrat);

        for (Garantie g : garanties) {
            g.setContratId(contrat.getId());
        }

        garantieRepository.saveAll(garanties);
    }

    private List<Garantie> buildGaranties(Contrat contrat) {
        // We defer full generation until an object is added for AUTO/HABITATION
        // For SANTE/VIE we can generate essential defaults if needed, 
        // but regenerateGarantiesWithRisk is the source of truth now.
        return new ArrayList<>();
    }

    private Garantie createGarantie(String nom, double plafond) {
        Garantie g = new Garantie();
        g.setNom(nom);
        g.setPlafond(plafond);
        return g;
    }

    // ================= REST =================
    public Contrat getContratById(String id) {
        return contratRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Contrat non trouvé"));
    }

    public List<Contrat> getAllContrats() {
        return contratRepository.findAll();
    }

    public List<Contrat> getContratsByUser(String username) {

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        return contratRepository.findByUserId(user.getId());
    }

    public Map<String, Object> getContratFull(String id) {

        Map<String, Object> result = new HashMap<>();
        Contrat contrat = getContratById(id);

        result.put("contrat", contrat);
        result.put("garanties", garantieRepository.findByContratId(id));
        result.put("objets", objetAssureRepository.findByContratId(id));

        // 🔥 Ajout des infos utilisateur pour l'affichage
        if (contrat.getUserId() != null) {
            userRepository.findById(contrat.getUserId()).ifPresent(u -> {
                result.put("userEmail", u.getEmail());
                result.put("userCin", u.getCin());
            });
        }

        return result;
    }

    public void deleteContrat(String id) {

        garantieRepository.deleteByContratId(id);
        objetAssureRepository.deleteByContratId(id);
        contratRepository.deleteById(id);
    }

    // ================= PDF =================
    public byte[] generatePdf(String contratId) {

        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();

            PdfWriter writer = new PdfWriter(out);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            Contrat contrat = getContratById(contratId);
            List<Garantie> garanties = garantieRepository.findByContratId(contratId);
            List<ObjetAssure> objets = objetAssureRepository.findByContratId(contratId);

            document.add(new Paragraph("===== CONTRAT ASSURANCE ====="));
            document.add(new Paragraph("Numéro: " + contrat.getNumero()));
            document.add(new Paragraph("Type: " + contrat.getType()));
            document.add(new Paragraph("Formule: " + contrat.getFormule()));

            // 🔥 Infos Assuré
            if (contrat.getUserId() != null) {
                userRepository.findById(contrat.getUserId()).ifPresent(u -> {
                    document.add(new Paragraph("Assuré: " + u.getEmail() + " (CIN: " + u.getCin() + ")"));
                });
            }

            if (contrat.getRiskLevel() != null) {
                document.add(new Paragraph("Niveau de Risque: " + contrat.getRiskLevel()));
            }
            document.add(new Paragraph("Prime: " + contrat.getPrime() + " TND"));

            document.add(new Paragraph("---- GARANTIES ----"));
            for (Garantie g : garanties) {
                document.add(new Paragraph(g.getNom() + " : " + g.getPlafond()));
            }

            document.add(new Paragraph("---- OBJETS ----"));
            for (ObjetAssure o : objets) {
                document.add(new Paragraph(o.getMarque() + " " + o.getModele()));
            }

            document.close();
            return out.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Erreur PDF", e);
        }
    }

    public Contrat payContrat(String id, Map<String, String> paymentDetails) {
        Contrat contrat = getContratById(id);
        contrat.setEtatPaiement("A_JOUR");
        contrat.setDateProchainPaiement(new Date(System.currentTimeMillis() + 365L * 24 * 60 * 60 * 1000)); // +1 year
        return contratRepository.save(contrat);
    }

    public byte[] generateReceiptPdf(String contratId) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();

            PdfWriter writer = new PdfWriter(out);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);

            Contrat contrat = getContratById(contratId);

            document.add(new Paragraph("========================================="));
            document.add(new Paragraph("      BNA ASSURANCE - REÇU DE PAIEMENT      "));
            document.add(new Paragraph("========================================="));
            document.add(new Paragraph("\n"));
            document.add(new Paragraph("Référence Contrat : " + contrat.getNumero()));
            document.add(new Paragraph("Type de Contrat : " + contrat.getType()));
            document.add(new Paragraph("Formule choisie : " + contrat.getFormule()));

            if (contrat.getUserId() != null) {
                userRepository.findById(contrat.getUserId()).ifPresent(u -> {
                    document.add(new Paragraph("Souscripteur : " + u.getEmail() + " (CIN: " + u.getCin() + ")"));
                });
            }

            document.add(new Paragraph("\n-----------------------------------------"));
            document.add(new Paragraph("Date du Paiement : " + new Date()));
            document.add(new Paragraph("Montant Réglé : " + contrat.getPrime() + " TND"));
            document.add(new Paragraph("Mode de Règlement : CARTE BANCAIRE"));
            document.add(new Paragraph("Statut : VALIDÉ & PAYÉ"));
            document.add(new Paragraph("Référence Transaction : TXN-" + System.currentTimeMillis()));
            document.add(new Paragraph("-----------------------------------------\n"));

            document.add(new Paragraph("Merci pour votre confiance."));
            document.add(new Paragraph("BNA Assurance, à vos côtés chaque jour."));

            document.close();
            return out.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Erreur de génération du reçu", e);
        }
    }
}