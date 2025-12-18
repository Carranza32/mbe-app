import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/admin_pre_alert_model.dart';
import '../data/models/package_status.dart';

part 'admin_pre_alerts_provider.g.dart';

@riverpod
class AdminPreAlerts extends _$AdminPreAlerts {
  @override
  Future<List<AdminPreAlert>> build() async {
    return _getMockData();
  }

  void filterByStatus(PackageStatus? status) {
    final currentData = state.value ?? [];
    if (status == null) {
      state = AsyncData(currentData);
      return;
    }
    final filtered = currentData.where((p) => p.status == status).toList();
    state = AsyncData(filtered);
  }

  void search(String query) {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }
    final allData = _getMockData();
    final lowerQuery = query.toLowerCase();
    final filtered = allData.where((p) {
      return p.trackingNumber.toLowerCase().contains(lowerQuery) ||
          p.eboxCode.toLowerCase().contains(lowerQuery) ||
          p.clientName.toLowerCase().contains(lowerQuery) ||
          p.provider.toLowerCase().contains(lowerQuery);
    }).toList();
    state = AsyncData(filtered);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncData(_getMockData());
  }

  List<AdminPreAlert> _getMockData() {
    return [
      AdminPreAlert(
        id: '1',
        trackingNumber: '0340309409439043',
        eboxCode: 'eeeeeeee',
        clientName: 'Mario Carranza',
        provider: 'ABERCROMBIE AND FITCH',
        total: 300.00,
        productCount: 1,
        store: 'Imprenta Central San Salvador',
        deliveryMethod: null,
        status: PackageStatus.pendingConfirmation,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AdminPreAlert(
        id: '2',
        trackingNumber: '1Z999AA10123456784',
        eboxCode: 'SAL1400',
        clientName: 'Juan Pérez',
        provider: 'AMAZON',
        total: 150.50,
        productCount: 3,
        store: 'Imprenta Santa Ana - Santa Ana',
        deliveryMethod: 'delivery',
        status: PackageStatus.readyToExport,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AdminPreAlert(
        id: '3',
        trackingNumber: '1Z999AA10123456785',
        eboxCode: 'SAL1401',
        clientName: 'María González',
        provider: 'EBAY',
        total: 89.99,
        productCount: 2,
        store: 'Imprenta Central San Salvador',
        deliveryMethod: 'pickup',
        status: PackageStatus.delivery,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      AdminPreAlert(
        id: '4',
        trackingNumber: '1Z999AA10123456786',
        eboxCode: 'SAL1402',
        clientName: 'Carlos Rodríguez',
        provider: 'WALMART',
        total: 245.75,
        productCount: 5,
        store: 'Imprenta Santa Ana - Santa Ana',
        deliveryMethod: 'pickup',
        status: PackageStatus.pickup,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      AdminPreAlert(
        id: '5',
        trackingNumber: '1Z999AA10123456787',
        eboxCode: 'SAL1403',
        clientName: 'Ana Martínez',
        provider: 'TARGET',
        total: 199.99,
        productCount: 1,
        store: 'Imprenta Central San Salvador',
        deliveryMethod: 'delivery',
        status: PackageStatus.readyToExport,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AdminPreAlert(
        id: '6',
        trackingNumber: '1Z999AA10123456788',
        eboxCode: 'SAL1404',
        clientName: 'Luis Hernández',
        provider: 'BEST BUY',
        total: 450.00,
        productCount: 2,
        store: 'Imprenta Santa Ana - Santa Ana',
        deliveryMethod: null,
        status: PackageStatus.pendingConfirmation,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

