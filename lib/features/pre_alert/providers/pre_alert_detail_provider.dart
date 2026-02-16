import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/pre_alert_detail_model.dart';
import '../data/repositories/pre_alerts_repository.dart';

part 'pre_alert_detail_provider.g.dart';

@riverpod
Future<PreAlertDetail> preAlertDetail(Ref ref, String preAlertId) async {
  return ref.read(preAlertsRepositoryProvider).getPreAlertDetail(preAlertId);
}
