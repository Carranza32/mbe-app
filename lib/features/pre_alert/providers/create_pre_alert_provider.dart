// lib/features/pre_alert/providers/create_pre_alert_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import '../data/models/create_pre_alert_request.dart';
import 'dart:io';

part 'create_pre_alert_provider.g.dart';

/// Estado del formulario de pre-alerta
class CreatePreAlertState {
  final CreatePreAlertRequest? request;
  final File? invoiceFile;
  final bool isLoading;
  final String? error;

  CreatePreAlertState({
    this.request,
    this.invoiceFile,
    this.isLoading = false,
    this.error,
  });

  CreatePreAlertState copyWith({
    CreatePreAlertRequest? request,
    File? invoiceFile,
    bool? isLoading,
    String? error,
  }) {
    return CreatePreAlertState(
      request: request ?? this.request,
      invoiceFile: invoiceFile ?? this.invoiceFile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Validación de campos
  bool get isTrackingNumberValid =>
      request?.trackingNumber.isNotEmpty ?? false;

  bool get isMailboxNumberValid =>
      request?.mailboxNumber.isNotEmpty ?? false;

  bool get isStoreSelected => request?.storeId.isNotEmpty ?? false;

  bool get isTotalValueValid => (request?.totalValue ?? 0) > 0;

  bool get hasProducts => (request?.products.length ?? 0) > 0;

  bool get productsMatchTotal {
    if (request == null) return false;
    final productsTotal = request!.products.fold<double>(
      0,
      (sum, product) => sum + product.subtotal,
    );
    return (productsTotal - request!.totalValue).abs() < 0.01;
  }

  bool get isValid =>
      isTrackingNumberValid &&
      isMailboxNumberValid &&
      isStoreSelected &&
      isTotalValueValid &&
      hasProducts &&
      productsMatchTotal;
}

@riverpod
class CreatePreAlert extends _$CreatePreAlert {
  @override
  CreatePreAlertState build() {
    return CreatePreAlertState(
      request: CreatePreAlertRequest(
        trackingNumber: '',
        mailboxNumber: '',
        storeId: '',
        totalValue: 0,
        products: [],
      ),
    );
  }

  // ===== SETTERS =====

  void setTrackingNumber(String value) {
    final updatedRequest = state.request!.copyWith(trackingNumber: value);
    state = state.copyWith(request: updatedRequest);
  }

  void setMailboxNumber(String value) {
    final updatedRequest = state.request!.copyWith(mailboxNumber: value);
    state = state.copyWith(request: updatedRequest);
  }

  void setStore(String storeId) {
    final updatedRequest = state.request!.copyWith(storeId: storeId);
    state = state.copyWith(request: updatedRequest);
  }

  void setTotalValue(double value) {
    final updatedRequest = state.request!.copyWith(totalValue: value);
    state = state.copyWith(request: updatedRequest);
  }

  void setInvoiceFile(File file) {
    state = state.copyWith(invoiceFile: file);
  }

  // ===== GESTIÓN DE PRODUCTOS =====

  void addProduct() {
    final currentProducts = List<PreAlertProduct>.from(state.request!.products);
    currentProducts.add(
      PreAlertProduct(
        productId: '',
        productName: '',
        quantity: 1,
        price: 0,
      ),
    );
    final updatedRequest = state.request!.copyWith(products: currentProducts);
    state = state.copyWith(request: updatedRequest);
  }

  void removeProduct(int index) {
    final currentProducts = List<PreAlertProduct>.from(state.request!.products);
    currentProducts.removeAt(index);
    final updatedRequest = state.request!.copyWith(products: currentProducts);
    state = state.copyWith(request: updatedRequest);
  }

  void updateProduct(int index, PreAlertProduct product) {
    final currentProducts = List<PreAlertProduct>.from(state.request!.products);
    currentProducts[index] = product;
    final updatedRequest = state.request!.copyWith(products: currentProducts);
    state = state.copyWith(request: updatedRequest);
  }

  void setProductName(int index, String productId, String productName) {
    final currentProducts = List<PreAlertProduct>.from(state.request!.products);
    currentProducts[index] = currentProducts[index].copyWith(
      productId: productId,
      productName: productName,
    );
    final updatedRequest = state.request!.copyWith(products: currentProducts);
    state = state.copyWith(request: updatedRequest);
  }

  void setProductQuantity(int index, int quantity) {
    final currentProducts = List<PreAlertProduct>.from(state.request!.products);
    currentProducts[index] = currentProducts[index].copyWith(quantity: quantity);
    final updatedRequest = state.request!.copyWith(products: currentProducts);
    state = state.copyWith(request: updatedRequest);
  }

  void setProductPrice(int index, double price) {
    final currentProducts = List<PreAlertProduct>.from(state.request!.products);
    currentProducts[index] = currentProducts[index].copyWith(price: price);
    final updatedRequest = state.request!.copyWith(products: currentProducts);
    state = state.copyWith(request: updatedRequest);
  }

  // ===== ENVIAR =====

  Future<bool> submit() async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Por favor complete todos los campos requeridos');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Aquí irá la llamada a la API
      await Future.delayed(const Duration(seconds: 2)); // Simulación

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al crear la pre-alerta: $e',
      );
      return false;
    }
  }

  // ===== RESET =====

  void reset() {
    state = CreatePreAlertState(
      request: CreatePreAlertRequest(
        trackingNumber: '',
        mailboxNumber: '',
        storeId: '',
        totalValue: 0,
        products: [],
      ),
    );
  }
}
