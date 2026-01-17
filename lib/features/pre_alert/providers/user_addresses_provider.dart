import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/data/models/address_model.dart';
import '../../profile/data/repositories/address_repository.dart';

part 'user_addresses_provider.g.dart';

/// Provider estable para las direcciones del usuario
@riverpod
Future<List<AddressModel>> userAddresses(Ref ref) async {
  final repository = ref.read(addressRepositoryProvider);
  return await repository.getAddresses();
}
