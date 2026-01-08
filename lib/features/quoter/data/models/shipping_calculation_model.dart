// lib/features/quoter/data/models/shipping_calculation_model.dart

class ShippingCalculationResponse {
  final double flete;
  final double garantiaEntrega;
  final double ivaTif;
  final double dai;
  final double totalImpuestos;
  final double gestionAduanal;
  final double manejoTerceros;
  final double totalPagar;
  final double totalConDescuento;
  final double descuentoAplicado;
  final ProductInfo product;
  final double daiRate;
  final bool aplicaDai;
  final double weightLbs;
  final double originalWeight;
  final bool pesoFueAproximado;
  final double valueUsd;
  final double umbralDai;
  final double valorPorLibra;
  final bool hasFixedRate;
  final CalculationConstants constants;

  ShippingCalculationResponse({
    required this.flete,
    required this.garantiaEntrega,
    required this.ivaTif,
    required this.dai,
    required this.totalImpuestos,
    required this.gestionAduanal,
    required this.manejoTerceros,
    required this.totalPagar,
    required this.totalConDescuento,
    required this.descuentoAplicado,
    required this.product,
    required this.daiRate,
    required this.aplicaDai,
    required this.weightLbs,
    required this.originalWeight,
    required this.pesoFueAproximado,
    required this.valueUsd,
    required this.umbralDai,
    required this.valorPorLibra,
    required this.hasFixedRate,
    required this.constants,
  });

  factory ShippingCalculationResponse.fromJson(Map<String, dynamic> json) {
    return ShippingCalculationResponse(
      flete: (json['flete'] as num?)?.toDouble() ?? 0.0,
      garantiaEntrega: (json['garantia_entrega'] as num?)?.toDouble() ?? 0.0,
      ivaTif: (json['iva_tif'] as num?)?.toDouble() ?? 0.0,
      dai: (json['dai'] as num?)?.toDouble() ?? 0.0,
      totalImpuestos: (json['total_impuestos'] as num?)?.toDouble() ?? 0.0,
      gestionAduanal: (json['gestion_aduanal'] as num?)?.toDouble() ?? 0.0,
      manejoTerceros: (json['manejo_terceros'] as num?)?.toDouble() ?? 0.0,
      totalPagar: (json['total_pagar'] as num?)?.toDouble() ?? 0.0,
      totalConDescuento: (json['total_con_descuento'] as num?)?.toDouble() ?? 0.0,
      descuentoAplicado: (json['descuento_aplicado'] as num?)?.toDouble() ?? 0.0,
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'] as Map<String, dynamic>)
          : ProductInfo(id: 0, name: ''),
      daiRate: (json['dai_rate'] as num?)?.toDouble() ?? 0.0,
      aplicaDai: json['aplica_dai'] as bool? ?? false,
      weightLbs: (json['weight_lbs'] as num?)?.toDouble() ?? 0.0,
      originalWeight: (json['original_weight'] as num?)?.toDouble() ?? 0.0,
      pesoFueAproximado: json['peso_fue_aproximado'] as bool? ?? false,
      valueUsd: (json['value_usd'] as num?)?.toDouble() ?? 0.0,
      umbralDai: (json['umbral_dai'] as num?)?.toDouble() ?? 0.0,
      valorPorLibra: (json['valor_por_libra'] as num?)?.toDouble() ?? 0.0,
      hasFixedRate: json['has_fixed_rate'] as bool? ?? false,
      constants: json['constants'] != null
          ? CalculationConstants.fromJson(json['constants'] as Map<String, dynamic>)
          : CalculationConstants(),
    );
  }
}

class ProductInfo {
  final int id;
  final String name;

  ProductInfo({
    required this.id,
    required this.name,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

class CalculationConstants {
  final double valorLibra;
  final double gestionAduanal;
  final double manejoTerceros;
  final double garantiaEntregaPercentage;
  final double ivaTifPercentage;
  final double daiPercentage;
  final double umbralDai;

  CalculationConstants({
    this.valorLibra = 4.99,
    this.gestionAduanal = 4.99,
    this.manejoTerceros = 2.74,
    this.garantiaEntregaPercentage = 1.0,
    this.ivaTifPercentage = 14.5,
    this.daiPercentage = 15.0,
    this.umbralDai = 300.0,
  });

  factory CalculationConstants.fromJson(Map<String, dynamic> json) {
    return CalculationConstants(
      valorLibra: (json['valor_libra'] as num?)?.toDouble() ?? 4.99,
      gestionAduanal: (json['gestion_aduanal'] as num?)?.toDouble() ?? 4.99,
      manejoTerceros: (json['manejo_terceros'] as num?)?.toDouble() ?? 2.74,
      garantiaEntregaPercentage: (json['garantia_entrega_percentage'] as num?)?.toDouble() ?? 1.0,
      ivaTifPercentage: (json['iva_tif_percentage'] as num?)?.toDouble() ?? 14.5,
      daiPercentage: (json['dai_percentage'] as num?)?.toDouble() ?? 15.0,
      umbralDai: (json['umbral_dai'] as num?)?.toDouble() ?? 300.0,
    );
  }
}

