// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pre_alert_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(preAlertDetail)
const preAlertDetailProvider = PreAlertDetailFamily._();

final class PreAlertDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<PreAlertDetail>,
          PreAlertDetail,
          FutureOr<PreAlertDetail>
        >
    with $FutureModifier<PreAlertDetail>, $FutureProvider<PreAlertDetail> {
  const PreAlertDetailProvider._({
    required PreAlertDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'preAlertDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$preAlertDetailHash();

  @override
  String toString() {
    return r'preAlertDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PreAlertDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PreAlertDetail> create(Ref ref) {
    final argument = this.argument as String;
    return preAlertDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PreAlertDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$preAlertDetailHash() => r'c72f31690e5ed596d046acc78350a5b18e8f0468';

final class PreAlertDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PreAlertDetail>, String> {
  const PreAlertDetailFamily._()
    : super(
        retry: null,
        name: r'preAlertDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PreAlertDetailProvider call(String preAlertId) =>
      PreAlertDetailProvider._(argument: preAlertId, from: this);

  @override
  String toString() => r'preAlertDetailProvider';
}
