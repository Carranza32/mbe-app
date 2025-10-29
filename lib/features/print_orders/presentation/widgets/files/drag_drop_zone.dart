import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';
import '../../../data/models/file_upload_config.dart';
import '../../../data/models/uploaded_file_model.dart';
import '../../../data/helpers/file_helpers.dart';

class DragDropZone extends HookWidget {
  final FileUploadConfig config;
  final Function(List<UploadedFile>) onFilesAdded;

  const DragDropZone({
    Key? key,
    required this.config,
    required this.onFilesAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDragging = useState(false);

    Future<void> handleFiles(List<File> files) async {
      final uploadedFiles = <UploadedFile>[];

      for (final file in files) {
        final fileName = file.path.split('/').last;
        final fileSize = await file.length();
        
        String mimeType = 'application/octet-stream';
        final extension = FileHelpers.getFileExtension(fileName).toLowerCase();
        
        if (extension == '.pdf') {
          mimeType = 'application/pdf';
        } else if (extension == '.doc') {
          mimeType = 'application/msword';
        } else if (extension == '.docx') {
          mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        } else if (['.jpg', '.jpeg'].contains(extension)) {
          mimeType = 'image/jpeg';
        } else if (extension == '.png') {
          mimeType = 'image/png';
        }

        final errors = FileHelpers.validateFile(
          fileSize: fileSize,
          fileType: mimeType,
          fileName: fileName,
          maxFileSizeBytes: config.maxFileSizeBytes,
          allowedTypes: config.allowedTypes,
        );

        String? preview;
        if (mimeType.startsWith('image/')) {
          preview = file.path;
        }

        uploadedFiles.add(
          UploadedFile(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                uploadedFiles.length.toString(),
            file: file,
            name: fileName,
            size: fileSize,
            type: mimeType,
            errors: errors,
            preview: preview,
          ),
        );
      }

      if (uploadedFiles.isNotEmpty) {
        onFilesAdded(uploadedFiles);
      }
    }

    Future<void> pickFiles() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: config.allowedExtensions
              .map((e) => e.replaceAll('.', ''))
              .toList(),
          allowMultiple: true,
        );

        if (result != null) {
          final files = result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();

          await handleFiles(files);
        }
      } catch (e) {
        debugPrint('Error picking files: $e');
      }
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..scale(isDragging.value ? 1.02 : 1.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          dashPattern: const [8, 4],
          strokeWidth: 2,
          color: isDragging.value
              ? colorScheme.primary
              : colorScheme.outline,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: isDragging.value
                  ? colorScheme.primaryContainer.withOpacity(0.3)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Ícono animado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDragging.value
                        ? colorScheme.primary
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Iconsax.document_upload,
                    size: 32,
                    color: isDragging.value
                        ? colorScheme.onPrimary
                        : colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(height: 16),

                // Título
                Text(
                  isDragging.value
                      ? '¡Suelta tus archivos aquí!'
                      : 'Arrastra tus archivos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isDragging.value
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'o haz clic para seleccionar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                // Botón de seleccionar
                FilledButton.icon(
                  onPressed: pickFiles,
                  icon: const Icon(Iconsax.document_text),
                  label: const Text('Seleccionar archivos'),
                ),

                const SizedBox(height: 24),

                // Badges informativos
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoBadge(
                      icon: Iconsax.document_text,
                      label: 'PDF, Word',
                      colorScheme: colorScheme,
                    ),
                    _InfoBadge(
                      icon: Iconsax.gallery,
                      label: 'Imágenes',
                      colorScheme: colorScheme,
                    ),
                    _InfoBadge(
                      icon: Iconsax.star,
                      label: 'Hasta ${config.maxFileSizeMB}MB',
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}