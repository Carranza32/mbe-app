import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/trends_response_model.dart';

part 'trends_repository.g.dart';

@riverpod
TrendsRepository trendsRepository(Ref ref) {
  return TrendsRepository(ref.read(apiServiceProvider));
}

class TrendsRepository {
  final ApiService _apiService;

  TrendsRepository(this._apiService);

  /// GET /trends - No requiere autenticación.
  Future<TrendsData> getTrends() async {
    return _apiService.get<TrendsData>(
      endpoint: ApiEndpoints.trends,
      fromJson: (json) => TrendsData.fromJson(json as Map<String, dynamic>),
    );
  }
}
