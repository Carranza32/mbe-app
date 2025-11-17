// lib/features/pre_alert/providers/stores_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/create_pre_alert_request.dart';

part 'stores_provider.g.dart';

@riverpod
class Stores extends _$Stores {
  @override
  Future<List<Store>> build() async {
    // TODO: Reemplazar con API real
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Store(id: '1', name: 'ADORAMA'),
      Store(id: '2', name: 'Amazon'),
      Store(id: '3', name: 'eBay'),
      Store(id: '4', name: 'Walmart'),
      Store(id: '5', name: 'Best Buy'),
      Store(id: '6', name: 'Target'),
      Store(id: '7', name: 'Newegg'),
      Store(id: '8', name: 'B&H Photo'),
      Store(id: '9', name: 'Home Depot'),
      Store(id: '10', name: 'Macy\'s'),
    ];
  }
}
