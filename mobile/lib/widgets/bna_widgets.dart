import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Fond dégradé navy + watermark "BNA" (comme le site web).
class BnaBackground extends StatelessWidget {
  final Widget child;
  final bool watermark;
  const BnaBackground({super.key, required this.child, this.watermark = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: Stack(
        children: [
          if (watermark)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Opacity(
                    opacity: 0.035,
                    child: Text(
                      "BNA",
                      style: TextStyle(
                        fontSize: 200,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// Scaffold prêt-à-l'emploi : fond BNA + AppBar transparente optionnelle.
class BnaScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool watermark;
  final bool showAppBar;
  const BnaScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.watermark = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: (showAppBar && title != null)
          ? AppBar(title: Text(title!), actions: actions)
          : null,
      floatingActionButton: floatingActionButton,
      body: BnaBackground(
        watermark: watermark,
        child: SafeArea(top: !(showAppBar && title != null), child: body),
      ),
    );
  }
}

/// Carte "verre" translucide avec bordure subtile.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final Color? borderColor;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = 20,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Bouton dégradé bleu (CTA principal), avec halo lumineux.
class BnaGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  const BnaGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: loading ? null : onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: Colors.white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Petit badge pilule (ex: "INNOVATION & CONFIANCE", "Disponible 24/7").
class BnaPill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  const BnaPill({super.key, required this.text, this.color = AppColors.primary, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class BnaLogo extends StatelessWidget {
  final double size;
  const BnaLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: Image.asset(
          'assets/images/bna-logo.png',
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }
}

/// Bouton chatbot flottant (rond, sombre) comme sur le web.
class BnaChatFab extends StatelessWidget {
  final VoidCallback onPressed;
  const BnaChatFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.surface,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.glassBorder),
        ),
        child: const Icon(Icons.forum_outlined, color: Colors.white),
      ),
    );
  }
}

/// Titre de section (texte blanc gras, optionnel sous-titre gris).
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextAlign align;
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final cross = align == TextAlign.center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(
          title,
          textAlign: align,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: align,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
