import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared visual language. Iris and coral replace the old teal pairing.
/// An aurora sits behind the app; search and navigation frost over it.
/// Cards and an opened event use one gloss gradient, never a flat fill.
abstract final class AstraeaTokens {
  static const iris = Color(0xFF6A35F0);
  static const coral = Color(0xFFFF4F78);
  static const ink = Color(0xFF1C1233);
  static const canvas = Color(0xFFF6EEFF);
  static const nightCanvas = Color(0xFF160C28);
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

/// Desk colours. Dark is its own iris night, not an inversion of the light
/// paper. Screens read these instead of inventing hex values.
class AstraeaPalette {
  const AstraeaPalette({
    required this.background,
    required this.paper,
    required this.paperRaised,
    required this.paperInset,
    required this.paperPressed,
    required this.ink,
    required this.inkMuted,
    required this.coral,
    required this.onCoral,
    required this.coralContainer,
    required this.onCoralContainer,
    required this.border,
    required this.shadow,
    required this.glow,
  });

  final Color background;
  final Color paper;
  final Color paperRaised;
  final Color paperInset;
  final Color paperPressed;
  final Color ink;
  final Color inkMuted;
  final Color coral;
  final Color onCoral;
  final Color coralContainer;
  final Color onCoralContainer;
  final Color border;
  final Color shadow;
  final List<Color> glow;

  static const light = AstraeaPalette(
    background: Color(0xFFF6EEFF),
    paper: Color(0xFFF8F2FF),
    paperRaised: Color(0xFFFFF7FB),
    paperInset: Color(0xFFE7D8FF),
    paperPressed: Color(0xFFE6D6FF),
    ink: Color(0xFF1C1233),
    inkMuted: Color(0xFF4A3868),
    coral: Color(0xFFFF4F78),
    onCoral: Color(0xFFFFFFFF),
    coralContainer: Color(0xFFFFD6E4),
    onCoralContainer: Color(0xFF5A1830),
    border: Color(0x66FFFFFF),
    shadow: Color(0xFF3A1870),
    glow: [
      Color(0xFFFFD0E6),
      Color(0xFFE4D0FF),
      Color(0xFFFFE0C4),
      Color(0xFFD4E2FF),
    ],
  );

  static const dark = AstraeaPalette(
    background: Color(0xFF160C28),
    paper: Color(0xFF241438),
    paperRaised: Color(0xFF321C4C),
    paperInset: Color(0xFF1C1030),
    paperPressed: Color(0xFF3A2468),
    ink: Color(0xFFF8F2FF),
    inkMuted: Color(0xFFD2C4F2),
    coral: Color(0xFFFF8AA8),
    onCoral: Color(0xFF3A1020),
    coralContainer: Color(0xFF4A2040),
    onCoralContainer: Color(0xFFFFE4EE),
    border: Color(0x55FFFFFF),
    shadow: Color(0xFF000000),
    glow: [
      Color(0xFF2A0E44),
      Color(0xFF4A1868),
      Color(0xFF6A2458),
      Color(0xFF1A1860),
    ],
  );

  static AstraeaPalette of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? AstraeaPalette.dark : AstraeaPalette.light;
  }
}

/// Black or white, whichever clears [background] by the higher WCAG ratio.
Color readableTextColorOn(Color background) {
  final luminance = background.computeLuminance();
  final onBlack = _contrastRatio(luminance, 0);
  final onWhite = _contrastRatio(luminance, 1);
  return onBlack >= onWhite ? Colors.black : Colors.white;
}

