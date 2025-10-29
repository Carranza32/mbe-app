import 'package:flutter/material.dart';

/// Material Design 3 Theme para MBE
class MD3Theme {
  MD3Theme._();

  // 🎨 Color Scheme (Material You)
  static const Color _primaryColor = Color(0xFF6B7280); // Grey MBE
  static const Color _secondaryColor = Color(0xFF111827); // Black MBE
  static const Color _tertiaryColor = Color(0xFFEF4444); // Red accent

  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.light,
    ),
    
    // 📝 Typography Scale (MD3)
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),

    // 🔲 Shape System (MD3)
    cardTheme: CardThemeData(
      elevation: 0, // MD3 usa tonal elevation, no sombras
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // 📦 App Bar Theme (MD3)
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 3,
    ),

    // 🔘 Button Themes (MD3)
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    // 🎯 FAB Theme (MD3)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // 📊 Progress Indicator Theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _primaryColor,
      linearTrackColor: _primaryColor.withOpacity(0.2),
    ),

    // 🔲 Divider Theme
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: Colors.grey.withOpacity(0.2),
    ),
  );

  /// Dark Theme (opcional)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      brightness: Brightness.dark,
    ),
    textTheme: lightTheme.textTheme,
    cardTheme: lightTheme.cardTheme,
    appBarTheme: lightTheme.appBarTheme,
    filledButtonTheme: lightTheme.filledButtonTheme,
    elevatedButtonTheme: lightTheme.elevatedButtonTheme,
    outlinedButtonTheme: lightTheme.outlinedButtonTheme,
    floatingActionButtonTheme: lightTheme.floatingActionButtonTheme,
  );

  // 🎨 Elevation Levels (MD3)
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 3;
  static const double elevation3 = 6;
  static const double elevation4 = 8;
  static const double elevation5 = 12;

  // 📏 Spacing Scale (MD3)
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;
  static const double spacing64 = 64;

  // 🎭 Motion (MD3)
  static const Duration durationShort1 = Duration(milliseconds: 50);
  static const Duration durationShort2 = Duration(milliseconds: 100);
  static const Duration durationShort3 = Duration(milliseconds: 150);
  static const Duration durationShort4 = Duration(milliseconds: 200);
  static const Duration durationMedium1 = Duration(milliseconds: 250);
  static const Duration durationMedium2 = Duration(milliseconds: 300);
  static const Duration durationMedium3 = Duration(milliseconds: 350);
  static const Duration durationMedium4 = Duration(milliseconds: 400);
  static const Duration durationLong1 = Duration(milliseconds: 450);
  static const Duration durationLong2 = Duration(milliseconds: 500);
  static const Duration durationLong3 = Duration(milliseconds: 550);
  static const Duration durationLong4 = Duration(milliseconds: 600);

  // Standard easing curves
  static const Curve standardEasing = Curves.easeInOut;
  static const Curve emphasizedEasing = Curves.easeInOutCubic;
  static const Curve deceleratedEasing = Curves.easeOut;
  static const Curve acceleratedEasing = Curves.easeIn;
}