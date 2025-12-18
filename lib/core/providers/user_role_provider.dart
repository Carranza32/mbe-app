import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';

part 'user_role_provider.g.dart';

@riverpod
bool isAdmin(Ref ref) {
  final user = ref.watch(authProvider).value;
  return user?.isAdmin ?? false;
}

