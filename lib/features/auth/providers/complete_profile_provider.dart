// lib/features/auth/providers/complete_profile_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/models/customer_model.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/providers/auth_provider.dart';

part 'complete_profile_provider.g.dart';

class CompleteProfileState {
  final String phone;
  final String? homePhone;
  final String? documentType;
  final String? documentNumber;
  final bool isLoading;
  final Map<String, String> errors;
  final bool isInitialized;

  CompleteProfileState({
    this.phone = '',
    this.homePhone,
    this.documentType,
    this.documentNumber,
    this.isLoading = false,
    this.errors = const {},
    this.isInitialized = false,
  });

  CompleteProfileState copyWith({
    String? phone,
    String? homePhone,
    String? documentType,
    String? documentNumber,
    bool? isLoading,
    Map<String, String>? errors,
    bool? isInitialized,
  }) {
    return CompleteProfileState(
      phone: phone ?? this.phone,
      homePhone: homePhone ?? this.homePhone,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  bool get isValid {
    return phone.isNotEmpty &&
        documentType != null &&
        documentType!.isNotEmpty &&
        documentNumber != null &&
        documentNumber!.isNotEmpty;
  }
}

class SaveResult {
  final bool isSuccess;
  final String? error;

  SaveResult.success() : isSuccess = true, error = null;
  SaveResult.error(this.error) : isSuccess = false;

  T when<T>({
    required T Function() success,
    required T Function(String error) error,
    String? defaultError,
  }) {
    if (isSuccess) {
      return success();
    } else {
      return error(this.error ?? defaultError ?? 'Error desconocido');
    }
  }
}

@riverpod
class CompleteProfile extends _$CompleteProfile {
  @override
  CompleteProfileState build() {
    return CompleteProfileState();
  }

  void initializeFromCustomer(Customer customer) {
    // Solo inicializar si no se ha inicializado antes
    if (state.isInitialized) return;

    state = state.copyWith(
      phone: customer.phone ?? '',
      homePhone: customer.homePhone,
      documentType: customer.documentType,
      documentNumber: customer.cedulaRnc,
      isInitialized: true,
    );
  }

  void setPhone(String phone) {
    final currentErrors = Map<String, String>.from(state.errors);
    currentErrors.remove('phone');
    state = state.copyWith(phone: phone, errors: currentErrors);
  }

  void setHomePhone(String? homePhone) {
    final currentErrors = Map<String, String>.from(state.errors);
    currentErrors.remove('home_phone');
    state = state.copyWith(
      homePhone: homePhone?.isEmpty == true ? null : homePhone,
      errors: currentErrors,
    );
  }

  void setDocumentType(String? documentType) {
    final currentErrors = Map<String, String>.from(state.errors);
    currentErrors.remove('document_type');
    state = state.copyWith(documentType: documentType, errors: currentErrors);
  }

  void setDocumentNumber(String? documentNumber) {
    final currentErrors = Map<String, String>.from(state.errors);
    currentErrors.remove('cedula_rnc');
    state = state.copyWith(
      documentNumber: documentNumber?.isEmpty == true ? null : documentNumber,
      errors: currentErrors,
    );
  }

  Future<SaveResult> saveProfile(AppLocalizations l10n) async {
    if (!state.isValid) {
      return SaveResult.error(l10n.completeRequiredFields);
    }

    state = state.copyWith(isLoading: true, errors: const {});

    try {
      final repository = ref.read(authRepositoryProvider);
      final authState = ref.read(authProvider);
      final user = authState.value;

      if (user == null || user.customer == null) {
        state = state.copyWith(isLoading: false);
        return SaveResult.error(l10n.userNotFound);
      }

      // Obtener datos del customer actual para enviarlos también
      final customer = user.customer!;

      // Actualizar el perfil del customer
      await repository.updateCustomerProfile(
        phone: state.phone,
        homePhone: state.homePhone,
        documentType: state.documentType,
        documentNumber: state.documentNumber,
        name: customer.name,
        email: customer.email,
        officePhone: customer.officePhone,
        birthDate: customer.birthDate,
      );

      // Refrescar el usuario
      ref.invalidate(authProvider);

      state = state.copyWith(isLoading: false);
      return SaveResult.success();
    } catch (e) {
      state = state.copyWith(isLoading: false, errors: _parseErrors(e, l10n));
      return SaveResult.error(e.toString());
    }
  }

  Map<String, String> _parseErrors(dynamic error, AppLocalizations l10n) {
    // Si el error tiene estructura de validación del servidor
    if (error is Map<String, dynamic>) {
      final errors = <String, String>{};
      error.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors[key] = value.first.toString();
        } else if (value is String) {
          errors[key] = value;
        }
      });
      return errors;
    }

    // Si es un error de validación con formato específico
    final errorString = error.toString();
    if (errorString.contains('phone')) {
      return {'phone': l10n.phoneInvalid};
    }
    if (errorString.contains('document')) {
      return {'cedula_rnc': l10n.documentInvalid};
    }

    return {};
  }
}
