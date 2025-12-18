// lib/features/print_orders/providers/create_order_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/create_order_request.dart';
import '../data/models/uploaded_file_model.dart';
import '../data/models/file_upload_config.dart';
import '../data/repositories/print_order_repository.dart';
import 'print_config_provider.dart' as print_config;
import 'print_configuration_state_provider.dart'; // Para los enums PrintType, PaperSize, etc.
import '../data/models/print_configuration_model.dart';
import '../data/helpers/config_converters.dart';

part 'create_order_provider.g.dart';

// ====== ENUMS Y CLASES PARA PAGO ======

/// Métodos de pago disponibles
enum PaymentMethod { cash, card, transfer }

/// Información de pago
class PaymentInfo {
  final PaymentMethod method;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cvv;

  PaymentInfo({
    this.method = PaymentMethod.card,
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cvv,
  });

  PaymentInfo copyWith({
    PaymentMethod? method,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
  }) {
    return PaymentInfo(
      method: method ?? this.method,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
    );
  }

  bool get isCardValid {
    if (method != PaymentMethod.card) return true;
    return (cardNumber?.replaceAll(' ', '').length ?? 0) >= 13 &&
           cardHolder != null && cardHolder!.isNotEmpty &&
           expiryDate != null && expiryDate!.length == 5 &&
           cvv != null && cvv!.length >= 3;
  }
}

/// Desglose de precios calculados
class PriceBreakdown {
  final double pricePerPage;
  final double printingCost;
  final double doubleSidedCost;
  final double bindingCost;
  final double printSubtotal;
  final double printTax;
  final double printTotal;
  final double deliveryBaseCost;
  final double deliveryCost;
  final double freeDeliveryMinimum;
  final bool isFreeDelivery;
  final double grandTotal;
  final int totalPages;
  final int copies;

  PriceBreakdown({
    this.pricePerPage = 0,
    this.printingCost = 0,
    this.doubleSidedCost = 0,
    this.bindingCost = 0,
    this.printSubtotal = 0,
    this.printTax = 0,
    this.printTotal = 0,
    this.deliveryBaseCost = 0,
    this.deliveryCost = 0,
    this.freeDeliveryMinimum = 0,
    this.isFreeDelivery = true,
    this.grandTotal = 0,
    this.totalPages = 0,
    this.copies = 1,
  });

  PriceBreakdown.zero()
      : pricePerPage = 0,
        printingCost = 0,
        doubleSidedCost = 0,
        bindingCost = 0,
        printSubtotal = 0,
        printTax = 0,
        printTotal = 0,
        deliveryBaseCost = 0,
        deliveryCost = 0,
        freeDeliveryMinimum = 0,
        isFreeDelivery = true,
        grandTotal = 0,
        totalPages = 0,
        copies = 1;
}

// Clases auxiliares para cálculos internos
class _PrintPricingResult {
  final double pricePerPage;
  final double printingCost;
  final double doubleSidedCost;
  final double bindingCost;
  final double subtotal;
  final double tax;
  final double total;

  _PrintPricingResult({
    required this.pricePerPage,
    required this.printingCost,
    required this.doubleSidedCost,
    required this.bindingCost,
    required this.subtotal,
    required this.tax,
    required this.total,
  });

  _PrintPricingResult.zero()
      : pricePerPage = 0,
        printingCost = 0,
        doubleSidedCost = 0,
        bindingCost = 0,
        subtotal = 0,
        tax = 0,
        total = 0;
}

class _DeliveryPricingResult {
  final double baseCost;
  final double deliveryCost;
  final double freeDeliveryMinimum;
  final bool isFreeDelivery;

  _DeliveryPricingResult({
    required this.baseCost,
    required this.deliveryCost,
    required this.freeDeliveryMinimum,
    required this.isFreeDelivery,
  });

  _DeliveryPricingResult.zero()
      : baseCost = 0,
        deliveryCost = 0,
        freeDeliveryMinimum = 0,
        isFreeDelivery = true;
}

