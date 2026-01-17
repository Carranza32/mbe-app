// lib/features/pre_alert/presentation/widgets/product_form_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../data/models/create_pre_alert_request.dart';
import '../../../../features/admin/pre_alert/data/models/product_category_model.dart';
import '../../../../features/admin/pre_alert/providers/product_categories_provider.dart';
import '../../../../core/design_system/ds_dropdown_search.dart';

class ProductFormItem extends HookConsumerWidget {
  final int index;
  final PreAlertProduct product;
  final VoidCallback onRemove;
  final Function(String productId, String productName) onProductChanged;
  final Function(int) onQuantityChanged;
  final Function(double) onPriceChanged;

  const ProductFormItem({
    Key? key,
    required this.index,
    required this.product,
    required this.onRemove,
    required this.onProductChanged,
    required this.onQuantityChanged,
    required this.onPriceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: MBESpacing.md),
        padding: const EdgeInsets.all(MBESpacing.md),
        decoration: BoxDecoration(
          color: MBETheme.lightGray.withOpacity(0.5),
          borderRadius: BorderRadius.circular(MBERadius.medium),
          border: Border.all(color: MBETheme.neutralGray.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con número y botón eliminar
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: MBETheme.brandRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: MBESpacing.sm),
                Text(
                  'Producto ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (index > 0)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Iconsax.trash),
                    iconSize: 20,
                    color: MBETheme.brandRed,
                    style: IconButton.styleFrom(
                      backgroundColor: MBETheme.brandRed.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MBERadius.small),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: MBESpacing.md),

            // Dropdown Producto con búsqueda
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Categoría del Producto',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '*',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: MBETheme.brandRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MBESpacing.xs),
                DSDropdownSearch<ProductCategory>(
                  label: '',
                  selectedItem: product.productId.isNotEmpty
                      ? ProductCategory(
                          id: int.tryParse(product.productId) ?? 0,
                          name: product.productName,
                        )
                      : null,
                  provider: allProductCategoriesProvider,
                  itemAsString: (item) => item.name,
                  onChanged: (ProductCategory? selectedCategory) {
                    if (selectedCategory != null) {
                      onProductChanged(
                        selectedCategory.id.toString(),
                        selectedCategory.name,
                      );
                    }
                  },
                  required: true,
                  hint: 'Selecciona o busca una categoría...',
                  searchHint: 'Buscar categoría...',
                  enableSearch: true,
                ),
              ],
            ),

            const SizedBox(height: MBESpacing.md),

            // Cantidad y Precio
            Row(
              children: [
                // Cantidad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Cantidad',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: MBETheme.brandRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(MBERadius.medium),
                          border: Border.all(
                            color: MBETheme.neutralGray.withOpacity(0.2),
                          ),
                        ),
                        child: TextFormField(
                          initialValue: product.quantity.toString(),
                          decoration: const InputDecoration(
                            hintText: '1',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: MBESpacing.md,
                              vertical: MBESpacing.sm,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            final parsed = int.tryParse(value) ?? 1;
                            onQuantityChanged(parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: MBESpacing.md),

                // Precio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Precio',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '*',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: MBETheme.brandRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MBESpacing.xs),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(MBERadius.medium),
                          border: Border.all(
                            color: MBETheme.neutralGray.withOpacity(0.2),
                          ),
                        ),
                        child: TextFormField(
                          initialValue: product.price > 0
                              ? product.price.toString()
                              : '',
                          decoration: const InputDecoration(
                            hintText: '\$ 0.00',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: MBESpacing.md,
                              vertical: MBESpacing.sm,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          onChanged: (value) {
                            final parsed = double.tryParse(value) ?? 0;
                            onPriceChanged(parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: MBESpacing.md),

            // Subtotal
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MBESpacing.md,
                vertical: MBESpacing.sm,
              ),
              decoration: BoxDecoration(
                color: MBETheme.brandBlack.withOpacity(0.05),
                borderRadius: BorderRadius.circular(MBERadius.small),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${product.subtotal.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
