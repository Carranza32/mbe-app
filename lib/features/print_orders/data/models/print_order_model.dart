// lib/features/print_orders/data/models/print_order_model.dart
import 'package:flutter/material.dart';

class PrintOrder {
  final int id;
  final String orderNumber;
  final String status;
  final String printType;
  final int pagesCount;
  final String total;
  final String deliveryMethod;
  final DateTime createdAt;

  PrintOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.printType,
    required this.pagesCount,
    required this.total,
    required this.deliveryMethod,
    required this.createdAt,
  });

  factory PrintOrder.fromJson(Map<String, dynamic> json) {
    return PrintOrder(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      status: json['status'] as String,
      printType: json['print_type'] as String,
      pagesCount: json['pages_count'] as int,
      total: json['total'] as String,
      deliveryMethod: json['delivery_method'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Helpers
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

class OrdersResponse {
  final List<PrintOrder> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  OrdersResponse({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['orders'] as List)
          .map((o) => PrintOrder.fromJson(o))
          .toList(),
      currentPage: json['pagination']['current_page'],
      lastPage: json['pagination']['last_page'],
      total: json['pagination']['total'],
    );
  }
}