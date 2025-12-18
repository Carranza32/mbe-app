// lib/features/auth/providers/register_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_provider.g.dart';

class RegisterState {
  // Step 1
  final String country;
  final String language;
  final String fullName;
  final String email;
  final String documentType;
  final String documentNumber;
  
  // Step 2
  final String preferredStore;
  final String department;
  final String city;
  final String address;
  final String references;
  
  // Step 3
  final String cellPhone;
  final String homePhone;
  final String workPhone;
  final String fax;
  
  // Step 4
  final String password;
  final String confirmPassword;

  RegisterState({
    this.country = '',
    this.language = '',
    this.fullName = '',
    this.email = '',
    this.documentType = '',
    this.documentNumber = '',
    this.preferredStore = '',
    this.department = '',
    this.city = '',
    this.address = '',
    this.references = '',
    this.cellPhone = '',
    this.homePhone = '',
    this.workPhone = '',
    this.fax = '',
    this.password = '',
    this.confirmPassword = '',
  });

  RegisterState copyWith({
    String? country,
    String? language,
    String? fullName,
    String? email,
    String? documentType,
    String? documentNumber,
    String? preferredStore,
    String? department,
    String? city,
    String? address,
    String? references,
    String? cellPhone,
    String? homePhone,
    String? workPhone,
    String? fax,
    String? password,
    String? confirmPassword,
  }) {
    return RegisterState(
      country: country ?? this.country,
      language: language ?? this.language,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      preferredStore: preferredStore ?? this.preferredStore,
      department: department ?? this.department,
      city: city ?? this.city,
      address: address ?? this.address,
      references: references ?? this.references,
      cellPhone: cellPhone ?? this.cellPhone,
      homePhone: homePhone ?? this.homePhone,
      workPhone: workPhone ?? this.workPhone,
      fax: fax ?? this.fax,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  bool canContinue(int step) {
    switch (step) {
      case 1:
        return country.isNotEmpty &&
            language.isNotEmpty &&
            fullName.isNotEmpty &&
            email.isNotEmpty &&
            documentType.isNotEmpty &&
            documentNumber.isNotEmpty;
      case 2:
        return preferredStore.isNotEmpty &&
            department.isNotEmpty &&
            city.isNotEmpty &&
            address.isNotEmpty;
      case 3:
        return cellPhone.isNotEmpty && cellPhone.length >= 8;
      case 4:
        return password.isNotEmpty && passwordsMatch && isPasswordValid;
      default:
        return false;
    }
  }

  bool get passwordsMatch => password == confirmPassword && confirmPassword.isNotEmpty;
  
  bool get isPasswordValid {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }

  bool get isValid => canContinue(1) && canContinue(2) && canContinue(3) && canContinue(4);
}

@riverpod
class Register extends _$Register {
  @override
  RegisterState build() => RegisterState();

  void setCountry(String value) => state = state.copyWith(country: value);
  void setLanguage(String value) => state = state.copyWith(language: value);
  void setFullName(String value) => state = state.copyWith(fullName: value);
  void setEmail(String value) => state = state.copyWith(email: value);
  void setDocumentType(String value) => state = state.copyWith(documentType: value);
  void setDocumentNumber(String value) => state = state.copyWith(documentNumber: value);
  
  void setPreferredStore(String value) => state = state.copyWith(preferredStore: value);
  void setDepartment(String value) => state = state.copyWith(department: value);
  void setCity(String value) => state = state.copyWith(city: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setReferences(String value) => state = state.copyWith(references: value);
  
  void setCellPhone(String value) => state = state.copyWith(cellPhone: value);
  void setHomePhone(String value) => state = state.copyWith(homePhone: value);
  void setWorkPhone(String value) => state = state.copyWith(workPhone: value);
  void setFax(String value) => state = state.copyWith(fax: value);
  
  void setPassword(String value) => state = state.copyWith(password: value);
  void setConfirmPassword(String value) => state = state.copyWith(confirmPassword: value);

  void reset() => state = RegisterState();
}

@riverpod
class RegisterStep extends _$RegisterStep {
  @override
  int build() => 1;

  void next() {
    if (state < 4) state++;
  }

  void previous() {
    if (state > 1) state--;
  }

  void goTo(int step) {
    if (step >= 1 && step <= 4) state = step;
  }

  void reset() => state = 1;
}