// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PrintConfig)
const printConfigProvider = PrintConfigProvider._();

final class PrintConfigProvider
    extends $AsyncNotifierProvider<PrintConfig, PrintConfigurationModel> {
  const PrintConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printConfigHash();

  @$internal
  @override
  PrintConfig create() => PrintConfig();
}

String _$printConfigHash() => r'a5a7dd7bdc25a4f4ab03f806d6e11984aee1a683';

abstract class _$PrintConfig extends $AsyncNotifier<PrintConfigurationModel> {
  FutureOr<PrintConfigurationModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PrintConfigurationModel>,
              PrintConfigurationModel
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PrintConfigurationModel>,
                PrintConfigurationModel
              >,
              AsyncValue<PrintConfigurationModel>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
