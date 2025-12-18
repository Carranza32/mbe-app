enum PackageStatus {
  pendingConfirmation,
  readyToExport,
  delivery,
  pickup,
  exported,
}

extension PackageStatusExtension on PackageStatus {
  String get label {
    switch (this) {
      case PackageStatus.pendingConfirmation:
        return 'Pendiente confirmación';
      case PackageStatus.readyToExport:
        return 'Enviar/Recoger';
      case PackageStatus.delivery:
        return 'Delivery';
      case PackageStatus.pickup:
        return 'Pickup';
      case PackageStatus.exported:
        return 'Exportado';
    }
  }

  String get key {
    switch (this) {
      case PackageStatus.pendingConfirmation:
        return 'pending_confirmation';
      case PackageStatus.readyToExport:
        return 'ready_to_export';
      case PackageStatus.delivery:
        return 'delivery';
      case PackageStatus.pickup:
        return 'pickup';
      case PackageStatus.exported:
        return 'exported';
    }
  }

  static PackageStatus? fromKey(String key) {
    switch (key) {
      case 'pending_confirmation':
        return PackageStatus.pendingConfirmation;
      case 'ready_to_export':
        return PackageStatus.readyToExport;
      case 'delivery':
        return PackageStatus.delivery;
      case 'pickup':
        return PackageStatus.pickup;
      case 'exported':
        return PackageStatus.exported;
      default:
        return null;
    }
  }
}

