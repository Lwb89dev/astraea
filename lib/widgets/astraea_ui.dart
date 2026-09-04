import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The small, shared visual language used by Astraea's screens.
abstract final class AstraeaTokens {
  static const ink = Color(0xFF17202B);
  static const canvas = Color(0xFFF5F7FB);
  static const nightCanvas = Color(0xFF0B111B);
  static const violet = Color(0xFF6674D9);
  static const cyan = Color(0xFF5CB8C8);
  static const warm = Color(0xFFE7A35A);
  static const radiusSm = 14.0;
  static const radiusMd = 22.0;
  static const radiusLg = 30.0;
  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 24.0;
  static const space6 = 32.0;
  static const shortMotion = Duration(milliseconds: 180);
  static const mediumMotion = Duration(milliseconds: 280);
  static const motionCurve = Curves.easeOutCubic;

  static Duration motion(BuildContext context, Duration duration) =>
      MediaQuery.maybeOf(context)?.disableAnimations == true
      ? Duration.zero
      : duration;
}

ThemeData astraeaTheme({required Brightness brightness, required Color seed}) {
  final dark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final colors = base.copyWith(
    surface: dark ? const Color(0xFF101824) : AstraeaTokens.canvas,
    surfaceContainerLowest: dark
        ? const Color(0xFF0B111B)
        : const Color(0xFFF9FAFD),
    surfaceContainerLow: dark
        ? const Color(0xFF131D2A)
        : const Color(0xFFF0F3F9),
    surfaceContainer: dark ? const Color(0xFF172231) : const Color(0xFFEAEFF7),
    surfaceContainerHigh: dark
        ? const Color(0xFF1C293A)
        : const Color(0xFFE3E8F2),
    surfaceContainerHighest: dark
        ? const Color(0xFF243347)
        : const Color(0xFFDCE3EF),
    onSurface: dark ? const Color(0xFFE9EEF8) : AstraeaTokens.ink,
    onSurfaceVariant: dark ? const Color(0xFFAFBBCD) : const Color(0xFF5F6B7D),
    outline: dark ? const Color(0xFF526278) : const Color(0xFFB9C4D4),
    outlineVariant: dark ? const Color(0xFF2B394C) : const Color(0xFFD4DBE7),
  );
  final text = Typography.material2021(platform: TargetPlatform.iOS).black;

  return ThemeData(
    colorScheme: colors,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: colors.surface,
    fontFamily: text.bodyMedium?.fontFamily,
    textTheme: text
        .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface)
        .copyWith(
          headlineMedium: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          headlineSmall: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.outlineVariant.withValues(alpha: dark ? 0.7 : 0.9),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow.withValues(
        alpha: dark ? 0.85 : 0.8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),
    cardTheme: CardThemeData(
      color: colors.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusMd),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}

class AstraeaGlassSurface extends StatelessWidget {
  const AstraeaGlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = AstraeaTokens.radiusMd,
    this.tint,
    this.blur = 12,
    this.border = true,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? tint;
  final double blur;
  final bool border;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = tint ?? scheme.surfaceContainerHigh;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: border
          ? BorderSide(color: scheme.onSurface.withValues(alpha: 0.09))
          : BorderSide.none,
    );
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: fill.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.72
                  : 0.78,
            ),
            shape: shape,
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
    return Container(
      margin: margin,
      decoration: shadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.07,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            )
          : null,
      child: content,
    );
  }
}

class AstraeaIconButton extends StatelessWidget {
  const AstraeaIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: selected
              ? scheme.primary.withValues(alpha: 0.16)
              : scheme.surfaceContainerLow.withValues(alpha: 0.72),
          foregroundColor: selected ? scheme.primary : scheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AstraeaTokens.radiusSm),
          ),
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class AstraeaFloatingBar extends StatelessWidget {
  const AstraeaFloatingBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(6),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AstraeaGlassSurface(
      radius: AstraeaTokens.radiusLg,
      padding: padding,
      blur: 18,
      child: child,
    );
  }
}

class AstraeaSection extends StatelessWidget {
  const AstraeaSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
