// lib/features/profile/providers/addresses_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/address_model.dart';
import '../data/repositories/address_repository.dart';

part 'addresses_provider.g.dart';

@riverpod
Future<List<AddressModel>> addresses(Ref ref) async {
  final repository = ref.read(addressRepositoryProvider);
  return await repository.getAddresses();
}