/// Estado centralizado del formulario completo de orden
class CreateOrderState {
  final CreateOrderRequest? request;
  final List<UploadedFile> uploadedFiles; // ← Archivos con metadata
  final FileUploadConfig config;
  final bool isLoading;
  final String? error;
  final int? totalPages; // ← Del análisis de archivos
  final PaymentInfo paymentInfo; // ← Información de pago consolidada
  
  CreateOrderState({
    this.request,
    this.uploadedFiles = const [],
    this.config = const FileUploadConfig(),
    this.isLoading = false,
    this.error,
    this.totalPages,
    PaymentInfo? paymentInfo,
  }) : paymentInfo = paymentInfo ?? PaymentInfo();

  CreateOrderState copyWith({
    CreateOrderRequest? request,
    List<UploadedFile>? uploadedFiles,
    FileUploadConfig? config,
    bool? isLoading,
    String? error,
    int? totalPages,
    PaymentInfo? paymentInfo,
  }) {
    return CreateOrderState(
      request: request ?? this.request,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
      paymentInfo: paymentInfo ?? this.paymentInfo,
    );
  }

  // ====== Getters útiles ======
  int get totalFiles => uploadedFiles.length;
  int get totalSize => uploadedFiles.fold(0, (sum, file) => sum + file.size);
  bool get hasFileErrors => uploadedFiles.any((file) => file.hasErrors);
  bool get canAddMoreFiles => uploadedFiles.length < config.maxFilesPerOrder;
  int get availableSlots => config.maxFilesPerOrder - uploadedFiles.length;
  
  // Validación por paso
  bool isStepValid(int step) {
    switch (step) {
      case 1: // Upload files
        return uploadedFiles.isNotEmpty && !hasFileErrors && totalPages != null;
      case 2: // Configuration
        return request?.printConfig != null;
      case 3: // Delivery
        return request?.deliveryInfo != null && _isDeliveryValid();
      case 4: // Customer info
        return request?.customerInfo != null && _isCustomerValid();
      default:
        return false;
    }
  }

  bool _isDeliveryValid() {
    final delivery = request?.deliveryInfo;
    if (delivery == null) return false;
    
    if (delivery.method == 'pickup') {
      return delivery.pickupLocation != null;
    } else {
      return delivery.address != null && 
             delivery.address!.isNotEmpty &&
             delivery.phone != null;
    }
  }

  bool _isCustomerValid() {
    final customer = request?.customerInfo;
    if (customer == null) return false;
    
    return customer.name.isNotEmpty && 
           customer.email.isNotEmpty &&
           RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(customer.email);
  }
}

@riverpod
class CreateOrder extends _$CreateOrder {
  @override
  CreateOrderState build() {
    return CreateOrderState();
  }

  // ====== STEP 1: ARCHIVOS ======
  
  /// Configurar límites de archivos
  void updateConfig(FileUploadConfig config) {
    state = state.copyWith(config: config);
  }

  /// Agregar archivos
  void addFiles(List<UploadedFile> newFiles) {
    final currentFiles = state.uploadedFiles;
    final availableSlots = state.availableSlots;

    if (availableSlots == 0) {
      state = state.copyWith(
        error: 'Máximo ${state.config.maxFilesPerOrder} archivos permitidos',
      );
      _clearErrorAfterDelay();
      return;
    }

    final filesToAdd = newFiles.take(availableSlots).toList();
    final updatedFiles = [...currentFiles, ...filesToAdd];

    // Actualizar archivos y resetear análisis
    state = state.copyWith(
      uploadedFiles: updatedFiles,
      totalPages: null, // Reset para forzar nuevo análisis
    );

    if (newFiles.length > availableSlots) {
      state = state.copyWith(
        error: 'Solo se pueden agregar $availableSlots archivos más',
      );
      _clearErrorAfterDelay();
    }
  }

