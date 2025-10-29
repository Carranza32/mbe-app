import 'package:mbe_orders_app/features/print_orders/data/repositories/print_order_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/print_order_model.dart';

part 'orders_provider.g.dart';

@riverpod
class Orders extends _$Orders {
  @override
  Future<OrdersResponse> build() async {
    return await ref.read(printOrderRepositoryProvider).getMyOrders();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref.read(printOrderRepositoryProvider).getMyOrders();
    });
  }
}