import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/trends_response_model.dart';
import '../data/repositories/trends_repository.dart';

part 'trends_provider.g.dart';

@riverpod
Future<TrendsData> trends(Ref ref) async {
  final repository = ref.read(trendsRepositoryProvider);
  return repository.getTrends();
}
