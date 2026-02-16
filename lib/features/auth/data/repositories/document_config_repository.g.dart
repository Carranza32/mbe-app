// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentConfigRepository)
const documentConfigRepositoryProvider = DocumentConfigRepositoryProvider._();

final class DocumentConfigRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentConfigRepository,
          DocumentConfigRepository,
          DocumentConfigRepository
        >
    with $Provider<DocumentConfigRepository> {
  const DocumentConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentConfigRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentConfigRepository create(Ref ref) {
    return documentConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentConfigRepository>(value),
    );
  }
}

String _$documentConfigRepositoryHash() =>
    r'84419964b236c17c67beece7debc7a37b8171a2c';
