import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/print_configuration_model.dart';
import 'print_config_provider.dart';
import 'print_configuration_state_provider.dart';
import 'print_order_provider.dart';

part 'print_pricing_provider.g.dart';

/// Resultado del cálculo de precio
class PriceCalculation {
  final double pricePerPage;
  final double printingCost;
  final double doubleSidedCost;
  final double bindingCost;
  final double subtotal;
  final double tax;
  final double total;
  final int totalPages;
  final int copies;

  PriceCalculation({
    required this.pricePerPage,
    required this.printingCost,
    required this.doubleSidedCost,
    required this.bindingCost,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.totalPages,
    required this.copies,
  });

  PriceCalculation.zero()
      : pricePerPage = 0,
        printingCost = 0,
        doubleSidedCost = 0,
        bindingCost = 0,
        subtotal = 0,
        tax = 0,
        total = 0,
        totalPages = 0,
        copies = 1;
}

@riverpod
class PrintPricing extends _$PrintPricing {
  @override
  PriceCalculation build() {
    final configAsync = ref.watch(printConfigProvider);
    final userConfig = ref.watch(printConfigurationStateProvider);
    final orderState = ref.watch(printOrderProvider);

    return configAsync.when(
      data: (configModel) => _calculatePrice(
        configModel,
        userConfig,
        orderState.totalPages ?? 0,
      ),
      loading: () => PriceCalculation.zero(),
      error: (_, __) => PriceCalculation.zero(),
    );
  }

  PriceCalculation _calculatePrice(
    PrintConfigurationModel configModel,
    UserPrintConfiguration userConfig,
    int totalPages,
  ) {
    if (totalPages == 0) {
      return PriceCalculation.zero();
    }

    final config = configModel.config;
    if (config?.prices == null) {
      return PriceCalculation.zero();
    }

    // 1. Obtener precio por página según configuración
    final pricePerPage = _getPricePerPage(
      config!.prices!,
      userConfig.printType,
      userConfig.paperSize,
      totalPages,
    );

    // 2. Calcular costo de impresión base
    final printingCost = pricePerPage * totalPages * userConfig.copies;

    // 3. Calcular costo de doble cara
    final doubleSidedCost = userConfig.doubleSided
        ? (config.prices!.doubleSided ?? 0) * totalPages * userConfig.copies
        : 0.0;

    // 4. Calcular costo de engargolado
    final bindingCost = userConfig.binding
        ? _getBindingPrice(config.prices!.binding, totalPages)
        : 0.0;

    // 5. Calcular subtotal
    final subtotal = printingCost + doubleSidedCost + bindingCost;

    // 6. Calcular IVA
    final taxRate = config.tax?.iva ?? 0.13;
    final tax = subtotal * taxRate;

    // 7. Total
    final total = subtotal + tax;

    return PriceCalculation(
      pricePerPage: pricePerPage,
      printingCost: printingCost,
      doubleSidedCost: doubleSidedCost,
      bindingCost: bindingCost,
      subtotal: subtotal,
      tax: tax,
      total: total,
      totalPages: totalPages,
      copies: userConfig.copies,
    );
  }

  /// Obtener precio por página según el rango
  double _getPricePerPage(
    Prices prices,
    PrintType printType,
    PaperSize paperSize,
    int totalPages,
  ) {
    // Seleccionar si es B&W o Color
    final copiesData = printType == PrintType.blackWhite
        ? prices.printing?.bw
        : prices.printing?.color;

    if (copiesData == null) return 0.0;

    // Seleccionar el tamaño de papel
    List<PaperCutting>? priceRanges;
    switch (paperSize) {
      case PaperSize.letter:
        priceRanges = copiesData.letter;
        break;
      case PaperSize.legal:
        priceRanges = copiesData.legal;
        break;
      case PaperSize.doubleLetter:
        priceRanges = copiesData.doubleLetter;
        break;
    }

    if (priceRanges == null || priceRanges.isEmpty) return 0.0;

    // Buscar el rango de precio correcto
    for (final range in priceRanges) {
      final min = range.min ?? 0;
      final max = range.max ?? double.infinity.toInt();

      if (totalPages >= min && totalPages <= max) {
        return range.price ?? 0.0;
      }
    }

    // Si no se encuentra, usar el último rango
    return priceRanges.last.price ?? 0.0;
  }

  /// Obtener precio de engargolado según páginas
  double _getBindingPrice(List<Binding>? bindings, int totalPages) {
    if (bindings == null || bindings.isEmpty) return 0.0;

    // Buscar el rango correcto
    for (final binding in bindings) {
      if (totalPages <= (binding.maxSheets ?? 0)) {
        return binding.price ?? 0.0;
      }
    }

    // Si excede todos los rangos, usar el más caro
    return bindings.last.price ?? 0.0;
  }

  /// Obtener rangos de precios para mostrar en UI
  String getPriceRange(PaperSize size) {
    final configAsync = ref.read(printConfigProvider);
    
    return configAsync.when(
      data: (configModel) {
        final prices = configModel.config?.prices?.printing?.bw;
        if (prices == null) return 'N/A';

        List<PaperCutting>? ranges;
        switch (size) {
          case PaperSize.letter:
            ranges = prices.letter;
            break;
          case PaperSize.legal:
            ranges = prices.legal;
            break;
          case PaperSize.doubleLetter:
            ranges = prices.doubleLetter;
            break;
        }

        if (ranges == null || ranges.isEmpty) return 'N/A';
        
        final minPrice = ranges.first.price ?? 0;
        return 'Desde \$${minPrice.toStringAsFixed(2)}';
      },
      loading: () => '...',
      error: (_, __) => 'N/A',
    );
  }
}