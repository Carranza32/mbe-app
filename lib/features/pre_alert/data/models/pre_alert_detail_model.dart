/// Modelo del detalle de una pre-alerta (GET /pre-alerts/{id})
class PreAlertDetail {
  final int id;
  final String trackNumber;
  final double? total;
  final int? productCount;
  final List<PreAlertDetailProduct> products;
  final PreAlertDetailStore? store;
  final PreAlertDetailCustomer? customer;
  final PreAlertDetailStatus? currentStatus;
  final PreAlertDetailAddress? customerAddress;
  final PreAlertDetailBillInfo? billInfo;
  final List<PreAlertDetailStatusHistoryItem> statusHistory;
  final PreAlertDetailPaymentSummary? paymentSummary;

  PreAlertDetail({
    required this.id,
    required this.trackNumber,
    this.total,
    this.productCount,
    this.products = const [],
    this.store,
    this.customer,
    this.currentStatus,
    this.customerAddress,
    this.billInfo,
    this.statusHistory = const [],
    this.paymentSummary,
  });

  factory PreAlertDetail.fromJson(Map<String, dynamic> json) {
    final productsRaw = json['products'];
    final productsList = productsRaw is List ? productsRaw : <dynamic>[];
    final historyRaw = json['status_history'];
    final historyList = historyRaw is List ? historyRaw : <dynamic>[];

    final List<PreAlertDetailProduct> products = [];
    for (final e in productsList) {
      if (e is Map<String, dynamic>) {
        try {
          products.add(PreAlertDetailProduct.fromJson(e));
        } catch (_) {}
      }
    }

    final List<PreAlertDetailStatusHistoryItem> statusHistory = [];
    for (final e in historyList) {
      if (e is Map<String, dynamic>) {
        try {
          statusHistory.add(PreAlertDetailStatusHistoryItem.fromJson(e));
        } catch (_) {}
      }
    }

    PreAlertDetailStore? store;
    if (json['store'] is Map<String, dynamic>) {
      try {
        store = PreAlertDetailStore.fromJson(json['store'] as Map<String, dynamic>);
      } catch (_) {}
    }

    PreAlertDetailCustomer? customer;
    if (json['customer'] is Map<String, dynamic>) {
      try {
        customer = PreAlertDetailCustomer.fromJson(json['customer'] as Map<String, dynamic>);
      } catch (_) {}
    }
    if (customer == null &&
        (json['contact_name'] != null || json['contact_email'] != null)) {
      customer = PreAlertDetailCustomer(
        id: (json['customer_id'] as num?)?.toInt(),
        name: json['contact_name']?.toString() ?? '',
        email: json['contact_email']?.toString(),
        phone: json['contact_phone']?.toString(),
        lockerCode: json['package_code']?.toString(),
      );
    }

    PreAlertDetailStatus? currentStatus;
    if (json['current_status'] is Map<String, dynamic>) {
      try {
        currentStatus = PreAlertDetailStatus.fromJson(json['current_status'] as Map<String, dynamic>);
      } catch (_) {}
    }

    PreAlertDetailAddress? customerAddress;
    if (json['customer_address'] is Map<String, dynamic>) {
      try {
        customerAddress = PreAlertDetailAddress.fromJson(json['customer_address'] as Map<String, dynamic>);
      } catch (_) {}
    }

    PreAlertDetailBillInfo? billInfo;
    if (json['bill_info'] is Map<String, dynamic>) {
      try {
        billInfo = PreAlertDetailBillInfo.fromJson(json['bill_info'] as Map<String, dynamic>);
      } catch (_) {}
    }

    PreAlertDetailPaymentSummary? paymentSummary;
    if (json['payment_summary'] is Map<String, dynamic>) {
      try {
        paymentSummary = PreAlertDetailPaymentSummary.fromJson(json['payment_summary'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return PreAlertDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      trackNumber: (json['track_number'] ?? json['tracking_number'] ?? '').toString(),
      total: (json['total'] as num?)?.toDouble(),
      productCount: (json['product_count'] as num?)?.toInt(),
      products: products,
      store: store,
      customer: customer,
      currentStatus: currentStatus,
      customerAddress: customerAddress,
      billInfo: billInfo,
      statusHistory: statusHistory,
      paymentSummary: paymentSummary,
    );
  }
}

class PreAlertDetailProduct {
  final int? id;
  final String? name;
  final int quantity;
  final double price;
  final String? categoryName;

  PreAlertDetailProduct({
    this.id,
    this.name,
    required this.quantity,
    required this.price,
    this.categoryName,
  });

  factory PreAlertDetailProduct.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailProduct(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: ((json['price'] ?? json['unit_price']) as num?)?.toDouble() ?? 0,
      categoryName: json['category_name']?.toString() ?? json['product_category']?['name']?.toString(),
    );
  }
}

class PreAlertDetailStore {
  final int? id;
  final String name;

  PreAlertDetailStore({this.id, required this.name});

  factory PreAlertDetailStore.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailStore(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
    );
  }
}

class PreAlertDetailCustomer {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? lockerCode;

