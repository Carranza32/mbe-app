import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';

/// Sección "Autocompletar con IA": subir factura (PDF/imagen) para que la IA
/// rellene el formulario. El mismo archivo se usa al enviar la pre-alerta.
class AutocompleteAiSection extends StatelessWidget {
  final File? selectedFile;
  final bool isAnalyzing;
  final String? error;
  final Function(File) onFilePicked;
  final VoidCallback? onDismissError;

  const AutocompleteAiSection({
    Key? key,
    required this.selectedFile,
    required this.isAnalyzing,
    required this.error,
    required this.onFilePicked,
    this.onDismissError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(MBESpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF1a1a2e), const Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(MBERadius.large),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe94560).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.magic_star5,
                    size: 28,
                    color: Color(0xFFe94560),
                  ),
                ),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Autocompletar con IA',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.preAlertAutocompleteAIDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: MBESpacing.lg),
            if (isAnalyzing) ...[
              _AnalyzingOverlay(),
            ] else if (error != null && error!.isNotEmpty) ...[
              _ErrorBanner(message: error!, onDismiss: onDismissError),
              const SizedBox(height: MBESpacing.md),
              _UploadButton(onTap: () => _pickFile(context, onFilePicked)),
            ] else if (selectedFile != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: MBESpacing.sm,
                  horizontal: MBESpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MBERadius.medium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.document_text,
                      color: Colors.white70,
                      size: 20,
                    ),
                    const SizedBox(width: MBESpacing.sm),
                    Expanded(
                      child: Text(
                        selectedFile!.path.split(RegExp(r'[/\\]')).last,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _pickFile(context, onFilePicked),
                      child: const Text(
                        'Cambiar',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              _UploadButton(onTap: () => _pickFile(context, onFilePicked)),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickFile(
    BuildContext context,
    Function(File) onFilePicked,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final sizeInMB = file.lengthSync() / (1024 * 1024);
        if (sizeInMB > 10) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.preAlertFileTooLarge),
                backgroundColor: MBETheme.brandRed,
              ),
            );
          }
          return;
        }
        onFilePicked(file);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.preAlertErrorSelecting(e.toString())),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    }
  }
}

class _UploadButton extends StatelessWidget {
  final VoidCallback onTap;

  const _UploadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MBERadius.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white30, width: 2),
            borderRadius: BorderRadius.circular(MBERadius.medium),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_upload, color: Colors.white70, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.preAlertUploadFile,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyzingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFe94560)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analizando con IA...',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.preAlertReadingInvoice,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const _ErrorBanner({required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(MBERadius.medium),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.red, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _shortMessage(message),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 20),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }

  static String _shortMessage(String m) {
    if (m.length <= 80) return m;
    return '${m.substring(0, 77)}...';
  }
}
