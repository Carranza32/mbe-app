// lib/features/auth/data/repositories/document_config_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/document_config_model.dart';

part 'document_config_repository.g.dart';

@riverpod
DocumentConfigRepository documentConfigRepository(Ref ref) {
  return DocumentConfigRepository(ref.watch(apiServiceProvider));
}

class DocumentConfigRepository {
  final ApiService _apiService;

  DocumentConfigRepository(this._apiService);

  /// Obtener todas las configuraciones de documentos
  Future<DocumentConfigs> getDocumentConfigs() async {
    return await _apiService.get<DocumentConfigs>(
      endpoint: ApiEndpoints.documentConfigs,
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          // Si viene envuelto en un objeto con 'data'
          if (json.containsKey('data')) {
            return DocumentConfigs.fromJson(json['data'] as Map<String, dynamic>);
          }
          return DocumentConfigs.fromJson(json);
        }
        throw Exception('Invalid response format');
      },
    );
  }
}
