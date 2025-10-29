/// Configuración de impresión del pedido
class PrintConfiguration {
  final String printType; // 'bw' o 'color'
  final String paperSize; // 'letter', 'legal', 'a4'
  final String paperType; // 'bond', 'photo_glossy'
  final String orientation; // 'portrait' o 'landscape'
  final int copies;
  final bool binding;
  final bool doubleSided;

  const PrintConfiguration({
    this.printType = 'bw',
    this.paperSize = 'letter',
    this.paperType = 'bond',
    this.orientation = 'portrait',
    this.copies = 1,
    this.binding = false,
    this.doubleSided = false,
  });

  PrintConfiguration copyWith({
    String? printType,
    String? paperSize,
    String? paperType,
    String? orientation,
    int? copies,
    bool? binding,
    bool? doubleSided,
  }) {
    return PrintConfiguration(
      printType: printType ?? this.printType,
      paperSize: paperSize ?? this.paperSize,
      paperType: paperType ?? this.paperType,
      orientation: orientation ?? this.orientation,
      copies: copies ?? this.copies,
      binding: binding ?? this.binding,
      doubleSided: doubleSided ?? this.doubleSided,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'print_type': printType,
      'paper_size': paperSize,
      'paper_type': paperType,
      'orientation': orientation,
      'copies': copies,
      'binding': binding,
      'double_sided': doubleSided,
    };
  }
}

/// Análisis de archivos desde el backend
class FileAnalysis {
  final int totalPages;
  final List<FilePageInfo> files;

  const FileAnalysis({
    required this.totalPages,
    required this.files,
  });

  factory FileAnalysis.fromJson(Map<String, dynamic> json) {
    return FileAnalysis(
      totalPages: json['total_pages'] as int,
      files: (json['files'] as List<dynamic>)
          .map((f) => FilePageInfo.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FilePageInfo {
  final String filename;
  final int pages;

  const FilePageInfo({
    required this.filename,
    required this.pages,
  });

  factory FilePageInfo.fromJson(Map<String, dynamic> json) {
    return FilePageInfo(
      filename: json['filename'] as String,
      pages: json['pages'] as int,
    );
  }
}

/// Desglose de precios
class PriceBreakdown {
  final double subtotal;
  final double discount;
  final double bindingCost;
  final double total;
  final double pricePerPage;
  final int pages;

  const PriceBreakdown({
    required this.subtotal,
    required this.discount,
    required this.bindingCost,
    required this.total,
    required this.pricePerPage,
    required this.pages,
  });
}

/// Configuración de precios desde el backend
class PricingConfig {
  final Map<String, Map<String, double>> perPage; // printType -> paperSize -> price
  final Map<String, double> paperType; // paperType -> additionalCost
  final double doubleSidedDiscount; // 0.15 = 15%
  final double binding;
  final int maxCopies;

  const PricingConfig({
    required this.perPage,
    required this.paperType,
    this.doubleSidedDiscount = 0.15,
    this.binding = 2.50,
    this.maxCopies = 100,
  });

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    final perPageRaw = json['per_page'] as Map<String, dynamic>;
    final perPage = <String, Map<String, double>>{};

    perPageRaw.forEach((printType, sizes) {
      perPage[printType] = Map<String, double>.from(sizes as Map);
    });

    return PricingConfig(
      perPage: perPage,
      paperType: Map<String, double>.from(json['paper_type'] as Map? ?? {}),
      doubleSidedDiscount: (json['double_sided_discount'] as num?)?.toDouble() ?? 0.15,
      binding: (json['binding'] as num?)?.toDouble() ?? 2.50,
      maxCopies: json['max_copies'] as int? ?? 100,
    );
  }

  /// Configuración por defecto (para desarrollo)
  factory PricingConfig.defaults() {
    return const PricingConfig(
      perPage: {
        'bw': {
          'letter': 0.10,
          'legal': 0.12,
          'a4': 0.11,
        },
        'color': {
          'letter': 0.50,
          'legal': 0.60,
          'a4': 0.55,
        },
      },
      paperType: {
        'bond': 0.0,
        'photo_glossy': 0.30,
      },
      doubleSidedDiscount: 0.15,
      binding: 2.50,
      maxCopies: 100,
    );
  }
}