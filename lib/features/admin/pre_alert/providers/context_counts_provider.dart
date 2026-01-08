import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/admin_pre_alerts_repository.dart';
import '../presentation/widgets/context_filter_segmented.dart';

part 'context_counts_provider.g.dart';

@riverpod
class ContextCounts extends _$ContextCounts {
  @override
  Future<Map<PackageContext, int>> build() async {
    final repository = ref.read(adminPreAlertsRepositoryProvider);
    
    final counts = <PackageContext, int>{};
    
    try {
      // Obtener totales de cada sección
      final porRecibir = await repository.getPreAlerts(
        statusFilter: 'por_recibir',
        perPage: 1,
        page: 1,
      );
      
      final enBodega = await repository.getPreAlerts(
        statusFilter: 'en_bodega',
        perPage: 1,
        page: 1,
      );
      
      final paraEntregar = await repository.getPreAlerts(
        statusFilter: 'para_entregar',
        perPage: 1,
        page: 1,
      );
      
      counts[PackageContext.porRecibir] = porRecibir.total;
      counts[PackageContext.enBodega] = enBodega.total;
      counts[PackageContext.paraEntregar] = paraEntregar.total;
      
      return counts;
    } catch (e) {
      // En caso de error, retornar ceros
      return {
        PackageContext.porRecibir: 0,
        PackageContext.enBodega: 0,
        PackageContext.paraEntregar: 0,
      };
    }
  }
  
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

