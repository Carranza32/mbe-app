// lib/features/pre_alert/presentation/screens/create_pre_alert_screen.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../../../core/design_system/ds_dropdown_search.dart';
import '../../../auth/presentation/widgets/verification_pending_modal.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/create_pre_alert_provider.dart';
import '../../providers/stores_provider.dart';
import '../../data/models/create_pre_alert_request.dart';
import '../../providers/pre_alerts_provider.dart';
import '../widgets/product_form_item.dart';
import '../widgets/autocomplete_ai_section.dart';

/// Permite adjuntar la factura manualmente (sin usar IA). Mismo archivo se envía con la pre-alerta.
Future<void> _pickInvoiceFileManually(
  BuildContext context,
  WidgetRef ref,
  CreatePreAlert notifier,
) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.single.path == null) return;
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
    notifier.setInvoiceFile(file);
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

class CreatePreAlertScreen extends HookConsumerWidget {
  const CreatePreAlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(createPreAlertProvider);
    final notifier = ref.read(createPreAlertProvider.notifier);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final hasShownModal = useState(false);

    // Verificar si el customer está verificado después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Evitar mostrar el modal múltiples veces
      if (hasShownModal.value) return;

      if (user != null &&
          !user.isAdmin &&
          user.customer != null &&
          user.customer!.verifiedAt == null) {
        hasShownModal.value = true;
        // Mostrar modal de verificación pendiente y volver atrás
        Future.microtask(() {
          if (context.mounted) {
            context.pop();
            showDialog(
              context: context,
              builder: (context) => const VerificationPendingModal(),
            );
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.preAlertNewTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(MBESpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MBERadius.large),
                    boxShadow: MBETheme.shadowSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(MBESpacing.md),
                        decoration: BoxDecoration(
                          color: MBETheme.brandRed,
                          borderRadius: BorderRadius.circular(MBERadius.medium),
                        ),
                        child: const Icon(
                          Iconsax.box,
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
                              l10n.preAlertNewTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: MBESpacing.xs),
                            Text(
                              l10n.preAlertNewSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: MBESpacing.xl),

              // Autocompletar con IA (mismo archivo se usa al enviar)
              AutocompleteAiSection(
                selectedFile: state.invoiceFile,
                isAnalyzing: state.isAnalyzingInvoice,
                error: state.invoiceAnalysisError,
                onFilePicked: (file) => notifier.analyzeInvoiceAndApply(file),
                onDismissError: notifier.clearInvoiceAnalysisError,
              ),

              const SizedBox(height: MBESpacing.xl),

              // Formulario Principal (con animación fade al rellenar por IA)
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: Container(
                  padding: const EdgeInsets.all(MBESpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(MBERadius.large),
                    boxShadow: MBETheme.shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Número de Factura (manual o rellenado por IA; key estable para no cerrar teclado al escribir)
                      FadeIn(
                        key: const ValueKey('invoice_field'),
                        duration: const Duration(milliseconds: 500),
                        child: DSInput.text(
                          label: l10n.preAlertInvoiceNumber,
                          hint: l10n.preAlertInvoiceHint,
                          value: state.request?.invoiceNumber ?? '',
                          onChanged: notifier.setInvoiceNumber,
                          required: true,
                          prefixIcon: Iconsax.document_text,
                        ),
                      ),

                      const SizedBox(height: MBESpacing.lg),

                      // Tienda (manual o rellenado por IA; key estable)
                      FadeIn(
                        key: const ValueKey('store_field'),
                        duration: const Duration(milliseconds: 500),
                        child: _StoreDropdown(
                          selectedStoreId: state.request?.storeId,
                          onChanged: notifier.setStore,
                        ),
                      ),

                      const SizedBox(height: MBESpacing.lg),

                      // Factura: desde "Autocompletar con IA" o adjuntar manualmente aquí
                      _InvoiceSummary(
                        file: state.invoiceFile,
                        onPickFile: () => _pickInvoiceFileManually(context, ref, notifier),
                      ),

                      const SizedBox(height: MBESpacing.lg),

                      // Productos (fade cuando la IA rellena la lista)
                      FadeIn(
                        key: ValueKey(
                          'products_${state.request?.products.length ?? 0}_'
                          '${state.request?.products.map((p) => p.productId).join(",") ?? ""}',
                        ),
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.box,
                                  size: 20,
                                  color: MBETheme.brandBlack,
                                ),
                                const SizedBox(width: MBESpacing.sm),
                                Text(
                                  l10n.preAlertProductsInPackage,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(width: MBESpacing.sm),
                              // Text(
                              //   '${state.request?.products.length ?? 0} productos',
                              //   style: theme.textTheme.bodySmall?.copyWith(
                              //     color: MBETheme.neutralGray,
                              //   ),
                              // ),
                              Text(
                                '*',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: MBETheme.brandRed,
                                ),
                              ),
                            ],
                          ),

                          // Lista de productos
                          ...List.generate(
                            state.request?.products.length ?? 0,
                            (index) {
                              final product = state.request!.products[index];
                              return ProductFormItem(
                                key: ValueKey('product_$index'),
                                index: index,
                                product: product,
                                onRemove: () => notifier.removeProduct(index),
                                onProductChanged: (productId, productName) =>
                                    notifier.setProductName(
                                      index,
                                      productId,
                                      productName,
                                    ),
                                onQuantityChanged: (quantity) => notifier
                                    .setProductQuantity(index, quantity),
                                onPriceChanged: (price) =>
                                    notifier.setProductPrice(index, price),
                              );
                            },
                          ),

                          const SizedBox(height: MBESpacing.md),

                            // Botón Agregar Producto
                            OutlinedButton.icon(
                              onPressed: notifier.addProduct,
                              icon: const Icon(Iconsax.add),
                              label: Text(l10n.preAlertAddProduct),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    MBERadius.medium,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: MBESpacing.xl),

              // Sección de Productos
              // FadeInUp(
              //   duration: const Duration(milliseconds: 400),
              //   delay: const Duration(milliseconds: 200),
              //   child: Container(
              //     padding: const EdgeInsets.all(MBESpacing.lg),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(MBERadius.large),
              //       boxShadow: MBETheme.shadowSm,
              //     ),
              //     child:
              //   ),
              // ),
              const SizedBox(height: MBESpacing.xl),

              // Suma de Productos (Warning si no coincide)
              // if (state.hasProducts) ...[
              //   _ProductsSummary(
              //     productsTotal: state.request!.products.fold<double>(
              //       0,
              //       (sum, p) => sum + p.subtotal,
              //     ),
              //     formTotal: state.request!.totalValue,
              //     isValid: state.productsMatchTotal,
              //   ),
              //   const SizedBox(height: MBESpacing.xl),
              // ],

              // Nota
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(MBESpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(MBERadius.medium),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Iconsax.info_circle,
                        size: 20,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: MBESpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.preAlertCategoryNote,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: MBESpacing.xl),

              // Botón Crear Prealerta
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 400),
                child: FilledButton(
                  onPressed: state.isValid && !state.isLoading
                      ? () => _handleSubmit(context, ref)
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: MBETheme.brandRed,
                    disabledBackgroundColor: MBETheme.neutralGray.withOpacity(
                      0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MBERadius.medium),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.document_upload),
                            const SizedBox(width: MBESpacing.sm),
                            Text(
                              l10n.preAlertCreate,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: MBESpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(createPreAlertProvider.notifier).submit();

    if (!context.mounted) return;

    if (success) {
      // Invalidar la lista de pre-alertas para refrescar
      ref.invalidate(preAlertsProvider);

      // Mostrar mensaje de éxito con animación
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (ctx) {
          final l10nDialog = AppLocalizations.of(ctx)!;
          return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MBERadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MBESpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono animado
                FadeIn(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.tick_circle,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: MBESpacing.lg),

                // Título
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    l10nDialog.preAlertCreatedSuccess,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                ),
                const SizedBox(height: MBESpacing.sm),

                // Mensaje
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    l10nDialog.preAlertCreatedMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MBETheme.neutralGray,
                    ),
                  ),
                ),
                const SizedBox(height: MBESpacing.xl),

                // Botón
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 300),
                  child: FilledButton(
                    onPressed: () {
                      ref.read(createPreAlertProvider.notifier).reset();
                      Navigator.pop(context); // Cerrar dialog
                      context.pop(); // Volver a lista usando go_router
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: MBETheme.brandBlack,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MBERadius.medium),
                      ),
                    ),
                    child: Text(l10nDialog.preAlertAccept),
                  ),
                ),
              ],
            ),
          ),
        );
        },
      );
    } else {
      final state = ref.read(createPreAlertProvider);
      final l10nErr = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
        content: Text(state.error ?? l10nErr.preAlertCreateError),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }
}

