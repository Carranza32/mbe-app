// lib/features/print_orders/presentation/providers/order_detail_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/print_order_detail.dart';
import '../data/repositories/print_order_repository.dart';

part 'order_detail_provider.g.dart';

@riverpod
class OrderDetail extends _$OrderDetail {
  @override
  Future<PrintOrderDetail> build(String orderNumber) async {
    return await ref.read(printOrderRepositoryProvider).getOrderDetail(orderNumber);
  }
}