import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'recent_searches_provider.g.dart';

@riverpod
class RecentSearches extends _$RecentSearches {
  static const String _key = 'recent_searches_pre_alerts';
  static const int _maxSearches = 10;

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// Agregar una búsqueda reciente
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final current = await future;
    final trimmedQuery = query.trim();

    // Remover si ya existe
    final updated = current.where((q) => q != trimmedQuery).toList();
    
    // Agregar al inicio
    updated.insert(0, trimmedQuery);

    // Limitar a máximo
    if (updated.length > _maxSearches) {
      updated.removeRange(_maxSearches, updated.length);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated);
    
    state = AsyncData(updated);
  }

  /// Limpiar todas las búsquedas recientes
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncData([]);
  }

  /// Remover una búsqueda específica
  Future<void> removeSearch(String query) async {
    final current = await future;
    final updated = current.where((q) => q != query).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated);
    
    state = AsyncData(updated);
  }
}

