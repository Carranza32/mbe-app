// lib/features/print_orders/providers/print_order_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/uploaded_file_model.dart';
import '../data/models/file_upload_config.dart';
import '../data/repositories/print_order_repository.dart';

part 'print_order_provider.g.dart';

/// Estado del pedido de impresión
class PrintOrderState {
  final List<UploadedFile> files;
  final FileUploadConfig config;
  final bool isLoading;
  final String? error;
  final int? totalPages; // ← NUEVO: páginas totales

  PrintOrderState({
    this.files = const [],
    this.config = const FileUploadConfig(),
    this.isLoading = false,
    this.error,
    this.totalPages,
  });

  PrintOrderState copyWith({
    List<UploadedFile>? files,
    FileUploadConfig? config,
    bool? isLoading,
    String? error,
    int? totalPages,
  }) {
    return PrintOrderState(
      files: files ?? this.files,
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  int get totalFiles => files.length;
  int get totalSize => files.fold(0, (sum, file) => sum + file.size);
  bool get hasErrors => files.any((file) => file.hasErrors);
  bool get canAddMoreFiles => files.length < config.maxFilesPerOrder;
  int get availableSlots => config.maxFilesPerOrder - files.length;
  bool get canContinue => files.isNotEmpty && !hasErrors && totalPages != null;
}

@riverpod
class PrintOrder extends _$PrintOrder {
  @override
  PrintOrderState build() {
    return PrintOrderState();
  }

  void addFiles(List<UploadedFile> newFiles) {
    final currentFiles = state.files;
    final availableSlots = state.availableSlots;

    if (availableSlots == 0) {
      state = state.copyWith(
        error: 'Máximo ${state.config.maxFilesPerOrder} archivos permitidos',
      );
      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(error: null);
      });
      return;
    }

    final filesToAdd = newFiles.take(availableSlots).toList();
    final updatedFiles = [...currentFiles, ...filesToAdd];

    state = state.copyWith(files: updatedFiles, totalPages: null);

    if (newFiles.length > availableSlots) {
      state = state.copyWith(
        error: 'Solo se pueden agregar $availableSlots archivos más',
      );
      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(error: null);
      });
    }
  }

  void removeFile(String id) {
    final updatedFiles = state.files.where((f) => f.id != id).toList();
    state = state.copyWith(files: updatedFiles, totalPages: null);
  }

  void clearFiles() {
    state = state.copyWith(files: [], totalPages: null);
  }

  void updateConfig(FileUploadConfig config) {
    state = state.copyWith(config: config);
  }

  /// Analizar archivos y obtener total de páginas
  Future<bool> analyzeFiles() async {
    if (state.files.isEmpty) {
      state = state.copyWith(error: 'Debes subir al menos un archivo');
      return false;
    }

    if (state.hasErrors) {
      state = state.copyWith(error: 'Algunos archivos tienen errores');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(printOrderRepositoryProvider);
      final response = await repository.analyzeFiles(state.files);

      state = state.copyWith(
        isLoading: false,
        totalPages: response.totalPages,
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
}