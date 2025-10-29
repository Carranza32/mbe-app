import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'print_configuration_state_provider.g.dart';

/// Enums para las opciones
enum PrintType { blackWhite, color }
enum PaperSize { letter, legal, doubleLetter }
enum PaperType { bond, glossy }
enum Orientation { vertical, horizontal }

/// Estado de la configuración de impresión del usuario
class UserPrintConfiguration {
  final PrintType printType;
  final PaperSize paperSize;
  final PaperType paperType;
  final Orientation orientation;
  final int copies;
  final bool doubleSided;
  final bool binding;

  UserPrintConfiguration({
    this.printType = PrintType.blackWhite,
    this.paperSize = PaperSize.letter,
    this.paperType = PaperType.bond,
    this.orientation = Orientation.vertical,
    this.copies = 1,
    this.doubleSided = false,
    this.binding = false,
  });

  UserPrintConfiguration copyWith({
    PrintType? printType,
    PaperSize? paperSize,
    PaperType? paperType,
    Orientation? orientation,
    int? copies,
    bool? doubleSided,
    bool? binding,
  }) {
    return UserPrintConfiguration(
      printType: printType ?? this.printType,
      paperSize: paperSize ?? this.paperSize,
      paperType: paperType ?? this.paperType,
      orientation: orientation ?? this.orientation,
      copies: copies ?? this.copies,
      doubleSided: doubleSided ?? this.doubleSided,
      binding: binding ?? this.binding,
    );
  }
}

@riverpod
class PrintConfigurationState extends _$PrintConfigurationState {
  @override
  UserPrintConfiguration build() {
    return UserPrintConfiguration();
  }

  void setPrintType(PrintType type) {
    state = state.copyWith(printType: type);
  }

  void setPaperSize(PaperSize size) {
    state = state.copyWith(paperSize: size);
  }

  void setPaperType(PaperType type) {
    state = state.copyWith(paperType: type);
  }

  void setOrientation(Orientation orientation) {
    state = state.copyWith(orientation: orientation);
  }

  void setCopies(int copies) {
    state = state.copyWith(copies: copies);
  }

  void setDoubleSided(bool value) {
    state = state.copyWith(doubleSided: value);
  }

  void setBinding(bool value) {
    state = state.copyWith(binding: value);
  }

  void reset() {
    state = UserPrintConfiguration();
  }
}