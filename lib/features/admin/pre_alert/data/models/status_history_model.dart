/// Modelo para la información de un estado
class StatusInfo {
  final int id;
  final String name;
  final String label;
  final String? color;

  StatusInfo({
    required this.id,
    required this.name,
    required this.label,
    this.color,
  });

  factory StatusInfo.fromJson(Map<String, dynamic> json) {
    return StatusInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      label: json['label'] as String,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'color': color,
    };
  }
}

/// Modelo para el estado anterior (puede ser null)
class PreviousStatusInfo {
  final int id;
  final String name;
  final String label;

  PreviousStatusInfo({
    required this.id,
    required this.name,
    required this.label,
  });

  factory PreviousStatusInfo.fromJson(Map<String, dynamic> json) {
    return PreviousStatusInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
    };
  }
}

/// Modelo para información de quién hizo el cambio
class ChangedByInfo {
  final int id;
  final String name;
  final String email;

  ChangedByInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ChangedByInfo.fromJson(Map<String, dynamic> json) {
    return ChangedByInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

/// Modelo para una entrada del historial de estados
class StatusHistoryItem {
  final int id;
  final StatusInfo status;
  final PreviousStatusInfo? previousStatus;
  final ChangedByInfo changedBy;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime changedAt;

  StatusHistoryItem({
    required this.id,
    required this.status,
    this.previousStatus,
    required this.changedBy,
    this.notes,
    this.metadata,
    required this.changedAt,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      id: json['id'] as int,
      status: StatusInfo.fromJson(json['status'] as Map<String, dynamic>),
      previousStatus: json['previous_status'] != null
          ? PreviousStatusInfo.fromJson(
              json['previous_status'] as Map<String, dynamic>)
          : null,
      changedBy: ChangedByInfo.fromJson(
          json['changed_by'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      metadata: json['metadata'] != null
          ? json['metadata'] as Map<String, dynamic>
          : null,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.toJson(),
      'previous_status': previousStatus?.toJson(),
      'changed_by': changedBy.toJson(),
      'notes': notes,
      'metadata': metadata,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}

/// Modelo para la respuesta del historial de estados
class StatusHistoryResponse {
  final bool status;
  final String message;
  final List<StatusHistoryItem> data;

  StatusHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StatusHistoryResponse.fromJson(Map<String, dynamic> json) {
    return StatusHistoryResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((item) => StatusHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

