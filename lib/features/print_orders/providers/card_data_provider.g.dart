// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CardDataNotifier)
const cardDataProvider = CardDataNotifierProvider._();

final class CardDataNotifierProvider
    extends $NotifierProvider<CardDataNotifier, CardData> {
  const CardDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardDataNotifierHash();

  @$internal
  @override
  CardDataNotifier create() => CardDataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardData>(value),
    );
  }
}

String _$cardDataNotifierHash() => r'618ad42ef0e4e87355fb51d9fed83206f10a223b';

abstract class _$CardDataNotifier extends $Notifier<CardData> {
  CardData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CardData, CardData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CardData, CardData>,
              CardData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