  PreAlertDetailCustomer({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.lockerCode,
  });

  factory PreAlertDetailCustomer.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailCustomer(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      lockerCode: json['locker_code']?.toString(),
    );
  }
}

class PreAlertDetailStatus {
  final int? id;
  final String name;
  final String? label;
  final String? color;

  PreAlertDetailStatus({this.id, required this.name, this.label, this.color});

  factory PreAlertDetailStatus.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailStatus(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString(),
      color: json['color']?.toString(),
    );
  }

  String get displayLabel => label ?? name;
}

class PreAlertDetailAddress {
  final int? id;
  final String? name;
  final String? addressLine1;
  final String? city;
  final String? region;
  final String? country;
  final String? phone;

  PreAlertDetailAddress({
    this.id,
    this.name,
    this.addressLine1,
    this.city,
    this.region,
    this.country,
    this.phone,
  });

  factory PreAlertDetailAddress.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailAddress(
      id: (json['id'] as num?)?.toInt(),
      name: json['name']?.toString(),
      addressLine1: json['address_line1']?.toString() ?? json['address']?.toString(),
      city: json['city']?.toString(),
      region: json['region']?.toString() ?? json['state']?.toString(),
      country: json['country']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  String get fullAddress {
    final parts = [addressLine1, city, region, country].where((e) => e != null && e.toString().trim().isNotEmpty);
    return parts.join(', ');
  }
}

class PreAlertDetailBillInfo {
  final String? name;
  final String? size;
  final String? url;
  final String? mimeType;

  PreAlertDetailBillInfo({this.name, this.size, this.url, this.mimeType});

  factory PreAlertDetailBillInfo.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailBillInfo(
      name: json['name']?.toString(),
      size: json['size']?.toString(),
      url: json['url']?.toString(),
      mimeType: json['mime_type']?.toString(),
    );
  }
}

class PreAlertDetailStatusHistoryItem {
  final int? id;
  final PreAlertDetailStatus? status;
  final PreAlertDetailStatus? previousStatus;
  final String? notes;
  final DateTime? changedAt;

  PreAlertDetailStatusHistoryItem({
    this.id,
    this.status,
    this.previousStatus,
    this.notes,
    this.changedAt,
  });

  factory PreAlertDetailStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailStatusHistoryItem(
      id: (json['id'] as num?)?.toInt(),
      status: json['status'] != null
          ? PreAlertDetailStatus.fromJson(json['status'] as Map<String, dynamic>)
          : null,
      previousStatus: json['previous_status'] != null
          ? PreAlertDetailStatus.fromJson(json['previous_status'] as Map<String, dynamic>)
          : null,
      notes: json['notes']?.toString(),
      changedAt: json['changed_at'] != null
          ? DateTime.tryParse(json['changed_at'].toString())
          : null,
    );
  }
}

class PreAlertDetailPaymentSummary {
  final bool isPaid;
  final double? totalPaid;
  final double? finalTotal;
  final PreAlertDetailLastPayment? lastPayment;

  PreAlertDetailPaymentSummary({
    required this.isPaid,
    this.totalPaid,
    this.finalTotal,
    this.lastPayment,
  });

  factory PreAlertDetailPaymentSummary.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailPaymentSummary(
      isPaid: json['is_paid'] == true,
      totalPaid: (json['total_paid'] as num?)?.toDouble(),
      finalTotal: (json['final_total'] as num?)?.toDouble(),
      lastPayment: json['last_payment'] != null
          ? PreAlertDetailLastPayment.fromJson(json['last_payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PreAlertDetailLastPayment {
  final int? id;
  final String? status;
  final double? amount;
  final String? currency;
  final DateTime? completedAt;

  PreAlertDetailLastPayment({
    this.id,
    this.status,
    this.amount,
    this.currency,
    this.completedAt,
  });

  factory PreAlertDetailLastPayment.fromJson(Map<String, dynamic> json) {
    return PreAlertDetailLastPayment(
      id: (json['id'] as num?)?.toInt(),
      status: json['status']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency']?.toString(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }
}
