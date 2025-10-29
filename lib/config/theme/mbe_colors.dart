import 'package:flutter/material.dart';

/// Colores corporativos de Mail Boxes Etc.
class MBEColors {
  MBEColors._();

  /// Rojo Pantone 485 C - Color principal de la marca
  static const Color primary = Color(0xFFDA291C);
  
  /// Negro corporativo
  static const Color black = Color(0xFF000000);
  
  /// Variaciones de rojo para estados
  static const Color primaryLight = Color(0xFFE85448);
  static const Color primaryDark = Color(0xFFB71C1C);
  
  /// Grises para UI
  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyExtraLight = Color(0xFFF5F5F5);
  
  /// Blanco
  static const Color white = Color(0xFFFFFFFF);
  
  /// Colores de estado
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFDA291C); // Usa el rojo MBE
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}