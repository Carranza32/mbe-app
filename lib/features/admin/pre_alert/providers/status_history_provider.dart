import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/status_history_model.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';

part 'status_history_provider.g.dart';

@riverpod
Future<List<StatusHistoryItem>> statusHistory(
  Ref ref,
  String packageId,
) async {
  final repository = ref.read(adminPreAlertsRepositoryProvider);
  try {
    return await repository.getStatusHistory(packageId);
  } catch (e) {
    // Si hay error, retornar lista vacía
    return [];
  }
}

