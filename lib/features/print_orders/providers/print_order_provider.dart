import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/uploaded_file_model.dart';
import '../data/models/file_upload_config.dart';

part 'print_order_provider.g.dart';

/// Estado del pedido de impresión
class PrintOrderState {
  final List<UploadedFile> files;
  final FileUploadConfig config;
  final bool isLoading;
  final String? error;

  PrintOrderState({
    this.files = const [],
    this.config = const FileUploadConfig(),
    this.isLoading = false,
    this.error,
  });

  PrintOrderState copyWith({
    List<UploadedFile>? files,
    FileUploadConfig? config,
    bool? isLoading,
    String? error,
  }) {
    return PrintOrderState(
      files: files ?? this.files,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Total de archivos
  int get totalFiles => files.length;

  /// Tamaño total de archivos en bytes
  int get totalSize => files.fold(0, (sum, file) => sum + file.size);

  /// Verificar si hay archivos con errores
  bool get hasErrors => files.any((file) => file.hasErrors);

  /// Verificar si se pueden agregar más archivos
  bool get canAddMoreFiles => files.length < config.maxFilesPerOrder;

  /// Archivos disponibles para agregar
  int get availableSlots => config.maxFilesPerOrder - files.length;
}

@riverpod
class PrintOrder extends _$PrintOrder {
  @override
  PrintOrderState build() {
    return PrintOrderState();
  }

  /// Agregar archivos
  void addFiles(List<UploadedFile> newFiles) {
    final currentFiles = state.files;
    final availableSlots = state.availableSlots;

    if (availableSlots == 0) {
      state = state.copyWith(
        error: 'Máximo ${state.config.maxFilesPerOrder} archivos permitidos',
      );
      // Limpiar error después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(error: null);
      });
      return;
    }

    final filesToAdd = newFiles.take(availableSlots).toList();
    final updatedFiles = [...currentFiles, ...filesToAdd];

    state = state.copyWith(files: updatedFiles);

    if (newFiles.length > availableSlots) {
      state = state.copyWith(
        error: 'Solo se pueden agregar $availableSlots archivos más',
      );
      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(error: null);
      });
    }
  }

  /// Eliminar archivo
  void removeFile(String id) {
    final updatedFiles = state.files.where((f) => f.id != id).toList();
    state = state.copyWith(files: updatedFiles);
  }

  /// Limpiar todos los archivos
  void clearFiles() {
    state = state.copyWith(files: []);
  }

  /// Actualizar configuración
  void updateConfig(FileUploadConfig config) {
    state = state.copyWith(config: config);
  }

  /// Validar y analizar archivos (llamada al backend)
  Future<void> analyzeFiles() async {
    if (state.files.isEmpty) {
      state = state.copyWith(error: 'Debes subir al menos un archivo');
      return;
    }

    if (state.hasErrors) {
      state = state.copyWith(error: 'Algunos archivos tienen errores');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Llamar al backend para analizar archivos
      // final response = await _repository.analyzeFiles(state.files);
      
      // Simular llamada al backend
      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al analizar archivos: $e',
      );
    }
  }
}