import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../../config/theme/app_colors.dart';
import '../providers/shipping_calculator_provider.dart';
import '../data/models/shipping_calculation_model.dart';
import '../../admin/pre_alert/data/models/product_category_model.dart';
import '../../admin/pre_alert/providers/product_categories_provider.dart';

class QuoteInputScreen extends HookConsumerWidget {
  const QuoteInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Controladores
    final valueController = useTextEditingController();
    final weightController = useTextEditingController();

    // Estados
    final selectedCategory = useState<ProductCategory?>(null);
    final calculationState = ref.watch(shippingCalculatorProvider);

    // Timer para "Debounce" (esperar a que el usuario termine de escribir)
    final debounceTimer = useRef<Timer?>(null);

    // Lógica de cálculo automático
    void attemptCalculation() {
      // 1. Cancelar timer anterior si sigue escribiendo
      debounceTimer.value?.cancel();

      // 2. Validar campos requeridos
      final weight = double.tryParse(weightController.text);
      final value = double.tryParse(valueController.text);

      if (weight == null || value == null || weight <= 0 || value <= 0) {
        ref.read(shippingCalculatorProvider.notifier).clear();
        return;
      }

      if (selectedCategory.value == null) {
        return;
      }

      // 3. Iniciar nuevo timer (espera 800ms después de que dejan de escribir)
      debounceTimer.value = Timer(const Duration(milliseconds: 800), () {
        // 4. Llamar al backend para calcular
        ref
            .read(shippingCalculatorProvider.notifier)
            .calculate(
              weight: weight,
              value: value,
              productCategoryId: selectedCategory.value!.id,
            );
      });
    }

    // Escuchar cambios en los inputs
    useEffect(() {
      valueController.addListener(attemptCalculation);
      weightController.addListener(attemptCalculation);
      return () {
        // Limpieza
        valueController.removeListener(attemptCalculation);
        weightController.removeListener(attemptCalculation);
        debounceTimer.value?.cancel();
      };
    }, []);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // CORRECCIÓN: Quita el botón de atrás
        title: const Text(
          'Calculadora de Envíos',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN INPUTS ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detalles del Paquete",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactInput(
                          controller: weightController,
                          label: "Peso",
                          suffix: "lb",
                          icon: Iconsax.weight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCompactInput(
                          controller: valueController,
                          label: "Valor",
                          suffix: "\$",
                          icon: Iconsax.dollar_circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Tipo de Producto",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownSearch<ProductCategory>(
                      selectedItem: selectedCategory.value,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Buscar categoría...',
                            prefixIcon: const Icon(Iconsax.search_normal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        menuProps: MenuProps(
                          backgroundColor: Colors.white,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      asyncItems: (String? search) async {
                        final provider = productCategoriesProvider(
                          search: search?.isEmpty == true ? null : search,
                          perPage: 50,
                        );
                        final categoriesAsync = ref.read(provider);
                        return await categoriesAsync.when(
                          data: (categories) => categories,
                          loading: () => <ProductCategory>[],
                          error: (_, __) => <ProductCategory>[],
                        );
                      },
                      itemAsString: (item) => item.name,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Selecciona o busca una categoría...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                      onChanged: (ProductCategory? category) {
                        selectedCategory.value = category;
                        attemptCalculation(); // Recalcular al cambiar categoría
                      },
                    ),
                  ),
                  // Nota: Eliminamos el botón "Calcular"
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECCIÓN RESULTADOS (Condicional) ---
            calculationState.when(
              data: (result) {
                if (result == null) {
                  return const SizedBox.shrink();
                }
                return _buildQuoteReceipt(context, result);
              },
              loading: () => _buildShimmerLoading(),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.danger, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Error al calcular: ${error.toString()}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Espacio extra para scroll
          ],
        ),
      ),
    );
  }

  // --- WIDGET DE SHIMMER (LOADING) ---
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          // Header Shimmer
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
          const SizedBox(height: 2),
          // Body Shimmer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80, height: 40, color: Colors.white),
                    Container(width: 80, height: 40, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES (IGUAL QUE ANTES) ---

  Widget _buildCompactInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              hintText: "0.00",
              prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteReceipt(
    BuildContext context,
    ShippingCalculationResponse calculation,
  ) {
    // Usamos FadeInAnimation simple al aparecer
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // Pequeño slide up
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // Encabezado del Ticket
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.tick_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cotización Generada",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Basado en tarifas actuales",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Separador punteado (simulado con contenedores)
          Container(
            color: Colors.white,
            child: Row(
              children: List.generate(
                30,
                (index) => Expanded(
                  child: Container(
                    color: index % 2 == 0
                        ? Colors.transparent
                        : Colors.grey.shade300,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          // Cuerpo del Ticket
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Resumen rápido
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem(
                      "Peso",
                      "${calculation.weightLbs.toStringAsFixed(1)} lbs",
                      isOrange: true,
                    ),
                    _buildSummaryItem(
                      "Valor",
                      "\$${calculation.valueUsd.toStringAsFixed(2)}",
                      isOrange: false,
                    ),
                  ],
                ),
                if (calculation.pesoFueAproximado) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Peso aproximado (original: ${calculation.originalWeight.toStringAsFixed(1)} lbs)",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 16),

                _buildCostRow(
                  "Costo de Flete",
                  "\$${calculation.flete.toStringAsFixed(2)}",
                ),
                _buildCostRow(
                  "Garantía de Entrega",
                  "\$${calculation.garantiaEntrega.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 16),

                // Impuestos
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Impuestos de Aduana",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB78608),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCostRow(
                        "IVA-CIF",
                        "\$${calculation.ivaTif.toStringAsFixed(2)}",
                        isSmall: true,
                      ),
                      if (calculation.aplicaDai) ...[
                        const SizedBox(height: 4),
                        _buildCostRow(
                          "DAI (${calculation.daiRate.toStringAsFixed(1)}%)",
                          "\$${calculation.dai.toStringAsFixed(2)}",
                          isSmall: true,
                        ),
                      ],
                      const SizedBox(height: 4),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      _buildCostRow(
                        "Total Impuestos",
                        "\$${calculation.totalImpuestos.toStringAsFixed(2)}",
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildCostRow(
                  "Gestión Aduanal",
                  "\$${calculation.gestionAduanal.toStringAsFixed(2)}",
                ),
                _buildCostRow(
                  "Manejo de Terceros",
                  "\$${calculation.manejoTerceros.toStringAsFixed(2)}",
                ),

                if (calculation.descuentoAplicado > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Descuento aplicado",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          "-\$${calculation.descuentoAplicado.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // TOTAL NEGRO
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total a Pagar:",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${calculation.totalConDescuento.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    required bool isOrange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isOrange ? Colors.orange.shade800 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(
    String label,
    String value, {
    bool isSmall = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
              color: isBold ? Colors.black : Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