// ===== WIDGETS AUXILIARES =====

class _StoreDropdown extends ConsumerWidget {
  final String? selectedStoreId;
  final Function(String) onChanged;

  const _StoreDropdown({
    required this.selectedStoreId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, child) {
        final storesAsync = ref.watch(allStoresProvider);
        return storesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text(l10n.preAlertErrorGeneric(error.toString())),
          data: (stores) {
            return DSDropdownSearch<Store>(
              label: l10n.preAlertStoreWhereBought,
              selectedItem: _getSelectedStore(stores),
              provider: allStoresProvider,
              itemAsString: (store) => store.name,
              onChanged: (store) {
                if (store != null) {
                  onChanged(store.id);
                }
              },
              required: true,
              hint: l10n.preAlertSelectStore,
              searchHint: l10n.preAlertSearchStore,
              prefixIcon: Iconsax.shop,
              enableSearch: true,
            );
          },
        );
      },
    );
  }

  Store? _getSelectedStore(List<Store> stores) {
    if (selectedStoreId != null && stores.isNotEmpty) {
      try {
        return stores.firstWhere((store) => store.id == selectedStoreId);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

/// Muestra la factura seleccionada. Se puede subir desde "Autocompletar con IA" o adjuntar aquí manualmente.
class _InvoiceSummary extends StatelessWidget {
  final File? file;
  final VoidCallback? onPickFile;

  const _InvoiceSummary({required this.file, this.onPickFile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.preAlertInvoiceForPurchase,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MBESpacing.sm),
        Container(
          padding: const EdgeInsets.all(MBESpacing.md),
          decoration: BoxDecoration(
            color: MBETheme.lightGray,
            borderRadius: BorderRadius.circular(MBERadius.medium),
            border: Border.all(
              color: MBETheme.neutralGray.withOpacity(0.3),
            ),
          ),
          child: file != null
              ? Row(
                  children: [
                    const Icon(
                      Iconsax.document_text,
                      size: 24,
                      color: MBETheme.brandBlack,
                    ),
                    const SizedBox(width: MBESpacing.sm),
                    Expanded(
                      child: Text(
                        file!.path.split(RegExp(r'[/\\]')).last,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onPickFile != null)
                      TextButton(
                        onPressed: onPickFile,
                        child: Text(
                          l10n.preAlertChange,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      size: 20,
                      color: MBETheme.neutralGray,
                    ),
                    const SizedBox(width: MBESpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.preAlertInvoiceUploadHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (onPickFile != null)
                      TextButton.icon(
                        onPressed: onPickFile,
                        icon: const Icon(Iconsax.document_upload, size: 18),
                        label: Text(
                          l10n.preAlertSelectImageOrPdf,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ProductsSummary extends StatelessWidget {
  final double productsTotal;
  final double formTotal;
  final bool isValid;

  const _ProductsSummary({
    required this.productsTotal,
    required this.formTotal,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: BoxDecoration(
        color: isValid ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(MBERadius.medium),
        border: Border.all(
          color: isValid
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFF59E0B).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isValid ? Iconsax.tick_circle : Iconsax.warning_2,
                size: 20,
                color: isValid
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: MBESpacing.sm),
              Text(
                'Suma de Productos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isValid
                      ? const Color(0xFF15803D)
                      : const Color(0xFF92400E),
                ),
              ),
              const Spacer(),
              Text(
                '\$${productsTotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isValid
                      ? const Color(0xFF15803D)
                      : const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          if (!isValid) ...[
            const SizedBox(height: MBESpacing.sm),
            Row(
              children: [
                const Icon(
                  Iconsax.info_circle,
                  size: 16,
                  color: Color(0xFFF59E0B),
                ),
                const SizedBox(width: MBESpacing.xs),
                Expanded(
                  child: Text(
                    'El total ingresado (\$${formTotal.toStringAsFixed(2)}) no coincide con la suma de productos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
