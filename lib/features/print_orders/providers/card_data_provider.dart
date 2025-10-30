// lib/features/print_orders/providers/card_data_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_data_provider.g.dart';

class CardData {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;

  CardData({
    this.cardNumber = '4970110000000062',
    this.cardHolder = 'Mario Carranza',
    this.expiryDate = '12/28',
    this.cvv = '123',
  });

  CardData copyWith({
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
  }) {
    return CardData(
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
    );
  }

  bool get isValid {
    return cardNumber.replaceAll(' ', '').length >= 13 &&
           cardHolder.isNotEmpty &&
           expiryDate.length == 5 &&
           cvv.length >= 3;
  }
}

@riverpod
class CardDataNotifier extends _$CardDataNotifier {
  @override
  CardData build() => CardData();

  void updateCardNumber(String value) {
    state = state.copyWith(cardNumber: value);
  }

  void updateCardHolder(String value) {
    state = state.copyWith(cardHolder: value);
  }

  void updateExpiryDate(String value) {
    state = state.copyWith(expiryDate: value);
  }

  void updateCVV(String value) {
    state = state.copyWith(cvv: value);
  }

  void reset() {
    state = CardData();
  }
}