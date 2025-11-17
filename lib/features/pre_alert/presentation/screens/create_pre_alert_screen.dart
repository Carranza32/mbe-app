// lib/features/pre_alert/presentation/screens/create_pre_alert_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_inputs.dart';
import '../../providers/create_pre_alert_provider.dart';
import '../../providers/stores_provider.dart';
import '../../providers/products_provider.dart';
import '../widgets/product_form_item.dart';

class CreatePreAlertScreen extends HookConsumerWidget {
  const CreatePreAlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(createPreAlertProvider);
    final notifier = ref.read(createPreAlertProvider.notifier);
    final storesAsync = ref.watch(storesProvider);

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva Prealerta',
          style: TextStyle(fontWeight: FontWeight.w600),
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
                              'Nueva Prealerta',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: MBESpacing.xs),
                            Text(
                              'Completa la información para registrar tu paquete',
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
        
              // Formulario Principal
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
                      // Número de Rastreo
                      DSInput.text(
                        label: 'Número de Rastreo',
                        hint: 'Ej: 1Z999AA10123456784',
                        value: state.request?.trackingNumber ?? '',
                        onChanged: notifier.setTrackingNumber,
                        required: true,
                        prefixIcon: Iconsax.truck_fast,
                      ),
        
                      const SizedBox(height: MBESpacing.lg),
        
                      // Número de Casillero
                      DSInput.text(
                        label: 'Número de casillero',
                        hint: 'SAL1400',
                        value: state.request?.mailboxNumber ?? '',
                        onChanged: notifier.setMailboxNumber,
                        required: true,
                        prefixIcon: Iconsax.box_1,
                      ),
        
                      const SizedBox(height: MBESpacing.lg),
        
                      // Tienda (Dropdown)
                      storesAsync.when(
                        data: (stores) => _StoreDropdown(
                          stores: stores,
                          selectedStoreId: state.request?.storeId,
                          onChanged: notifier.setStore,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error al cargar tiendas'),
                      ),
        
                      const SizedBox(height: MBESpacing.lg),
        
                      // Valor Total
                      DSInput.text(
                        label: 'Valor total de su compra en US\$',
                        hint: '\$ 49.98',
                        value: state.request?.totalValue.toString() ?? '',
                        onChanged: (value) {
                          final parsed = double.tryParse(value) ?? 0;
                          notifier.setTotalValue(parsed);
                        },
                        required: true,
                        prefixIcon: Iconsax.dollar_circle,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
        
                      const SizedBox(height: MBESpacing.lg),
        
                      // Subir Factura
                      _FileUploadSection(
                        file: state.invoiceFile,
                        onFilePicked: notifier.setInvoiceFile,
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: MBESpacing.xl),
        
              // Sección de Productos
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
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
                      Row(
                        children: [
                          const Icon(
                            Iconsax.box,
                            size: 20,
                            color: MBETheme.brandBlack,
                          ),
                          const SizedBox(width: MBESpacing.sm),
                          Text(
                            'Cantidad de productos dentro del paquete',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Text(
                        '*',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: MBETheme.brandRed,
                        ),
                      ),
                      const SizedBox(height: MBESpacing.lg),
        
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
                                notifier.setProductName(index, productId, productName),
                            onQuantityChanged: (quantity) =>
                                notifier.setProductQuantity(index, quantity),
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
                        label: const Text('Agregar Producto'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MBERadius.medium),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: MBESpacing.xl),
        
              // Suma de Productos (Warning si no coincide)
              if (state.hasProducts) ...[
                _ProductsSummary(
                  productsTotal: state.request!.products.fold<double>(
                    0,
                    (sum, p) => sum + p.subtotal,
                  ),
                  formTotal: state.request!.totalValue,
                  isValid: state.productsMatchTotal,
                ),
                const SizedBox(height: MBESpacing.xl),
              ],
        
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
                          '* Asegúrate de ingresar la descripción correcta de tu paquete, ya que pueden causar retrasos al procesarlo.',
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
                    disabledBackgroundColor: MBETheme.neutralGray.withOpacity(0.3),
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
                              'Crear Prealerta',
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          icon: const Icon(
            Iconsax.tick_circle,
            size: 64,
            color: Color(0xFF10B981),
          ),
          title: const Text('¡Prealerta creada!'),
          content: const Text(
            'Tu prealerta ha sido registrada exitosamente',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                ref.read(createPreAlertProvider.notifier).reset();
                Navigator.pop(context); // Cerrar dialog
                Navigator.pop(context); // Volver a lista
              },
              style: FilledButton.styleFrom(
                backgroundColor: MBETheme.brandBlack,
              ),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      final state = ref.read(createPreAlertProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Error al crear la prealerta'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }
}

// ===== WIDGETS AUXILIARES =====

class _StoreDropdown extends ConsumerWidget {
  final List stores;
  final String? selectedStoreId;
  final Function(String) onChanged;

  const _StoreDropdown({
    required this.stores,
    required this.selectedStoreId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tienda donde compraste el producto',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: theme.textTheme.titleSmall?.copyWith(
                color: MBETheme.brandRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: MBESpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: MBETheme.lightGray,
            borderRadius: BorderRadius.circular(MBERadius.medium),
            border: Border.all(
              color: MBETheme.neutralGray.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedStoreId?.isEmpty == true ? null : selectedStoreId,
            decoration: InputDecoration(
              hintText: 'ADORAMA',
              prefixIcon: const Icon(Iconsax.shop),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MBESpacing.md,
                vertical: MBESpacing.md,
              ),
            ),
            items: stores.map((store) {
              return DropdownMenuItem<String>(
                value: store.id,
                child: Text(store.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}

class _FileUploadSection extends StatelessWidget {
  final File? file;
  final Function(File) onFilePicked;

  const _FileUploadSection({
    required this.file,
    required this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subir factura relacionada a esta compra',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: MBESpacing.sm),
        GestureDetector(
          onTap: () => _pickFile(context),
          child: Container(
            padding: const EdgeInsets.all(MBESpacing.xl),
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              borderRadius: BorderRadius.circular(MBERadius.medium),
              border: Border.all(
                color: MBETheme.neutralGray.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  file != null ? Iconsax.document_upload : Iconsax.document_upload,
                  size: 48,
                  color: file != null ? MBETheme.brandBlack : MBETheme.neutralGray,
                ),
                const SizedBox(height: MBESpacing.md),
                Text(
                  file != null ? 'Archivo seleccionado' : 'Seleccionar archivo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: file != null ? MBETheme.brandBlack : MBETheme.neutralGray,
                  ),
                ),
                const SizedBox(height: MBESpacing.xs),
                if (file != null)
                  Text(
                    file!.path.split('/').last,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    'PDF, JPG, PNG o GIF. Máx. 4MB',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final sizeInMB = file.lengthSync() / (1024 * 1024);

        if (sizeInMB > 4) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El archivo no puede superar los 4MB'),
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
            content: Text('Error al seleccionar archivo: $e'),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    }
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
                color: isValid ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: MBESpacing.sm),
              Text(
                'Suma de Productos',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isValid ? const Color(0xFF15803D) : const Color(0xFF92400E),
                ),
              ),
              const Spacer(),
              Text(
                '\$${productsTotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isValid ? const Color(0xFF15803D) : const Color(0xFF92400E),
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
