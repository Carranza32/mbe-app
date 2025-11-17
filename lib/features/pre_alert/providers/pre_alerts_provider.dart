// lib/features/pre_alert/providers/pre_alerts_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/pre_alert_model.dart';

part 'pre_alerts_provider.g.dart';

@riverpod
class PreAlerts extends _$PreAlerts {
  @override
  Future<PreAlertsResponse> build() async {
    // TODO: Reemplazar con API real
    await Future.delayed(const Duration(seconds: 1));

    // Datos de ejemplo
    return PreAlertsResponse(
      preAlerts: [
        PreAlert(
          id: '1',
          trackingNumber: '045904590459',
          mailboxNumber: 'SAL1400',
          store: 'Imprenta Central San Salvador',
          totalValue: 50.00,
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          productCount: 1,
        ),
        PreAlert(
          id: '2',
          trackingNumber: '4535345345',
          mailboxNumber: 'SAL1400',
          store: 'Imprenta Central San Salvador',
          totalValue: 5.00,
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          productCount: 1,
        ),
      ],
      currentPage: 1,
      lastPage: 1,
      total: 2,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
