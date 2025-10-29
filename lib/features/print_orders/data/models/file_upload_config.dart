/// Configuración de límites para archivos
class FileUploadConfig {
  final int maxFileSizeMB;
  final int maxFilesPerOrder;
  final List<String> allowedTypes;
  final List<String> allowedExtensions;

  const FileUploadConfig({
    this.maxFileSizeMB = 50,
    this.maxFilesPerOrder = 5,
    this.allowedTypes = const [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'image/jpeg',
      'image/jpg',
      'image/png',
    ],
    this.allowedExtensions = const [
      '.pdf',
      '.doc',
      '.docx',
      '.jpg',
      '.jpeg',
      '.png',
    ],
  });

  /// Tamaño máximo en bytes
  int get maxFileSizeBytes => maxFileSizeMB * 1024 * 1024;

  /// Crear desde JSON (cuando venga del backend)
  factory FileUploadConfig.fromJson(Map<String, dynamic> json) {
    return FileUploadConfig(
      maxFileSizeMB: json['max_file_size_mb'] as int? ?? 50,
      maxFilesPerOrder: json['max_files_per_order'] as int? ?? 5,
      allowedTypes: (json['allowed_file_types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'image/jpeg',
            'image/jpg',
            'image/png',
          ],
      allowedExtensions: (json['allowed_extensions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png'],
    );
  }
}