enum PackageStatus {
  enTransito,             // id: 1 - En Tránsito
  listaParaRecepcionar,   // id: 2 - Lista para Recepcionar
  disponibleParaRetiro,   // id: 3 - Disponible para Retiro
  solicitudRecoleccion,   // id: 4 - Solicitud de Recolección
  confirmadaRecoleccion,  // id: 5 - Recolección Confirmada
  enRuta,                 // id: 6 - En Ruta
  entregado,              // id: 7 - Entregado
  cancelado,              // id: 8 - Cancelado
}

extension PackageStatusExtension on PackageStatus {
  String get label {
    switch (this) {
      case PackageStatus.enTransito:
        return 'En Tránsito';
      case PackageStatus.listaParaRecepcionar:
        return 'Lista para Recepcionar';
      case PackageStatus.disponibleParaRetiro:
        return 'Disponible para Retiro';
      case PackageStatus.solicitudRecoleccion:
        return 'Solicitud de Recolección';
      case PackageStatus.confirmadaRecoleccion:
        return 'Recolección Confirmada';
      case PackageStatus.enRuta:
        return 'En Ruta';
      case PackageStatus.entregado:
        return 'Entregado';
      case PackageStatus.cancelado:
        return 'Cancelado';
    }
  }

  String get key {
    switch (this) {
      case PackageStatus.enTransito:
        return 'en_tránsito';
      case PackageStatus.listaParaRecepcionar:
        return 'lista_para_recepcionar';
      case PackageStatus.disponibleParaRetiro:
        return 'disponible_para_retiro';
      case PackageStatus.solicitudRecoleccion:
        return 'solicitud_recoleccion';
      case PackageStatus.confirmadaRecoleccion:
        return 'confirmada_recoleccion';
      case PackageStatus.enRuta:
        return 'en_ruta';
      case PackageStatus.entregado:
        return 'entregado';
      case PackageStatus.cancelado:
        return 'cancelado';
    }
  }

  int get statusId {
    switch (this) {
      case PackageStatus.enTransito:
        return 1;
      case PackageStatus.listaParaRecepcionar:
        return 2;
      case PackageStatus.disponibleParaRetiro:
        return 3;
      case PackageStatus.solicitudRecoleccion:
        return 4;
      case PackageStatus.confirmadaRecoleccion:
        return 5;
      case PackageStatus.enRuta:
        return 6;
      case PackageStatus.entregado:
        return 7;
      case PackageStatus.cancelado:
        return 8;
    }
  }

  /// True si el paquete ya pasó por recepción (está en tienda/bodega o ya fue entregado).
  bool get isAlreadyReceived {
    switch (this) {
      case PackageStatus.disponibleParaRetiro:
      case PackageStatus.solicitudRecoleccion:
      case PackageStatus.confirmadaRecoleccion:
      case PackageStatus.enRuta:
      case PackageStatus.entregado:
        return true;
      case PackageStatus.enTransito:
      case PackageStatus.listaParaRecepcionar:
      case PackageStatus.cancelado:
        return false;
    }
  }

  static PackageStatus? fromKey(String key) {
    // Normalizar: quitar tildes para comparación flexible
    final normalized = key.toLowerCase().replaceAll('á', 'a').replaceAll('í', 'i');
    switch (normalized) {
      case 'en_transito':
        return PackageStatus.enTransito;
      case 'lista_para_recepcionar':
        return PackageStatus.listaParaRecepcionar;
      case 'disponible_para_retiro':
        return PackageStatus.disponibleParaRetiro;
      case 'solicitud_recoleccion':
        return PackageStatus.solicitudRecoleccion;
      case 'confirmada_recoleccion':
        return PackageStatus.confirmadaRecoleccion;
      case 'en_ruta':
        return PackageStatus.enRuta;
      case 'entregado':
        return PackageStatus.entregado;
      case 'cancelado':
        return PackageStatus.cancelado;
      // Aliases para compatibilidad con respuestas legacy
      case 'ingresada':
        return PackageStatus.enTransito;
      case 'lista_para_recibir':
        return PackageStatus.listaParaRecepcionar;
      case 'en_tienda':
      case 'lista_retiro':
        return PackageStatus.disponibleParaRetiro;
      case 'entregada':
      case 'completada':
        return PackageStatus.entregado;
      case 'cancelada':
        return PackageStatus.cancelado;
      default:
        return null;
    }
  }

  static PackageStatus? fromStatusId(int statusId) {
    switch (statusId) {
      case 1:
        return PackageStatus.enTransito;
      case 2:
        return PackageStatus.listaParaRecepcionar;
      case 3:
        return PackageStatus.disponibleParaRetiro;
      case 4:
        return PackageStatus.solicitudRecoleccion;
      case 5:
        return PackageStatus.confirmadaRecoleccion;
      case 6:
        return PackageStatus.enRuta;
      case 7:
        return PackageStatus.entregado;
      case 8:
        return PackageStatus.cancelado;
      default:
        return null;
    }
  }
}
