import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../config/theme/mbe_theme.dart';

/// Widget genérico de dropdown con búsqueda para el design system
///
/// Soporta dos modos:
/// - Normal: Dropdown simple sin búsqueda
/// - Con búsqueda: Dropdown con campo de búsqueda que filtra localmente
///
/// El tipo T debe implementar un método toString() o usar itemAsString
///
/// Ejemplo de uso:
/// ```dart
/// DSDropdownSearch<ProductCategory>(
///   label: 'Categoría',
///   selectedItem: selectedCategory,
///   provider: allProductCategoriesProvider,
///   itemAsString: (item) => item.name,
///   onChanged: (item) => setState(() => selectedCategory = item),
///   required: true,
///   hint: 'Selecciona una categoría',
///   searchHint: 'Buscar categoría...',
///   prefixIcon: Iconsax.box,
/// )
/// ```
class DSDropdownSearch<T> extends HookConsumerWidget {
  /// Label del campo
  final String label;

  /// Item seleccionado actualmente
  final T? selectedItem;

  /// Provider que contiene la lista de items (debe retornar AsyncValue<List<T>>)
  /// Puede ser cualquier provider de Riverpod que retorne AsyncValue<List<T>>
  final dynamic provider;

  /// Función para convertir el item a string para mostrar
  final String Function(T) itemAsString;

  /// Callback cuando se selecciona un item
  final Function(T?) onChanged;

  /// Si el campo es requerido
  final bool required;

  /// Si el campo está habilitado
  final bool enabled;

  /// Hint text para el dropdown
  final String? hint;

  /// Hint text para el campo de búsqueda (solo si enableSearch = true)
  final String? searchHint;

  /// Icono prefix
  final IconData? prefixIcon;

  /// Si se habilita la búsqueda
  final bool enableSearch;

  /// Función opcional para comparar items (útil para encontrar el item seleccionado)
  final bool Function(T, T)? compareFn;

  /// Función opcional para filtrar items localmente (por defecto busca en itemAsString)
  final bool Function(T, String)? filterFn;

  const DSDropdownSearch({
    Key? key,
    required this.label,
    this.selectedItem,
    required this.provider,
    required this.itemAsString,
    required this.onChanged,
    this.required = false,
    this.enabled = true,
    this.hint,
    this.searchHint,
    this.prefixIcon,
    this.enableSearch = true,
    this.compareFn,
    this.filterFn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final itemsAsyncValue = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: MBETheme.brandRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: MBESpacing.sm),

        // Dropdown Container - Usar maybeWhen para manejar AsyncData correctamente
        _buildAsyncWidget(itemsAsyncValue, context, theme, colorScheme),
      ],
    );
  }

  Widget _buildAsyncWidget(
    dynamic itemsAsyncValue,
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // Usar los métodos de instancia de AsyncValue que están disponibles
    final asyncValue = itemsAsyncValue as AsyncValue<List<T>>;

    if (asyncValue.hasValue) {
      // Tiene datos
      return _buildDropdown(
        context,
        theme,
        colorScheme,
        asyncValue.value!,
        isEnabled: enabled,
      );
    } else if (asyncValue.hasError) {
      // Tiene error
      return Container(
        padding: const EdgeInsets.all(MBESpacing.md),
        decoration: BoxDecoration(
          color: MBETheme.brandRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MBERadius.medium),
          border: Border.all(color: MBETheme.brandRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.danger, color: MBETheme.brandRed, size: 16),
            const SizedBox(width: MBESpacing.sm),
            Expanded(
              child: Text(
                'Error al cargar datos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: MBETheme.brandRed,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Está cargando
      return _buildDropdown(
        context,
        theme,
        colorScheme,
        <T>[], // Lista vacía mientras carga
        isEnabled: false, // Deshabilitado mientras carga
      );
    }
  }

  Widget _buildDropdown(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<T> items, {
    required bool isEnabled,
  }) {
    if (enableSearch) {
      // Dropdown con búsqueda
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MBERadius.medium),
          border: Border.all(color: MBETheme.neutralGray.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: MBESpacing.sm,
          vertical: MBESpacing.xs,
        ),
        child: DropdownSearch<T>(
          selectedItem: selectedItem,
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: searchHint ?? 'Buscar...',
                prefixIcon: const Icon(Iconsax.search_normal),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(MBERadius.medium),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: MBESpacing.md,
                  vertical: MBESpacing.md,
                ),
              ),
            ),
            menuProps: MenuProps(
              backgroundColor: Colors.white,
              elevation: 8,
              borderRadius: BorderRadius.circular(MBERadius.medium),
            ),
          ),
          items: items,
          itemAsString: itemAsString,
          compareFn: compareFn ?? (T item1, T item2) => item1 == item2,
          filterFn:
              filterFn ??
              (T item, String search) {
                final searchLower = search.toLowerCase();
                final itemString = itemAsString(item).toLowerCase();
                return itemString.contains(searchLower);
              },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: hint ?? 'Selecciona...',
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MBESpacing.md,
                vertical: MBESpacing.sm,
              ),
            ),
          ),
          onChanged: isEnabled ? (T? value) => onChanged(value) : null,
          enabled: isEnabled,
        ),
      );
    } else {
      // Dropdown normal sin búsqueda
      return Container(
        decoration: BoxDecoration(
          color: isEnabled
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: MBETheme.neutralGray.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: MBETheme.shadowSm,
        ),
        child: DropdownButtonFormField<T>(
          value: selectedItem,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemAsString(item),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              )
              .toList(),
          onChanged: isEnabled ? (T? value) => onChanged(value) : null,
          hint: hint != null
              ? Text(
                  hint!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MBESpacing.lg,
              vertical: MBESpacing.lg,
            ),
          ),
          dropdownColor: colorScheme.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
  }
}
