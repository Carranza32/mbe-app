// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PrintOrder)
const printOrderProvider = PrintOrderProvider._();

final class PrintOrderProvider
    extends $NotifierProvider<PrintOrder, PrintOrderState> {
  const PrintOrderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'printOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$printOrderHash();

  @$internal
  @override
  PrintOrder create() => PrintOrder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrintOrderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrintOrderState>(value),
    );
  }
}

String _$printOrderHash() => r'cdd6bea74c8af7fbbe2004d71270cdb5b060c028';

abstract class _$PrintOrder extends $Notifier<PrintOrderState> {
  PrintOrderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PrintOrderState, PrintOrderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PrintOrderState, PrintOrderState>,
              PrintOrderState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