/// Softer than [readableTextColorOn], still at least 4.5:1 on [background].
Color mutedTextColorOn(Color background) {
  final ink = readableTextColorOn(background);
  var lo = 0.0;
  var hi = 1.0;
  var best = ink;
  for (var i = 0; i < 10; i++) {
    final mid = (lo + hi) / 2;
    final candidate = Color.alphaBlend(ink.withValues(alpha: mid), background);
    final ratio = _contrastRatio(
      candidate.computeLuminance(),
      background.computeLuminance(),
    );
    if (ratio >= 4.5) {
      best = candidate;
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return best;
}

double _contrastRatio(double luminanceA, double luminanceB) {
  final lighter = luminanceA > luminanceB ? luminanceA : luminanceB;
  final darker = luminanceA > luminanceB ? luminanceB : luminanceA;
  return (lighter + 0.05) / (darker + 0.05);
}

ThemeData astraeaTheme({required Brightness brightness, required Color seed}) {
  final dark = brightness == Brightness.dark;
  final palette = dark ? AstraeaPalette.dark : AstraeaPalette.light;
  final base = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final colors = base.copyWith(
    secondary: palette.coral,
    onSecondary: palette.onCoral,
    secondaryContainer: palette.coralContainer,
    onSecondaryContainer: palette.onCoralContainer,
    surface: palette.background,
    surfaceContainerLowest: palette.paper,
    surfaceContainerLow: palette.paperRaised,
    surfaceContainer: palette.paperInset,
    surfaceContainerHigh: palette.paperRaised,
    surfaceContainerHighest: palette.paperPressed,
    onSurface: palette.ink,
    onSurfaceVariant: palette.inkMuted,
    outline: palette.inkMuted,
    outlineVariant: palette.border,
    shadow: palette.shadow,
  );
  final text = Typography.material2021(platform: TargetPlatform.iOS).black;

  return ThemeData(
    colorScheme: colors,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: text.bodyMedium?.fontFamily,
    textTheme: text
        .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface)
        .copyWith(
          headlineMedium: text.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            color: colors.onSurface,
          ),
          headlineSmall: text.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: colors.onSurface,
          ),
          titleLarge: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
          titleMedium: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
          labelLarge: text.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      titleTextStyle: text.titleLarge?.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colors.onSurface.withValues(alpha: dark ? 0.16 : 0.12),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerLow.withValues(alpha: dark ? 0.7 : 0.8),
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
      color: colors.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusMd),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.paper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AstraeaTokens.radiusLg),
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

/// Aurora behind every screen. Scaffolds stay transparent so this shows
/// through frosted search and navigation.
class AstraeaBackdrop extends StatelessWidget {
  const AstraeaBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final glow = AstraeaPalette.of(context).glow;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: glow,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

/// Top-to-bottom gloss. Cards and an opened event both paint this, so
/// opening an event is the card at full size rather than a flat fill.
LinearGradient astraeaSheetGradient(Color tint) {
  final lightInk = readableTextColorOn(tint) == Colors.white;
  final wash = lightInk ? 0.10 : 0.42;
  final top = Color.alphaBlend(Colors.white.withValues(alpha: wash), tint);
  return LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [top, tint],
  );
}

/// Night desk keeps light type. A bright tint that would force black text
/// (a blue event on the dark aurora) is deepened until white clears both
/// ends of the gloss.
Color astraeaDarkTint(Color tint) {
  var current = tint;
  for (var step = 0; step < 16; step++) {
    if (_whiteClearsGloss(current)) return current;
    current = Color.alphaBlend(const Color(0x1F000000), current);
  }
  return current;
}

bool _whiteClearsGloss(Color tint) {
  // A little above 4.5: the ink that actually gets painted is not pure
  // white, and the lighter end of the gloss is the harder background.
  final top = astraeaSheetGradient(tint).colors.first;
  final topClears = _contrastRatio(top.computeLuminance(), 1) >= 4.8;
  final baseClears = _contrastRatio(tint.computeLuminance(), 1) >= 4.8;
  return topClears && baseClears;
}

/// The gloss stop where [ink] has the weaker contrast.
Color _hardestStop(Color tint, Color ink) {
  final top = astraeaSheetGradient(tint).colors.first;
  final topRatio = _contrastRatio(
    top.computeLuminance(),
    ink.computeLuminance(),
  );
  final baseRatio = _contrastRatio(
    tint.computeLuminance(),
    ink.computeLuminance(),
  );
  return topRatio < baseRatio ? top : tint;
}

BoxDecoration astraeaGlossDecoration({
  required Color tint,
  required bool dark,
  double radius = AstraeaTokens.radiusMd,
  bool border = true,
  List<BoxShadow>? shadow,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: astraeaSheetGradient(tint),
    border: border
        ? Border.all(
            color: dark ? const Color(0x66FFFFFF) : const Color(0xEEFFFFFF),
          )
        : null,
    boxShadow: shadow,
  );
}

/// Full-bleed gloss of [tint]. The child inherits ink that clears that tint.
class AstraeaSheet extends StatelessWidget {
  const AstraeaSheet({
    super.key,
    required this.tint,
    required this.child,
    this.radius,
  });

  final Color tint;
  final Widget child;

  /// When set, clips to this radius. A bottom sheet uses the top corners only.
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final paint = dark ? astraeaDarkTint(tint) : tint;
    final painted = DecoratedBox(
      decoration: BoxDecoration(gradient: astraeaSheetGradient(paint)),
      child: _inkScope(_sheetTheme(Theme.of(context), paint), child),
    );
    final radius = this.radius;
    if (radius == null) return painted;
    return ClipRRect(borderRadius: radius, child: painted);
  }
}

