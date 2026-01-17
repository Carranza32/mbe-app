import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/pre_alert_model.dart';
import '../data/models/promotion_model.dart';

part 'pre_alert_complete_provider.g.dart';

/// Estado para completar información de pre-alerta
class PreAlertCompleteState {
  final PreAlert preAlert;
  final String? deliveryMethod; // 'pickup' o 'delivery'
  final int? selectedStoreId;
  final int? selectedAddressId;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactNotes;
  final bool isDifferentReceiver;
  final String? receiverName;
  final String? receiverEmail;
  final String? receiverPhone;
  final String? paymentMethod; // 'card' o 'cash'
  final Map<String, dynamic>? paymentData;
  final PromotionModel? promotion; // Promoción aplicada

  PreAlertCompleteState({
    required this.preAlert,
    this.deliveryMethod,
    this.selectedStoreId,
    this.selectedAddressId,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.contactNotes,
    this.isDifferentReceiver = false,
    this.receiverName,
    this.receiverEmail,
    this.receiverPhone,
    this.paymentMethod,
    this.paymentData,
    this.promotion,
  });

  PreAlertCompleteState copyWith({
    PreAlert? preAlert,
    String? deliveryMethod,
    int? selectedStoreId,
    int? selectedAddressId,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? contactNotes,
    bool? isDifferentReceiver,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
    String? paymentMethod,
    Map<String, dynamic>? paymentData,
    PromotionModel? promotion,
  }) {
    return PreAlertCompleteState(
      preAlert: preAlert ?? this.preAlert,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      selectedStoreId: selectedStoreId ?? this.selectedStoreId,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      contactName: contactName ?? this.contactName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      contactNotes: contactNotes ?? this.contactNotes,
      isDifferentReceiver: isDifferentReceiver ?? this.isDifferentReceiver,
      receiverName: receiverName ?? this.receiverName,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentData: paymentData ?? this.paymentData,
      promotion: promotion ?? this.promotion,
    );
  }

  bool get isPickup => deliveryMethod == 'pickup';
  bool get isDelivery => deliveryMethod == 'delivery';

  bool get isStep1Valid {
    if (deliveryMethod == null) return false;
    if (isPickup) return selectedStoreId != null;
    if (isDelivery) return selectedAddressId != null;
    return false;
  }

  bool get isStep2Valid {
    if (contactName == null || contactName!.isEmpty) return false;
    if (contactEmail == null || contactEmail!.isEmpty) return false;
    if (contactPhone == null || contactPhone!.isEmpty) return false;
    
    // Si es receptor diferente, validar datos del receptor
    if (isDifferentReceiver) {
      if (receiverName == null || receiverName!.isEmpty) return false;
      if (receiverEmail == null || receiverEmail!.isEmpty) return false;
      if (receiverPhone == null || receiverPhone!.isEmpty) return false;
    }
    
    return true;
  }

  bool get isStep3Valid {
    if (paymentMethod == null) return false;
    if (paymentMethod == 'cash') return true;
    if (paymentMethod == 'card') {
      // Validar datos de tarjeta
      return paymentData != null &&
          paymentData!['cardNumber'] != null &&
          paymentData!['cardHolder'] != null &&
          paymentData!['expiryDate'] != null &&
          paymentData!['cvv'] != null;
    }
    return false;
  }
}

/// Provider para el estado de completar pre-alerta
@riverpod
class PreAlertComplete extends _$PreAlertComplete {
  @override
  PreAlertCompleteState build(PreAlert preAlert) {
    return PreAlertCompleteState(preAlert: preAlert);
  }

  void setDeliveryMethod(String method) {
    state = state.copyWith(
      deliveryMethod: method,
      selectedStoreId: method == 'pickup' ? state.selectedStoreId : null,
      selectedAddressId: method == 'delivery' ? state.selectedAddressId : null,
      promotion: null, // Limpiar promoción al cambiar método
    );
  }

  void setPromotion(PromotionModel? promotion) {
    state = state.copyWith(promotion: promotion);
  }

  void setSelectedStore(int storeId) {
    state = state.copyWith(selectedStoreId: storeId);
  }

  void setSelectedAddress(int addressId) {
    state = state.copyWith(selectedAddressId: addressId);
  }

  void setContactInfo({
    String? name,
    String? email,
    String? phone,
    String? notes,
  }) {
    state = state.copyWith(
      contactName: name ?? state.contactName,
      contactEmail: email ?? state.contactEmail,
      contactPhone: phone ?? state.contactPhone,
      contactNotes: notes ?? state.contactNotes,
    );
  }

  void setDifferentReceiver(bool isDifferent) {
    state = state.copyWith(isDifferentReceiver: isDifferent);
  }

  void setReceiverInfo({
    String? name,
    String? email,
    String? phone,
  }) {
    state = state.copyWith(
      receiverName: name ?? state.receiverName,
      receiverEmail: email ?? state.receiverEmail,
      receiverPhone: phone ?? state.receiverPhone,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setPaymentData(Map<String, dynamic> data) {
    state = state.copyWith(paymentData: data);
  }

  void reset() {
    state = PreAlertCompleteState(preAlert: state.preAlert);
  }

  /// Construir el payload para enviar al endpoint
  Map<String, dynamic> toJson() {
    final deliveryData = <String, dynamic>{
      'method': state.deliveryMethod ?? 'pickup',
    };

    if (state.isPickup && state.selectedStoreId != null) {
      deliveryData['pickupLocation'] = state.selectedStoreId;
    } else if (state.isDelivery && state.selectedAddressId != null) {
      deliveryData['customerAddressId'] = state.selectedAddressId;
    }

    // Agregar ID de promoción si existe y es delivery
    if (state.isDelivery && state.promotion != null) {
      deliveryData['delivery_promotion_id'] = state.promotion!.id;
    }

    final contactData = <String, dynamic>{
      'name': state.contactName ?? '',
      'email': state.contactEmail ?? '',
      'phone': state.contactPhone ?? '',
      'is_different_receiver': state.isDifferentReceiver,
    };

    if (state.contactNotes != null && state.contactNotes!.isNotEmpty) {
      contactData['notes'] = state.contactNotes;
    }

    if (state.isDifferentReceiver) {
      contactData['receiver'] = {
        'name': state.receiverName ?? '',
        'email': state.receiverEmail ?? '',
        'phone': state.receiverPhone ?? '',
      };
    }

    return {
      'delivery': deliveryData,
      'contact': contactData,
    };
  }
}
