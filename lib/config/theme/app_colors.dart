import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Primary Colors
  static const primary = Color(0xFFDA291C);
  static const primaryDark = Color(0xFF764ba2);
  static const secondary = Color(0xFF00B894);
  static const accent = Color(0xFFF5576C);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
  );

  static const dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5576C), Color(0xFFFD79A8)],
  );

  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
  );

  // Neutral Colors
  static const backgroundLight = Color(0xFFF8F9FA);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF2D3436);
  static const textSecondary = Color(0xFF636E72);
  static const textHint = Color(0xFFB2BEC3);
  static const divider = Color(0xFFDFE6E9);

  // Semantic Colors
  static const success = Color(0xFF00B894);
  static const error = Color(0xFFD63031);
  static const warning = Color(0xFFFFBE76);
  static const info = Color(0xFF74B9FF);

  // Shadow Colors
  static final shadowLight = Colors.black.withOpacity(0.05);
  static final shadowMedium = Colors.black.withOpacity(0.1);
  static final shadowDark = Colors.black.withOpacity(0.15);
}