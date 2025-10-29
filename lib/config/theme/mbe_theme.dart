import 'package:flutter/material.dart';

/// MBE Mailboxes - Design System Theme
/// Colores de marca: Negro (primario) y Rojo Pantone 485 C
/// Diseño inspirado en Grab: limpio, espaciado, sombras suaves
class MBETheme {
  MBETheme._();

  // 🎨 Brand Colors
  static const Color brandBlack = Color(0xFF000000);
  static const Color brandRed = Color(0xFFED1C24); // Pantone 485 C
  static const Color brandRedDark = Color(0xFFDA291C);
  
  // Supporting colors
  static const Color neutralGray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF3F4F6); // Background estilo Grab ✨
  static const Color darkGray = Color(0xFF1F2937);

  /// ☀️ Light Theme - AJUSTADO ESTILO GRAB
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    
    // Scaffold background gris claro por defecto
    scaffoldBackgroundColor: lightGray,
    
    colorScheme: ColorScheme.light(
      primary: brandBlack,
      secondary: brandRed,
      tertiary: neutralGray,
      error: brandRed,
      surface: Colors.white, // Cards blancas
      surfaceContainerHighest: lightGray,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: brandBlack,
      onSurfaceVariant: neutralGray,
      outline: neutralGray.withOpacity(0.3),
      outlineVariant: neutralGray.withOpacity(0.1),
    ),

    // Typography - Profesional y legible
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    ),

    // Card Theme - AJUSTADO ESTILO GRAB ✨
    cardTheme: CardThemeData(
      elevation: 0, // Sin elevation, usamos boxShadow manual
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05), // Sombra muy sutil
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Radio grande
      ),
      margin: EdgeInsets.zero,
    ),

    // AppBar Theme - FONDO BLANCO ESTILO GRAB ✨
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white, // Fondo blanco
      foregroundColor: brandBlack,
      surfaceTintColor: Colors.transparent,
    ),

    // Button Themes
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brandBlack,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Sin elevation
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        foregroundColor: brandBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brandBlack,
        side: BorderSide(
          color: neutralGray.withOpacity(0.2), // Borde más sutil
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        minimumSize: const Size(64, 48),
      ),
    ),

    // FAB Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: brandRed,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    // Progress Indicator
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: brandBlack,
      linearTrackColor: neutralGray.withOpacity(0.15),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: neutralGray.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),

    // Bottom Sheet - ESTILO GRAB ✨
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
  );

  /// 🌙 Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
      secondary: brandRed,
      tertiary: neutralGray,
      error: brandRed,
      surface: const Color(0xFF1E1E1E),
      surfaceContainerHighest: darkGray,
      onPrimary: brandBlack,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFFB0B0B0),
      outline: neutralGray.withOpacity(0.3),
      outlineVariant: neutralGray.withOpacity(0.1),
    ),
    textTheme: lightTheme.textTheme,
    cardTheme: lightTheme.cardTheme?.copyWith(
      color: const Color(0xFF1E1E1E),
    ),
    appBarTheme: lightTheme.appBarTheme?.copyWith(
      backgroundColor: const Color(0xFF121212),
      foregroundColor: Colors.white,
    ),
  );

  // ✨ Shadows - MÁS SUTILES ESTILO GRAB ✨
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.03), // Muy sutil
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05), // Sutil
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08), // Poco más visible
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // Sombra para bottom navigation (hacia arriba)
  static List<BoxShadow> get shadowTop => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -4),
        ),
      ];

  static List<BoxShadow> shadowRed({double opacity = 0.3}) => [
        BoxShadow(
          color: brandRed.withOpacity(opacity),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // 🎨 Gradients
  static const LinearGradient blackGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1F2937)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFED1C24), Color(0xFFDA291C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient redOverlay({double opacity = 0.1}) => LinearGradient(
        colors: [
          brandRed.withOpacity(opacity),
          brandRed.withOpacity(opacity * 0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

/// 📏 Spacing Constants
class MBESpacing {
  MBESpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// 🎭 Border Radius Constants
class MBERadius {
  MBERadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}

/// ⏱️ Animation Durations
class MBEDuration {
  MBEDuration._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

/// 📐 Animation Curves
class MBECurve {
  MBECurve._();

  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve decelerated = Curves.easeOut;
  static const Curve accelerated = Curves.easeIn;
}

// ✨ Helper para crear cards estilo Grab fácilmente
class MBECardDecoration {
  static BoxDecoration card({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(MBERadius.large),
      boxShadow: MBETheme.shadowMd,
    );
  }

  static BoxDecoration cardWithBorder({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(MBERadius.large),
      border: Border.all(
        color: borderColor ?? MBETheme.neutralGray.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: MBETheme.shadowSm,
    );
  }
}