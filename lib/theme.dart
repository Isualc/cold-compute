import 'package:flutter/material.dart';

/// Visual language for the global situation room.
///
/// The palette deliberately avoids generic purple cyberpunk. Cool map/data
/// signals, warm policy warnings and a near-black editorial canvas make the
/// simulated world state readable even on a small phone.
class AppTheme {
  static const Color bg = Color(0xFF050A10);
  static const Color bgRaised = Color(0xFF09131B);
  static const Color surface = Color(0xFF0E1B24);
  static const Color surfaceHigh = Color(0xFF142936);
  static const Color surfaceGlass = Color(0xE612222D);
  static const Color line = Color(0xFF29424D);
  static const Color lineSoft = Color(0x662F5361);

  static const Color amber = Color(0xFFFFC34D);
  static const Color teal = Color(0xFF28BFB1);
  static const Color tealBright = Color(0xFF65E3D0);
  static const Color blue = Color(0xFF62C8FF);
  static const Color red = Color(0xFFFF5A61);
  static const Color danger = Color(0xFFFF4567);
  static const Color green = Color(0xFF57D69A);
  static const Color covert = Color(0xFF9B7CFF);
  static const Color textPrimary = Color(0xFFF3F4EE);
  static const Color textSecondary = Color(0xFF91A5AE);
  static const Color textFaint = Color(0xFF5D747E);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07121B), bg, Color(0xFF081018)],
    stops: [0, .52, 1],
  );

  static Color valueColor(double value, {bool inverted = false}) {
    final score = inverted ? 100 - value : value;
    if (score >= 66) return green;
    if (score >= 36) return amber;
    return danger;
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: tealBright,
      secondary: amber,
      surface: surface,
      error: danger,
      onPrimary: bg,
      onSecondary: bg,
      onSurface: textPrimary,
      onError: Colors.white,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _SituationRoomTransitionsBuilder(),
          TargetPlatform.iOS: _SituationRoomTransitionsBuilder(),
          TargetPlatform.windows: _SituationRoomTransitionsBuilder(),
          TargetPlatform.macOS: _SituationRoomTransitionsBuilder(),
          TargetPlatform.linux: _SituationRoomTransitionsBuilder(),
        },
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: lineSoft),
        ),
      ),
      dividerTheme: const DividerThemeData(color: lineSoft, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: const Color(0xF20A151D),
        indicatorColor: tealBright.withValues(alpha: .13),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? textPrimary
                : textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: .6,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? tealBright
                : textSecondary,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 54)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          ),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.disabled) ? line : tealBright,
          ),
          foregroundColor: const WidgetStatePropertyAll(bg),
          overlayColor: WidgetStatePropertyAll(
            Colors.white.withValues(alpha: .2),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          foregroundColor: const WidgetStatePropertyAll(textPrimary),
          side: const WidgetStatePropertyAll(BorderSide(color: line)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          foregroundColor: const WidgetStatePropertyAll(textSecondary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: tealBright,
        linearTrackColor: surfaceHigh,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          color: textPrimary,
          fontSize: 52,
          height: .95,
          fontWeight: FontWeight.w900,
          letterSpacing: -2.2,
        ),
        headlineLarge: const TextStyle(
          color: textPrimary,
          fontSize: 32,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
        ),
        headlineMedium: const TextStyle(
          color: textPrimary,
          fontSize: 26,
          height: 1.12,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
        titleLarge: const TextStyle(
          color: textPrimary,
          fontSize: 19,
          height: 1.2,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: const TextStyle(
          color: textPrimary,
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: const TextStyle(
          color: textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          color: textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodySmall: const TextStyle(
          color: textSecondary,
          fontSize: 12.5,
          height: 1.42,
        ),
        labelLarge: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class _SituationRoomTransitionsBuilder extends PageTransitionsBuilder {
  const _SituationRoomTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .025),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
