// lib/features/auth/presentation/widgets/document_number_formatter.dart
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Helper para crear formateadores de documentos basados en el formato del backend
class DocumentNumberFormatterHelper {
  /// Convierte el formato del backend a una máscara compatible con mask_text_input_formatter
  /// y crea el formateador apropiado
  static TextInputFormatter? createFormatter({
    required String format,
    int? maxLength,
    String? initialText,
  }) {
    // Si el formato es "Alfanumérico", usar un formateador simple que solo limita longitud
    if (format.toLowerCase() == 'alfanumérico' ||
        format.toLowerCase() == 'alfanumerico') {
      return LengthLimitingTextInputFormatter(maxLength);
    }

    // Convertir formato del backend a formato de máscara
    // 0 -> # (dígito)
    // A -> A (letra mayúscula)
    // Mantener caracteres literales (guiones, espacios, etc.)
    String mask = format.replaceAll('0', '#').replaceAll('a', 'A');

    // Crear filtros para la máscara
    final filter = <String, RegExp>{
      '#': RegExp(r'[0-9]'),
      'A': RegExp(r'[A-Za-z]'),
    };

    // Crear el formateador con la máscara y texto inicial si existe
    return MaskTextInputFormatter(
      mask: mask,
      filter: filter,
      type: MaskAutoCompletionType.lazy,
      initialText: initialText,
    );
  }
}
