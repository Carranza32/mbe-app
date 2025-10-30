// lib/features/print_orders/providers/create_order_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/create_order_request.dart';
import '../data/models/create_order_request_extensions.dart'; // ← IMPORTANTE
import '../data/models/uploaded_file_model.dart';
import '../data/models/file_upload_config.dart';
import '../data/repositories/print_order_repository.dart';

part 'create_order_provider.g.dart';

// NOTA: Si FileAnalysisResponse no existe, créala en:
// lib/features/print_orders/data/models/file_analysis_response.dart
// (ver archivo file_analysis_response.dart en outputs)

/// Estado centralizado del formulario completo de orden
class CreateOrderState {
  final CreateOrderRequest? request;
  final List<UploadedFile> uploadedFiles; // ← Archivos con metadata
  final FileUploadConfig config;
  final bool isLoading;
  final String? error;
  final int? totalPages; // ← Del análisis de archivos
  
  CreateOrderState({
    this.request,
    this.uploadedFiles = const [],
    this.config = const FileUploadConfig(),
    this.isLoading = false,
    this.error,
    this.totalPages,
  });

  CreateOrderState copyWith({
    CreateOrderRequest? request,
    List<UploadedFile>? uploadedFiles,
    FileUploadConfig? config,
    bool? isLoading,
    String? error,
    int? totalPages,
  }) {
    return CreateOrderState(
      request: request ?? this.request,
      uploadedFiles: uploadedFiles ?? this.uploadedFiles,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
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