  /// Eliminar un archivo
  void removeFile(String id) {
    final updatedFiles = state.uploadedFiles.where((f) => f.id != id).toList();
    
    state = state.copyWith(
      uploadedFiles: updatedFiles,
      totalPages: null, // Reset para forzar nuevo análisis
    );
  }

  /// Limpiar todos los archivos
  void clearFiles() {
    state = state.copyWith(
      uploadedFiles: [],
      totalPages: null,
    );
  }

  /// Analizar archivos y obtener total de páginas
  Future<bool> analyzeFiles() async {
    if (state.uploadedFiles.isEmpty) {
      state = state.copyWith(error: 'Debes subir al menos un archivo');
      return false;
    }

    if (state.hasFileErrors) {
      state = state.copyWith(error: 'Algunos archivos tienen errores');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(printOrderRepositoryProvider);
      final response = await repository.analyzeFiles(state.uploadedFiles);

      // Actualizar el request con los paths de archivos
      final filePaths = state.uploadedFiles.map((f) => f.file.path).toList();
      
      final updatedRequest = (state.request ?? _emptyRequest()).copyWith(
        files: filePaths,
      );

      state = state.copyWith(
        isLoading: false,
        totalPages: response.totalPages,
        request: updatedRequest,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al analizar archivos: $e',
      );
      return false;
    }
  }

  // ====== STEP 2: CONFIGURACIÓN DE IMPRESIÓN ======
  
  /// Actualizar configuración completa
  void updatePrintConfig(PrintConfig config) {
    final updatedRequest = (state.request ?? _emptyRequest()).copyWith(
      printConfig: config,
    );
    state = state.copyWith(request: updatedRequest);
  }

