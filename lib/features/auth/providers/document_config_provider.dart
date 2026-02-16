// lib/features/auth/providers/document_config_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/document_config_model.dart';
import '../data/repositories/document_config_repository.dart';

part 'document_config_provider.g.dart';

@riverpod
Future<DocumentConfigs> documentConfigs(Ref ref) async {
  final repository = ref.read(documentConfigRepositoryProvider);
  return await repository.getDocumentConfigs();
}