ThemeData _sheetTheme(ThemeData theme, Color tint) {
  final ink = readableTextColorOn(tint);
  final muted = mutedTextColorOn(_hardestStop(tint, ink));
  final lightInk = ink == Colors.white;
  final lifted = Color.alphaBlend(
    Colors.white.withValues(alpha: lightInk ? 0.12 : 0.34),
    tint,
  );
  final colors = theme.colorScheme.copyWith(
    surface: tint,
    surfaceContainerLowest: lifted,
    surfaceContainerLow: lifted,
    surfaceContainer: lifted,
    onSurface: ink,
    onSurfaceVariant: muted,
  );
  return theme.copyWith(
    colorScheme: colors,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: theme.textTheme.apply(bodyColor: ink, displayColor: ink),
    iconTheme: theme.iconTheme.copyWith(color: ink),
    dividerTheme: theme.dividerTheme.copyWith(
      color: ink.withValues(alpha: 0.22),
    ),
    appBarTheme: theme.appBarTheme.copyWith(
      foregroundColor: ink,
      iconTheme: IconThemeData(color: ink),
      titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(color: ink),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: lightInk ? Brightness.light : Brightness.dark,
        statusBarBrightness: lightInk ? Brightness.dark : Brightness.light,
      ),
    ),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      fillColor: Colors.white.withValues(alpha: lightInk ? 0.08 : 0.45),
      hintStyle: TextStyle(color: muted),
    ),
  );
}

/// [Theme] updates [Theme.of] but leaves the surrounding [DefaultTextStyle]
/// in place, so a plain [Text] kept the desk ink and disappeared on a blue
/// event. The scope paints that ink onto both.
Widget _inkScope(ThemeData data, Widget child) {
  final ink = data.colorScheme.onSurface;
  final icon = data.iconTheme.color ?? ink;
  return Theme(
    data: data,
    child: DefaultTextStyle.merge(
      style: TextStyle(color: ink),
      child: IconTheme.merge(
        data: IconThemeData(color: icon),
        child: child,
      ),
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
    this.borderRadius,
    this.tint,
    this.blur = 18,
    this.border = true,
    this.shadow = true,
    this.frosted = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final BorderRadius? borderRadius;
  final Color? tint;
  final double blur;
  final bool border;
  final bool shadow;

  /// Frost is for search and navigation only. A blur on every card is how a
  /// scrolling list gets sticky, so cards use [frosted] false and a gloss.
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = borderRadius ?? BorderRadius.circular(radius);
    final fill = tint ?? Theme.of(context).colorScheme.surfaceContainerLowest;
    final paint = (dark && tint != null) ? astraeaDarkTint(fill) : fill;
    final painted = frosted
        ? _frost(context, shape, dark)
        : _gloss(context, shape, paint, dark);
    return Container(
      margin: margin,
      decoration: shadow ? _shadow(context, paint, shape, dark) : null,
      child: painted,
    );
  }

  Widget _frost(BuildContext context, BorderRadius shape, bool dark) {
    final fill = dark ? const Color(0xCC241438) : const Color(0xBFFFFFFF);
    final edge = dark ? const Color(0x55FFFFFF) : const Color(0xEEFFFFFF);
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: shape,
            border: border ? Border.all(color: edge) : null,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: dark ? 0.16 : 0.55),
                fill,
              ],
            ),
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }

  Widget _gloss(
    BuildContext context,
    BorderRadius shape,
    Color fill,
    bool dark,
  ) {
    final content = Padding(padding: padding ?? EdgeInsets.zero, child: child);
    return DecoratedBox(
      decoration: astraeaGlossDecoration(
        tint: fill,
        dark: dark,
        border: border,
      ).copyWith(borderRadius: shape),
      child: tint == null ? content : _inkTheme(context, fill, content),
    );
  }

  Widget _inkTheme(BuildContext context, Color fill, Widget content) {
    final theme = Theme.of(context);
    final ink = readableTextColorOn(fill);
    final muted = mutedTextColorOn(_hardestStop(fill, ink));
    return _inkScope(
      theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          onSurface: ink,
          onSurfaceVariant: muted,
        ),
        textTheme: theme.textTheme.apply(bodyColor: ink, displayColor: ink),
        iconTheme: theme.iconTheme.copyWith(color: muted),
      ),
      content,
    );
  }

  BoxDecoration _shadow(
    BuildContext context,
    Color fill,
    BorderRadius shape,
    bool dark,
  ) {
    final color = frosted
        ? Colors.black.withValues(alpha: dark ? 0.28 : 0.08)
        : fill.withValues(alpha: dark ? 0.36 : 0.16);
    return BoxDecoration(
      borderRadius: shape,
      boxShadow: [
        BoxShadow(color: color, blurRadius: 22, offset: const Offset(0, 10)),
      ],
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
      frosted: true,
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