  /// Establecer tipo de impresión (blackWhite o color)
  void setPrintType(String printType) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(printType: printType);
    updatePrintConfig(updatedConfig);
  }

  /// Establecer tamaño de papel
  void setPaperSize(String paperSize) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(paperSize: paperSize);
    updatePrintConfig(updatedConfig);
  }

  /// Establecer tipo de papel
  void setPaperType(String paperType) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(paperType: paperType);
    updatePrintConfig(updatedConfig);
  }

  /// Establecer orientación
  void setOrientation(String orientation) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(orientation: orientation);
    updatePrintConfig(updatedConfig);
  }

  /// Establecer número de copias
  void setCopies(int copies) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(copies: copies);
    updatePrintConfig(updatedConfig);
  }

  /// Establecer doble cara
  void setDoubleSided(bool doubleSided) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(doubleSided: doubleSided);
    updatePrintConfig(updatedConfig);
  }

  /// Establecer engargolado
  void setBinding(bool binding) {
    final currentConfig = state.request?.printConfig ?? _defaultPrintConfig();
    final updatedConfig = currentConfig.copyWith(binding: binding);
    updatePrintConfig(updatedConfig);
  }

  // ====== STEP 3: INFORMACIÓN DE ENTREGA ======
  
  void updateDeliveryInfo(DeliveryInfo delivery) {
    final updatedRequest = (state.request ?? _emptyRequest()).copyWith(
      deliveryInfo: delivery,
    );
    state = state.copyWith(request: updatedRequest);
  }

  /// Establecer método de entrega (pickup o delivery)
  void setDeliveryMethod(String method) {
    final currentDelivery = state.request?.deliveryInfo ?? _defaultDeliveryInfo();
    final updatedDelivery = currentDelivery.copyWith(method: method);
    updateDeliveryInfo(updatedDelivery);
  }

  /// Establecer ubicación de pickup
  void setPickupLocation(int locationId) {
    final currentDelivery = state.request?.deliveryInfo ?? _defaultDeliveryInfo();
    final updatedDelivery = currentDelivery.copyWith(
      method: 'pickup',
      pickupLocation: locationId,
    );
    updateDeliveryInfo(updatedDelivery);
  }

  /// Establecer dirección de entrega
  void setDeliveryAddress(String address) {
    final currentDelivery = state.request?.deliveryInfo ?? _defaultDeliveryInfo();
    final updatedDelivery = currentDelivery.copyWith(
      method: 'delivery',
      address: address,
    );
    updateDeliveryInfo(updatedDelivery);
  }

  /// Establecer teléfono de entrega
  void setDeliveryPhone(String phone) {
    final currentDelivery = state.request?.deliveryInfo ?? _defaultDeliveryInfo();
    final updatedDelivery = currentDelivery.copyWith(
      method: 'delivery',
      phone: phone,
    );
    updateDeliveryInfo(updatedDelivery);
  }

  /// Establecer notas de entrega
  void setDeliveryNotes(String notes) {
    final currentDelivery = state.request?.deliveryInfo ?? _defaultDeliveryInfo();
    final updatedDelivery = currentDelivery.copyWith(notes: notes);
    updateDeliveryInfo(updatedDelivery);
  }

  DeliveryInfo _defaultDeliveryInfo() {
    return DeliveryInfo(method: 'pickup');
  }

  // ====== STEP 4: INFORMACIÓN DEL CLIENTE ======
  
  void updateCustomerInfo(CustomerInfo customer) {
    final updatedRequest = (state.request ?? _emptyRequest()).copyWith(
      customerInfo: customer,
    );
    state = state.copyWith(request: updatedRequest);
  }

  /// Establecer nombre completo del cliente
  void setCustomerName(String name) {
    final currentCustomer = state.request?.customerInfo ?? CustomerInfo(name: '', email: '');
    final updatedCustomer = currentCustomer.copyWith(name: name);
    updateCustomerInfo(updatedCustomer);
  }

  /// Establecer email del cliente
  void setCustomerEmail(String email) {
    final currentCustomer = state.request?.customerInfo ?? CustomerInfo(name: '', email: '');
    final updatedCustomer = currentCustomer.copyWith(email: email);
    updateCustomerInfo(updatedCustomer);
  }

  /// Establecer teléfono del cliente (opcional)
  void setCustomerPhone(String phone) {
    final currentCustomer = state.request?.customerInfo ?? CustomerInfo(name: '', email: '');
    final updatedCustomer = currentCustomer.copyWith(phone: phone.isNotEmpty ? phone : null);
    updateCustomerInfo(updatedCustomer);
  }

  /// Establecer notas del cliente (opcional)
  void setCustomerNotes(String notes) {
    final currentCustomer = state.request?.customerInfo ?? CustomerInfo(name: '', email: '');
    final updatedCustomer = currentCustomer.copyWith(notes: notes.isNotEmpty ? notes : null);
    updateCustomerInfo(updatedCustomer);
  }

  // ====== STEP 5: INFORMACIÓN DE PAGO ======
  
  /// Establecer método de pago
  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(
      paymentInfo: state.paymentInfo.copyWith(method: method),
    );
  }

  /// Establecer número de tarjeta
  void setCardNumber(String cardNumber) {
    state = state.copyWith(
      paymentInfo: state.paymentInfo.copyWith(cardNumber: cardNumber),
    );
  }

  /// Establecer titular de tarjeta
  void setCardHolder(String cardHolder) {
    state = state.copyWith(
      paymentInfo: state.paymentInfo.copyWith(cardHolder: cardHolder),
    );
  }

  /// Establecer fecha de expiración
  void setExpiryDate(String expiryDate) {
    state = state.copyWith(
      paymentInfo: state.paymentInfo.copyWith(expiryDate: expiryDate),
    );
  }

  /// Establecer CVV
  void setCVV(String cvv) {
    state = state.copyWith(
      paymentInfo: state.paymentInfo.copyWith(cvv: cvv),
    );
  }

  // ====== CÁLCULOS DE PRECIOS (COMPUTED) ======
  
  /// Calcular desglose completo de precios
  PriceBreakdown calculatePricing() {
    final configAsync = ref.read(print_config.printConfigProvider);
    
    return configAsync.when(
      data: (configModel) {
        final printConfig = state.request?.printConfig;
        final totalPages = state.totalPages ?? 0;

        if (printConfig == null || totalPages == 0) {
          return PriceBreakdown.zero();
        }

        // Calcular precios de impresión
        final printPricing = _calculatePrintPricing(configModel, printConfig, totalPages);
        
        // Calcular precios de entrega
        final deliveryPricing = _calculateDeliveryPricing(configModel, printPricing.total);

        return PriceBreakdown(
          pricePerPage: printPricing.pricePerPage,
          printingCost: printPricing.printingCost,
          doubleSidedCost: printPricing.doubleSidedCost,
          bindingCost: printPricing.bindingCost,
          printSubtotal: printPricing.subtotal,
          printTax: printPricing.tax,
          printTotal: printPricing.total,
          deliveryBaseCost: deliveryPricing.baseCost,
          deliveryCost: deliveryPricing.deliveryCost,
          freeDeliveryMinimum: deliveryPricing.freeDeliveryMinimum,
          isFreeDelivery: deliveryPricing.isFreeDelivery,
          grandTotal: printPricing.total + deliveryPricing.deliveryCost,
          totalPages: totalPages,
          copies: printConfig.copies,
        );
      },
      loading: () => PriceBreakdown.zero(),
      error: (_, __) => PriceBreakdown.zero(),
    );
  }

  /// Calcular precios de impresión
  _PrintPricingResult _calculatePrintPricing(
    PrintConfigurationModel configModel,
    PrintConfig printConfig,
    int totalPages,
  ) {
    if (totalPages == 0) {
      return _PrintPricingResult.zero();
    }

    final config = configModel.config;
    if (config?.prices == null) {
      return _PrintPricingResult.zero();
    }

    // Convertir strings a enums
    final printType = ConfigConverters.printTypeFromString(printConfig.printType);
    final paperSize = ConfigConverters.paperSizeFromString(printConfig.paperSize);

    // 1. Obtener precio por página
    final pricePerPage = _getPricePerPage(
      config!.prices!,
      printType,
      paperSize,
      totalPages,
    );

    // 2. Calcular costo de impresión base
    final printingCost = pricePerPage * totalPages * printConfig.copies;

    // 3. Calcular costo de doble cara
    final doubleSidedCost = printConfig.doubleSided
        ? (config.prices!.doubleSided ?? 0) * totalPages * printConfig.copies
        : 0.0;

    // 4. Calcular costo de engargolado
    final bindingCost = printConfig.binding
        ? _getBindingPrice(config.prices!.binding, totalPages)
        : 0.0;

    // 5. Calcular subtotal
    final subtotal = printingCost + doubleSidedCost + bindingCost;

    // 6. Calcular IVA
    final taxRate = config.tax?.iva ?? 0.13;
    final tax = subtotal * taxRate;

    // 7. Total
    final total = subtotal;

    return _PrintPricingResult(
      pricePerPage: pricePerPage,
      printingCost: printingCost,
      doubleSidedCost: doubleSidedCost,
      bindingCost: bindingCost,
      subtotal: subtotal,
      tax: tax,
      total: total,
    );
  }

  /// Calcular precios de entrega
  _DeliveryPricingResult _calculateDeliveryPricing(
    PrintConfigurationModel configModel,
    double printTotal,
  ) {
    final deliveryInfo = state.request?.deliveryInfo;
    final isPickup = deliveryInfo?.method == 'pickup' || deliveryInfo == null;

    if (isPickup) {
      return _DeliveryPricingResult(
        baseCost: 0,
        deliveryCost: 0,
        freeDeliveryMinimum: 0,
        isFreeDelivery: true,
      );
    }

    final deliveryConfig = configModel.config?.delivery;
    if (deliveryConfig == null) {
      return _DeliveryPricingResult.zero();
    }

    final baseCost = (deliveryConfig.baseCost ?? 0).toDouble();
    final freeDeliveryMinimum = (deliveryConfig.freeDeliveryMinimum ?? 0).toDouble();
    final isFree = printTotal >= freeDeliveryMinimum;
    final deliveryCost = isFree ? 0.0 : baseCost;

    return _DeliveryPricingResult(
      baseCost: baseCost,
      deliveryCost: deliveryCost,
      freeDeliveryMinimum: freeDeliveryMinimum,
      isFreeDelivery: isFree,
    );
  }

  /// Obtener precio por página según el rango
  double _getPricePerPage(
    Prices prices,
    PrintType printType,
    PaperSize paperSize,
    int totalPages,
  ) {
    // Seleccionar si es B&W o Color
    final copiesData = printType == PrintType.blackWhite
        ? prices.printing?.bw
        : prices.printing?.color;

    if (copiesData == null) return 0.0;

    // Seleccionar el tamaño de papel
    List<PaperCutting>? priceRanges;
    switch (paperSize) {
      case PaperSize.letter:
        priceRanges = copiesData.letter;
        break;
      case PaperSize.legal:
        priceRanges = copiesData.legal;
        break;
      case PaperSize.doubleLetter:
        priceRanges = copiesData.doubleLetter;
        break;
    }

    if (priceRanges == null || priceRanges.isEmpty) return 0.0;

    // Buscar el rango de precio correcto
    for (final range in priceRanges) {
      final min = range.min ?? 0;
      final max = range.max ?? double.infinity.toInt();

      if (totalPages >= min && totalPages <= max) {
        return range.price ?? 0.0;
      }
    }

    // Si no se encuentra, usar el último rango
    return priceRanges.last.price ?? 0.0;
  }

  /// Obtener precio de engargolado según páginas
  double _getBindingPrice(List<Binding>? bindings, int totalPages) {
    if (bindings == null || bindings.isEmpty) return 0.0;

    // Buscar el rango correcto
    for (final binding in bindings) {
      if (totalPages <= (binding.maxSheets ?? 0)) {
        return binding.price ?? 0.0;
      }
    }

    // Si excede todos los rangos, usar el más caro
    return bindings.last.price ?? 0.0;
  }

  /// Obtener rango de precios para mostrar en UI
  String getPriceRange(PaperSize size) {
    final configAsync = ref.read(print_config.printConfigProvider);
    
    return configAsync.when(
      data: (configModel) {
        final prices = configModel.config?.prices?.printing?.bw;
        if (prices == null) return 'N/A';

        List<PaperCutting>? ranges;
        switch (size) {
          case PaperSize.letter:
            ranges = prices.letter;
            break;
          case PaperSize.legal:
            ranges = prices.legal;
            break;
          case PaperSize.doubleLetter:
            ranges = prices.doubleLetter;
            break;
        }

        if (ranges == null || ranges.isEmpty) return 'N/A';
        
        final minPrice = ranges.first.price ?? 0;
        return 'Desde \$${minPrice.toStringAsFixed(2)}';
      },
      loading: () => '...',
      error: (_, __) => 'N/A',
    );
  }

  // ====== HELPERS ======
  
  void _clearErrorAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (state.error != null) {
        state = state.copyWith(error: null);
      }
    });
  }

  CreateOrderRequest _emptyRequest() {
    return CreateOrderRequest(
      customerInfo: CustomerInfo(name: '', email: ''),
      printConfig: _defaultPrintConfig(),
      deliveryInfo: DeliveryInfo(method: 'pickup'),
      files: [],
    );
  }

  PrintConfig _defaultPrintConfig() {
    return PrintConfig(
      printType: 'bw',
      paperSize: 'letter',
      paperType: 'bond',
      orientation: 'portrait',
      copies: 1,
      doubleSided: false,
      binding: false,
    );
  }

  /// Resetear todo
  void reset() {
    state = CreateOrderState();
  }
}