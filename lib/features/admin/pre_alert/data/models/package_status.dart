enum PackageStatus {
  ingresada,              // id: 1 - Pre Alerta Ingresada
  listaParaRecibir,       // id: 2 - Lista para Recibir
  enTienda,              // id: 3 - Paquete en Tienda
  solicitudRecoleccion,   // id: 4 - Solicitud de Recolección
  confirmadaRecoleccion,  // id: 5 - Recolección Confirmada
  enRuta,                 // id: 6 - En Ruta de Entrega
  entregada,              // id: 7 - Entregada al Cliente (Delivery)
  retornada,              // id: 8 - Retornada a Tienda
  listaRetiro,            // id: 9 - Lista para Retiro
  completada,             // id: 10 - Entregada en Tienda (Pickup)
  cancelada,              // id: 11 - Cancelada
}

extension PackageStatusExtension on PackageStatus {
  String get label {
    switch (this) {
      case PackageStatus.ingresada:
        return 'Pre Alerta Ingresada';
      case PackageStatus.listaParaRecibir:
        return 'Lista para Recibir';
      case PackageStatus.enTienda:
        return 'Paquete en Tienda';
      case PackageStatus.solicitudRecoleccion:
        return 'Solicitud de Recolección';
      case PackageStatus.confirmadaRecoleccion:
        return 'Recolección Confirmada';
      case PackageStatus.enRuta:
        return 'En Ruta de Entrega';
      case PackageStatus.entregada:
        return 'Entregada al Cliente';
      case PackageStatus.retornada:
        return 'Retornada a Tienda';
      case PackageStatus.listaRetiro:
        return 'Lista para Retiro';
      case PackageStatus.completada:
        return 'Entregada en Tienda';
      case PackageStatus.cancelada:
        return 'Cancelada';
    }
  }

  String get key {
    switch (this) {
      case PackageStatus.ingresada:
        return 'ingresada';
      case PackageStatus.listaParaRecibir:
        return 'lista_para_recibir';
      case PackageStatus.enTienda:
        return 'en_tienda';
      case PackageStatus.solicitudRecoleccion:
        return 'solicitud_recoleccion';
      case PackageStatus.confirmadaRecoleccion:
        return 'confirmada_recoleccion';
      case PackageStatus.enRuta:
        return 'en_ruta';
      case PackageStatus.entregada:
        return 'entregada';
      case PackageStatus.retornada:
        return 'retornada';
      case PackageStatus.listaRetiro:
        return 'lista_retiro';
      case PackageStatus.completada:
        return 'completada';
      case PackageStatus.cancelada:
        return 'cancelada';
    }
  }

  int get statusId {
    switch (this) {
      case PackageStatus.ingresada:
        return 1;
      case PackageStatus.listaParaRecibir:
        return 2;
      case PackageStatus.enTienda:
        return 3;
      case PackageStatus.solicitudRecoleccion:
        return 4;
      case PackageStatus.confirmadaRecoleccion:
        return 5;
      case PackageStatus.enRuta:
        return 6;
      case PackageStatus.entregada:
        return 7;
      case PackageStatus.retornada:
        return 8;
      case PackageStatus.listaRetiro:
        return 9;
      case PackageStatus.completada:
        return 10;
      case PackageStatus.cancelada:
        return 11;
    }
  }

  static PackageStatus? fromKey(String key) {
    switch (key) {
      case 'ingresada':
        return PackageStatus.ingresada;
      case 'lista_para_recibir':
        return PackageStatus.listaParaRecibir;
      case 'en_tienda':
        return PackageStatus.enTienda;
      case 'solicitud_recoleccion':
        return PackageStatus.solicitudRecoleccion;
      case 'confirmada_recoleccion':
        return PackageStatus.confirmadaRecoleccion;
      case 'en_ruta':
        return PackageStatus.enRuta;
      case 'entregada':
        return PackageStatus.entregada;
      case 'retornada':
        return PackageStatus.retornada;
      case 'lista_retiro':
        return PackageStatus.listaRetiro;
      case 'completada':
        return PackageStatus.completada;
      case 'cancelada':
        return PackageStatus.cancelada;
      default:
        return null;
    }
  }

  static PackageStatus? fromStatusId(int statusId) {
    switch (statusId) {
      case 1:
        return PackageStatus.ingresada;
      case 2:
        return PackageStatus.listaParaRecibir;
      case 3:
        return PackageStatus.enTienda;
      case 4:
        return PackageStatus.solicitudRecoleccion;
      case 5:
        return PackageStatus.confirmadaRecoleccion;
      case 6:
        return PackageStatus.enRuta;
      case 7:
        return PackageStatus.entregada;
      case 8:
        return PackageStatus.retornada;
      case 9:
        return PackageStatus.listaRetiro;
      case 10:
        return PackageStatus.completada;
      case 11:
        return PackageStatus.cancelada;
      default:
        return null;
    }
  }
}

