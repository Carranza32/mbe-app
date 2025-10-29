import 'dart:io';

/// Modelo para representar un archivo subido
class UploadedFile {
  final String id;
  final File file;
  final String name;
  final int size;
  final String type;
  final List<String> errors;
  final String? preview; // Para imágenes

  UploadedFile({
    required this.id,
    required this.file,
    required this.name,
    required this.size,
    required this.type,
    this.errors = const [],
    this.preview,
  });

  /// Verificar si el archivo tiene errores
  bool get hasErrors => errors.isNotEmpty;

  /// Verificar si es una imagen
  bool get isImage => type.startsWith('image/');

  /// Crear copia con campos modificados
  UploadedFile copyWith({
    String? id,
    File? file,
    String? name,
    int? size,
    String? type,
    List<String>? errors,
    String? preview,
  }) {
    return UploadedFile(
      id: id ?? this.id,
      file: file ?? this.file,
      name: name ?? this.name,
      size: size ?? this.size,
      type: type ?? this.type,
      errors: errors ?? this.errors,
      preview: preview ?? this.preview,
    );
  }
}