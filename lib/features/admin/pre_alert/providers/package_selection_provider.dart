import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_selection_provider.g.dart';

@riverpod
class PackageSelection extends _$PackageSelection {
  @override
  Set<String> build() => {};

  void toggleSelection(String packageId) {
    final current = Set<String>.from(state);
    if (current.contains(packageId)) {
      current.remove(packageId);
    } else {
      current.add(packageId);
    }
    state = current;
  }

  void selectAll(List<String> packageIds) {
    state = Set<String>.from(packageIds);
  }

  void clearSelection() {
    state = {};
  }

  bool isSelected(String packageId) {
    return state.contains(packageId);
  }

  int get selectedCount => state.length;
}

