import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';

import '../../../providers/print_order_provider.dart';
import '../../../data/helpers/file_helpers.dart';
import '../files/drag_drop_zone.dart';
import '../files/file_list_item.dart';

class Step1UploadFiles extends HookConsumerWidget {
  const Step1UploadFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orderState = ref.watch(printOrderProvider);
    final files = orderState.files;
    final config = orderState.config;
    final hasErrors = orderState.hasErrors;
    final totalSize = orderState.totalSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del paso - Estilo Grab
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.lg),
            decoration: MBECardDecoration.card(),
            child: Row(
              children: [
                // Icono con fondo negro
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
                        'Subir archivos',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        'Arrastra o selecciona tus documentos',
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
            config: config,
            onFilesAdded: (newFiles) {
              ref.read(printOrderProvider.notifier).addFiles(newFiles);
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
                  Icon(
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
                // Header de lista - Estilo Grab
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
                              borderRadius: BorderRadius.circular(MBERadius.small),
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
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${files.length} de ${config.maxFilesPerOrder} archivos',
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
                            'Tamaño total',
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

                // Lista de archivos con animación
                ...files.asMap().entries.map(
                      (entry) => FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 100 * entry.key),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: MBESpacing.md),
                          child: FileListItem(
                            file: entry.value,
                            index: entry.key,
                            onRemove: () {
                              ref
                                  .read(printOrderProvider.notifier)
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

        // Info adicional si no hay archivos - Estilo Grab
        if (files.isEmpty) ...[
          const SizedBox(height: MBESpacing.lg),
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
                          'PDF, Word, Excel, PowerPoint, imágenes\nHasta ${config.maxFilesPerOrder} archivos',
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

          // Tips adicionales
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
                  _buildTip(
                    context,
                    '• Usa archivos PDF para mejor calidad',
                  ),
                  const SizedBox(height: MBESpacing.xs),
                  _buildTip(
                    context,
                    '• Verifica que el texto sea legible',
                  ),
                  const SizedBox(height: MBESpacing.xs),
                  _buildTip(
                    context,
                    '• Las imágenes deben tener buena resolución',
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: MBESpacing.xxxl),
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