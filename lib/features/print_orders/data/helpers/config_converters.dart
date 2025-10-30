// lib/features/print_orders/data/helpers/config_converters.dart
// Helpers para convertir entre los enums del UI y los strings del backend

import '../../providers/print_configuration_state_provider.dart';

class ConfigConverters {
  // ====== Print Type ======
  static String printTypeToString(PrintType type) {
    switch (type) {
      case PrintType.blackWhite:
        return 'bw';
      case PrintType.color:
        return 'color';
    }
  }

  static PrintType printTypeFromString(String type) {
    switch (type) {
      case 'bw':
        return PrintType.blackWhite;
      case 'color':
        return PrintType.color;
      default:
        return PrintType.blackWhite;
    }
  }

  // ====== Paper Size ======
  static String paperSizeToString(PaperSize size) {
    switch (size) {
      case PaperSize.letter:
        return 'letter';
      case PaperSize.legal:
        return 'legal';
      case PaperSize.doubleLetter:
        return 'double_letter';
    }
  }

  static PaperSize paperSizeFromString(String size) {
    switch (size) {
      case 'letter':
        return PaperSize.letter;
      case 'legal':
        return PaperSize.legal;
      case 'double_letter':
        return PaperSize.doubleLetter;
      default:
        return PaperSize.letter;
    }
  }

  // ====== Paper Type ======
  static String paperTypeToString(PaperType type) {
    switch (type) {
      case PaperType.bond:
        return 'bond';
      case PaperType.glossy:
        return 'photo_glossy';
    }
  }

  static PaperType paperTypeFromString(String type) {
    switch (type) {
      case 'bond':
        return PaperType.bond;
      case 'photo_glossy':
        return PaperType.glossy;
      default:
        return PaperType.bond;
    }
  }

  // ====== Orientation ======
  static String orientationToString(Orientation orientation) {
    switch (orientation) {
      case Orientation.vertical:
        return 'portrait';
      case Orientation.horizontal:
        return 'landscape';
    }
  }

  static Orientation orientationFromString(String orientation) {
    switch (orientation) {
      case 'portrait':
        return Orientation.vertical;
      case 'landscape':
        return Orientation.horizontal;
      default:
        return Orientation.vertical;
    }
  }
}