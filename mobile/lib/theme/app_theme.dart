import 'package:flutter/material.dart';

/// Palette "BNA" — light / premium (identité du site web).
class AppColors {
  // Fond dégradé
  static const Color bg1 = Color(0xFFF4F6FB); // light grayish blue (fond général)
  static const Color bg2 = Color(0xFFFFFFFF); // blanc (surfaces)

  // Bleu principal (boutons, liens)
  static const Color primary = Color(0xFF2B3990); // Royal Blue officiel
  static const Color primaryLight = Color(0xFF3D4FA8);

  // Accents
  static const Color cyan = Color(0xFF00A2C6);
  static const Color teal = Color(0xFF00843D); // vert logo BNA

  // Surfaces / verre
  static const Color surface = Color(0xFFFFFFFF);
  static const Color glassFill = Color(0xFFEEF0FB); // lavande-bleu très doux (inputs)
  static const Color glassBorder = Color(0xFFE2E6F3); // bordure subtile

  // Texte
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // États
  static const Color success = Color(0xFF00843D);
  static const Color warning = Color(0xFFC47800);
  static const Color danger = Color(0xFFB30000);

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bg1, bg1],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryLight],
  );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg1,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      // AppBar style
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      iconTheme: const IconThemeData(color: AppColors.textPrimary),

      // Champs de formulaire (type Image 1).
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.primary),

      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),

      dividerColor: Colors.black.withOpacity(0.08),
    );
  }
}
