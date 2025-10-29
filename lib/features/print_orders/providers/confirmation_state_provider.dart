// lib/features/print_orders/providers/confirmation_state_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'confirmation_state_provider.g.dart';

/// Enums para métodos de pago
enum PaymentMethod { cash, card, transfer }

/// Estado de confirmación del pedido
class ConfirmationState {
  final String fullName;
  final String email;
  final String phone;
  final String notes;
  final PaymentMethod paymentMethod;

  ConfirmationState({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.notes = '',
    this.paymentMethod = PaymentMethod.card,
  });

  ConfirmationState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? notes,
    PaymentMethod? paymentMethod,
  }) {
    return ConfirmationState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  bool get isValid {
    return fullName.isNotEmpty && email.isNotEmpty && _isValidEmail(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String getPaymentMethodName() {
    switch (paymentMethod) {
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }
}

@riverpod
class ConfirmationStateNotifier extends _$ConfirmationStateNotifier {
  @override
  ConfirmationState build() {
    return ConfirmationState();
  }

  void setFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void reset() {
    state = ConfirmationState();
  }
}