// lib/features/print_orders/providers/delivery_state_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delivery_state_provider.g.dart';

/// Enums para método de entrega
enum DeliveryMethod { pickup, delivery }

/// Estado de la entrega del usuario
class UserDeliveryState {
  final DeliveryMethod method;
  final String? selectedLocationId;
  final String deliveryAddress;
  final String deliveryPhone;
  final String deliveryNotes;
  final double? deliveryCost;

  UserDeliveryState({
    this.method = DeliveryMethod.pickup,
    this.selectedLocationId,
    this.deliveryAddress = '',
    this.deliveryPhone = '',
    this.deliveryNotes = '',
    this.deliveryCost,
  });

  UserDeliveryState copyWith({
    DeliveryMethod? method,
    String? selectedLocationId,
    String? deliveryAddress,
    String? deliveryPhone,
    String? deliveryNotes,
    double? deliveryCost,
  }) {
    return UserDeliveryState(
      method: method ?? this.method,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryPhone: deliveryPhone ?? this.deliveryPhone,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      deliveryCost: deliveryCost ?? this.deliveryCost,
    );
  }

  bool get isPickup => method == DeliveryMethod.pickup;
  bool get isDelivery => method == DeliveryMethod.delivery;
  
  bool get isValid {
    if (isPickup) {
      return selectedLocationId != null;
    } else {
      return deliveryAddress.isNotEmpty && deliveryPhone.isNotEmpty;
    }
  }
}

@riverpod
class DeliveryState extends _$DeliveryState {
  @override
  UserDeliveryState build() {
    return UserDeliveryState();
  }

  void setMethod(DeliveryMethod method) {
    state = state.copyWith(method: method);
  }

  void setSelectedLocation(String locationId) {
    state = state.copyWith(selectedLocationId: locationId);
  }

  void setDeliveryAddress(String address) {
    state = state.copyWith(deliveryAddress: address);
  }

  void setDeliveryPhone(String phone) {
    state = state.copyWith(deliveryPhone: phone);
  }

  void setDeliveryNotes(String notes) {
    state = state.copyWith(deliveryNotes: notes);
  }

  void setDeliveryCost(double cost) {
    state = state.copyWith(deliveryCost: cost);
  }

  void reset() {
    state = UserDeliveryState();
  }
}