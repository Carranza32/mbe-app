// lib/features/print_orders/data/models/print_order_detail.dart
import 'package:flutter/material.dart';

class PrintOrderDetail {
  final String orderNumber;
  final String status;
  final DateTime createdAt;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final double total;
  final int pagesCount;
  final List<dynamic> files;
  final OrderConfig config;
  final OrderDelivery delivery;
  final List<OrderHistory> history;

  PrintOrderDetail({
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.total,
    required this.pagesCount,
    required this.files,
    required this.config,
    required this.delivery,
    required this.history,
  });

  factory PrintOrderDetail.fromJson(Map<String, dynamic> json) {
    return PrintOrderDetail(
      orderNumber: json['orderNumber'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      total: (json['total'] as num).toDouble(),
      pagesCount: json['pagesCount'],
      files: json['files'] as List,
      config: OrderConfig.fromJson(json['config']),
      delivery: OrderDelivery.fromJson(json['delivery']),
      history: (json['history'] as List)
          .map((h) => OrderHistory.fromJson(h))
          .toList(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'printing': return 'Imprimiendo';
      case 'ready': return 'Listo';
      case 'delivered': return 'Entregado';
      case 'cancelled': return 'Cancelado';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending': return const Color(0xFFEAB308);
      case 'printing': return const Color(0xFF8B5CF6);
      case 'ready': return const Color(0xFF10B981);
      case 'delivered': return const Color(0xFF3B82F6);
      case 'cancelled': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }
}

class OrderConfig {
  final String printType;
  final String paperSize;
  final int copies;
  final bool binding;

  OrderConfig({
    required this.printType,
    required this.paperSize,
    required this.copies,
    required this.binding,
  });

  factory OrderConfig.fromJson(Map<String, dynamic> json) {
    return OrderConfig(
      printType: json['printType'],
      paperSize: json['paperSize'],
      copies: json['copies'],
      binding: json['binding'],
    );
  }

  String get printTypeLabel {
    return printType == 'color' ? 'Color' : 'Blanco y Negro';
  }

  String get paperSizeLabel {
    return paperSize.toUpperCase();
  }
}

class OrderDelivery {
  final String method;
  final String? location;

  OrderDelivery({
    required this.method,
    this.location,
  });

  factory OrderDelivery.fromJson(Map<String, dynamic> json) {
    return OrderDelivery(
      method: json['method'],
      location: json['location'],
    );
  }

  String get methodLabel {
    return method == 'pickup' ? 'Recoger en tienda' : 'Envío a domicilio';
  }
}

class OrderHistory {
  final String status;
  final DateTime timestamp;
  final String comment;

  OrderHistory({
    required this.status,
    required this.timestamp,
    required this.comment,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      comment: json['comment'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pendiente';
      case 'printing': return 'Imprimiendo';
      case 'ready': return 'Listo';
      case 'delivered': return 'Entregado';
      default: return status;
    }
  }
}