import 'admin_pre_alert_model.dart';
import 'customer_address_model.dart';
import 'customer_detail_model.dart';

/// Respuesta de GET /api/v1/admin/pre-alerts/{id} con customer y addresses para "Completar información".
class PreAlertDetailResponse {
  final AdminPreAlert package;
  final CustomerDetail customer;

  PreAlertDetailResponse({
    required this.package,
    required this.customer,
  });

  factory PreAlertDetailResponse.fromJson(Map<String, dynamic> json) {
    final data = json.containsKey('data') ? json['data'] as Map<String, dynamic> : json;
    final Map<String, dynamic> packageJson = data.containsKey('package')
        ? data['package'] as Map<String, dynamic>
        : data;
    final customerJson = data['customer'] as Map<String, dynamic>?;
    // addresses suele venir como customer.addresses; también puede estar en data.addresses
    final addressesRaw = (customerJson?['addresses'] as List<dynamic>?) ??
        (data['addresses'] as List<dynamic>?);
    final addressesList = addressesRaw
            ?.map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    // Ordenar por is_default DESC (dirección por defecto primero)
    addressesList.sort((a, b) => (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0));
    final customer = customerJson != null
        ? CustomerDetail(
            id: (customerJson['id'] as num?)?.toInt() ?? 0,
            name: customerJson['name'] as String? ??
                customerJson['full_name'] as String? ??
                '',
            email: customerJson['email'] as String?,
            phone: customerJson['phone'] as String?,
            lockerCode: customerJson['locker_code'] as String? ??
                customerJson['code'] as String?,
            addresses: addressesList,
          )
        : CustomerDetail(
            id: (data['customer_id'] as num?)?.toInt() ?? 0,
            name: data['client_name'] as String? ??
                packageJson['client_name'] as String? ??
                'N/A',
            email: data['contact_email'] as String?,
            phone: data['contact_phone'] as String?,
            lockerCode: data['locker_code'] as String?,
            addresses: addressesList,
          );
    return PreAlertDetailResponse(
      package: AdminPreAlert.fromJson(packageJson),
      customer: customer,
    );
  }
}
