// lib/features/print_orders/presentation/widgets/steps/step1_upload_files.dart
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';

// ✅ NUEVO: Usa el provider centralizado
import '../../../providers/create_order_provider.dart';
import '../../../providers/print_config_provider.dart';
import '../../../data/helpers/file_helpers.dart';
import '../../../data/models/file_upload_config.dart';
import '../files/drag_drop_zone.dart';
import '../files/file_list_item.dart';

class Step1UploadFiles extends HookConsumerWidget {
  const Step1UploadFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // ✅ CAMBIO: Usa el provider centralizado
    final orderState = ref.watch(createOrderProvider);
    final configAsync = ref.watch(printConfigProvider);

    // Hook para rastrear si ya se inicializó la config
    final configInitialized = useRef(false);

    // Inicializar config cuando esté disponible
    useEffect(() {
      configAsync.whenData((configModel) {
        if (!configInitialized.value) {
          debugPrint('🔧 Inicializando configuración desde backend...');
          
          final fileConfig = FileUploadConfig(
            maxFileSizeMB: configModel.config?.limits?.maxFileSizeMb ?? 10,
            maxFilesPerOrder: configModel.config?.limits?.maxFilesPerOrder ?? 5,
            allowedTypes: configModel.config?.allowedFileTypes ?? [],
          );

          // ✅ CAMBIO: Actualizar config en el nuevo provider
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(createOrderProvider.notifier).updateConfig(fileConfig);
            configInitialized.value = true;
            debugPrint('✅ Configuración inicializada');
          });
        }
      });
      return null;
    }, [configAsync]);

    return configAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: MBESpacing.lg),
            Text(
              AppLocalizations.of(context)!.printOrderLoadingConfig,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              size: 48,
              color: MBETheme.brandRed,
            ),
            const SizedBox(height: MBESpacing.lg),
            Text(
              AppLocalizations.of(context)!.printOrderErrorLoadingConfig,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: MBESpacing.sm),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MBESpacing.lg),
            FilledButton.icon(
              onPressed: () {
                debugPrint('🔄 Recargando configuración...');
                ref.read(printConfigProvider.notifier).refresh();
              },
              icon: const Icon(Iconsax.refresh),
              label: Text(AppLocalizations.of(context)!.preAlertRetry),
              style: FilledButton.styleFrom(
                backgroundColor: MBETheme.brandBlack,
              ),
            ),
          ],
        ),
      ),
      data: (config) {
        // ✅ CAMBIO: Lee desde el nuevo estado
        final files = orderState.uploadedFiles;
        final totalSize = orderState.totalSize;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del paso
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(MBESpacing.lg),
                decoration: MBECardDecoration.card(),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(MBESpacing.md),
                      decoration: BoxDecoration(
                        color: MBETheme.brandBlack,
                        borderRadius: BorderRadius.circular(MBERadius.medium),
                        boxShadow: MBETheme.shadowSm,
                      ),
                      child: const Icon(
                        Iconsax.document_upload,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: MBESpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.printOrderUploadFiles,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: MBESpacing.xs),
                          Text(
                            AppLocalizations.of(context)!.printOrderUploadFilesDesc,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: MBESpacing.lg),

            // Drag & Drop Zone
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: DragDropZone(
                config: orderState.config,
                onFilesAdded: (newFiles) {
                  debugPrint('📁 Agregando ${newFiles.length} archivos...');
                  // ✅ CAMBIO: Usa el nuevo provider
                  ref.read(createOrderProvider.notifier).addFiles(newFiles);
                },
              ),
            ),

            // Mensaje de error
            if (orderState.error != null) ...[
              const SizedBox(height: MBESpacing.lg),
              FadeIn(
                child: Container(
                  padding: const EdgeInsets.all(MBESpacing.lg),
                  decoration: BoxDecoration(
                    color: MBETheme.brandRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(MBERadius.large),
                    border: Border.all(
                      color: MBETheme.brandRed.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.warning_2,
                        color: MBETheme.brandRed,
                        size: 24,
                      ),
                      const SizedBox(width: MBESpacing.md),
                      Expanded(
                        child: Text(
                          orderState.error!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: MBETheme.brandRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Lista de archivos
            if (files.isNotEmpty) ...[
              const SizedBox(height: MBESpacing.lg),
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(MBESpacing.lg),
                      decoration: MBECardDecoration.card(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(MBESpacing.sm),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius:
                                      BorderRadius.circular(MBERadius.small),
                                ),
                                child: const Icon(
                                  Iconsax.tick_circle5,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: MBESpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Archivos seleccionados',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppLocalizations.of(context)!.printOrderFilesCount(files.length, orderState.config.maxFilesPerOrder),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.printOrderTotalSize,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                FileHelpers.formatFileSize(totalSize),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: MBESpacing.md),

                    ...files.asMap().entries.map(
                          (entry) => FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            delay: Duration(milliseconds: 100 * entry.key),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: MBESpacing.md),
                              child: FileListItem(
                                file: entry.value,
                                index: entry.key,
                                onRemove: () {
                                  debugPrint(
                                      '🗑️ Eliminando archivo: ${entry.value.name}');
                                  // ✅ CAMBIO: Usa el nuevo provider
                                  ref
                                      .read(createOrderProvider.notifier)
                                      .removeFile(entry.value.id);
                                },
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],

            // Info y tips cuando no hay archivos
            if (files.isEmpty) ...[
              const SizedBox(height: MBESpacing.lg),
              _buildEmptyState(context, theme, colorScheme, orderState),
            ],

            const SizedBox(height: MBESpacing.xxxl),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    CreateOrderState orderState, // ✅ CAMBIO: Tipo actualizado
  ) {
    return Column(
      children: [
        // Info de formatos aceptados
        FadeIn(
          delay: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              borderRadius: BorderRadius.circular(MBERadius.large),
              border: Border.all(
                color: MBETheme.neutralGray.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formatos aceptados',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        orderState.config.allowedExtensions.join(', ').toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        AppLocalizations.of(context)!.printOrderFilesLimit(orderState.config.maxFilesPerOrder, orderState.config.maxFileSizeMB),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tips
        const SizedBox(height: MBESpacing.lg),
        FadeIn(
          delay: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Iconsax.lamp_on5,
                      size: 20,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: MBESpacing.sm),
                    Text(
                      'Tips para mejores resultados',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MBESpacing.md),
                _buildTip(context, AppLocalizations.of(context)!.printOrderTipPdf),
                const SizedBox(height: MBESpacing.xs),
                _buildTip(context, AppLocalizations.of(context)!.printOrderTipReadable),
                const SizedBox(height: MBESpacing.xs),
                _buildTip(context, AppLocalizations.of(context)!.printOrderTipResolution),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}