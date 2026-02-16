// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentConfigs)
const documentConfigsProvider = DocumentConfigsProvider._();

final class DocumentConfigsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DocumentConfigs>,
          DocumentConfigs,
          FutureOr<DocumentConfigs>
        >
    with $FutureModifier<DocumentConfigs>, $FutureProvider<DocumentConfigs> {
  const DocumentConfigsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentConfigsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentConfigsHash();

  @$internal
  @override
  $FutureProviderElement<DocumentConfigs> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DocumentConfigs> create(Ref ref) {
    return documentConfigs(ref);
  }
}

String _$documentConfigsHash() => r'a11aada6a97e3a8027cd8e7066a4e08ebd04f2db';
