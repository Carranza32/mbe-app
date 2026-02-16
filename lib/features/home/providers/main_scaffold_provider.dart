import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_scaffold_provider.g.dart';

// Provider que expone el GlobalKey del Scaffold de MainScreen
@riverpod
class MainScaffoldKey extends _$MainScaffoldKey {
  @override
  GlobalKey<ScaffoldState>? build() => null;

  void setScaffoldKey(GlobalKey<ScaffoldState> key) {
    state = key;
  }
}
