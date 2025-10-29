import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Helpers para manejo de archivos
class FileHelpers {
  FileHelpers._();

  /// Formatear tamaño de archivo
  static String formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes == 0) ? 0 : (bytes.bitLength - 1) ~/ 10;
    final value = bytes / (1 << (i * 10));
    return '${value.toStringAsFixed(i > 0 ? 2 : 0)} ${sizes[i]}';
  }

  /// Obtener ícono según el tipo de archivo
  static IconData getFileIcon(String type) {
    if (type.startsWith('image/')) {
      return Iconsax.gallery;
    } else if (type.contains('pdf')) {
      return Iconsax.document_text;
    } else if (type.contains('word') || type.contains('doc')) {
      return Iconsax.document;
    }
    return Iconsax.document_text;
  }

  /// Obtener color según el tipo de archivo
  static Color getFileColor(String type) {
    if (type.startsWith('image/')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (type.contains('pdf')) {
      return const Color(0xFFEF4444); // Red
    } else if (type.contains('word') || type.contains('doc')) {
      return const Color(0xFF3B82F6); // Blue
    }
    return const Color(0xFF6B7280); // Gray
  }

  /// Validar archivo
  static List<String> validateFile({
    required int fileSize,
    required String fileType,
    required String fileName,
    required int maxFileSizeBytes,
    required List<String> allowedTypes,
  }) {
    final errors = <String>[];

    // Validar tipo
    if (!allowedTypes.contains(fileType)) {
      errors.add('Tipo de archivo no permitido');
    }

    // Validar tamaño
    if (fileSize > maxFileSizeBytes) {
      final maxSizeMB = (maxFileSizeBytes / (1024 * 1024)).round();
      errors.add('El archivo excede el tamaño máximo de ${maxSizeMB}MB');
    }

    return errors;
  }

  /// Obtener extensión del archivo
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return '.${parts.last.toLowerCase()}';
    }
    return '';
  }
}