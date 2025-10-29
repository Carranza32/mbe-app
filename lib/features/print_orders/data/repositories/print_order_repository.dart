// lib/features/print_orders/data/repositories/print_order_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/print_configuration_model.dart';
import '../models/uploaded_file_model.dart';

final printOrderRepositoryProvider = Provider<PrintOrderRepository>((ref) {
  return PrintOrderRepository(ref.read(apiServiceProvider));
});

class PrintOrderRepository {
  final ApiService _apiService;

  PrintOrderRepository(this._apiService);

  /// Obtener configuración inicial
  Future<PrintConfigurationModel> getPrintConfig() async {
    return await _apiService.get<PrintConfigurationModel>(
      endpoint: '/print-config',
      fromJson: (json) => PrintConfigurationModel.fromJson(json),
    );
  }

  /// Analizar archivos (obtener páginas totales)
  Future<FileAnalysisResponse> analyzeFiles(List<UploadedFile> files) async {
    final formData = FormData();

    for (var file in files) {
      formData.files.add(MapEntry(
        'files[]',
        await MultipartFile.fromFile(
          file.file.path,
          filename: file.name,
        ),
      ));
    }

    return await _apiService.post<FileAnalysisResponse>(
      endpoint: '/print-config/analyze-files',
      data: Map.fromEntries(formData.fields),
      fromJson: (json) => FileAnalysisResponse.fromJson(json),
    );
  }
}

/// Respuesta del análisis de archivos
class FileAnalysisResponse {
  final int totalPages;
  final List<FilePageInfo> files;

  FileAnalysisResponse({
    required this.totalPages,
    required this.files,
  });

  factory FileAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return FileAnalysisResponse(
      totalPages: json['total_pages'] as int,
      files: (json['files'] as List<dynamic>)
          .map((f) => FilePageInfo.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FilePageInfo {
  final String filename;
  final int pages;

  FilePageInfo({
    required this.filename,
    required this.pages,
  });

  factory FilePageInfo.fromJson(Map<String, dynamic> json) {
    return FilePageInfo(
      filename: json['filename'] as String,
      pages: json['pages'] as int,
    );
  }
}