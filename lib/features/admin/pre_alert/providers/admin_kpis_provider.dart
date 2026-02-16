// lib/features/admin/pre_alert/providers/admin_kpis_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import '../data/models/admin_kpis_model.dart';

part 'admin_kpis_provider.g.dart';

@riverpod
Future<AdminKPIs> adminKPIs(Ref ref) async {
  final repository = ref.read(adminPreAlertsRepositoryProvider);
  return await repository.getKPIs();
}
