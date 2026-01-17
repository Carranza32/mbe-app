import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/address_model.dart';

/// Provider del repositorio de direcciones
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository(ref.read(apiServiceProvider));
});

class AddressRepository {
  final ApiService _apiService;

  AddressRepository(this._apiService);

  /// Obtener todas las direcciones del cliente
  Future<List<AddressModel>> getAddresses() async {
    return await _apiService.get<List<AddressModel>>(
      endpoint: ApiEndpoints.addresses,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );
  }

  /// Obtener una dirección específica por ID
  Future<AddressModel> getAddressById(String id) async {
    return await _apiService.get<AddressModel>(
      endpoint: ApiEndpoints.addressById(id),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Crear una nueva dirección
  Future<AddressModel> createAddress(AddressModel address) async {
    return await _apiService.post<AddressModel>(
      endpoint: ApiEndpoints.addresses,
      data: address.toJson(),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Actualizar una dirección existente
  Future<AddressModel> updateAddress(String id, AddressModel address) async {
    return await _apiService.put<AddressModel>(
      endpoint: ApiEndpoints.addressById(id),
      data: address.toJson(),
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Eliminar una dirección
  Future<void> deleteAddress(String id) async {
    await _apiService.delete<bool>(
      endpoint: ApiEndpoints.addressById(id),
    );
  }

  /// Establecer una dirección como predeterminada
  Future<AddressModel> setDefaultAddress(String id) async {
    return await _apiService.post<AddressModel>(
      endpoint: ApiEndpoints.setDefaultAddress(id),
      data: {},
      fromJson: (json) => AddressModel.fromJson(json as Map<String, dynamic>),
    );
  }
}

