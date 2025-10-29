// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'print_configuration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrintConfigurationModel _$PrintConfigurationModelFromJson(
  Map<String, dynamic> json,
) => PrintConfigurationModel(
  pickupLocations: (json['pickup_locations'] as List<dynamic>?)
      ?.map((e) => PickupLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  config: json['config'] == null
      ? null
      : Config.fromJson(json['config'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PrintConfigurationModelToJson(
  PrintConfigurationModel instance,
) => <String, dynamic>{
  'pickup_locations': instance.pickupLocations?.map((e) => e.toJson()).toList(),
  'config': instance.config?.toJson(),
};

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
  prices: json['prices'] == null
      ? null
      : Prices.fromJson(json['prices'] as Map<String, dynamic>),
  services: json['services'] == null
      ? null
      : Services.fromJson(json['services'] as Map<String, dynamic>),
  delivery: json['delivery'] == null
      ? null
      : Delivery.fromJson(json['delivery'] as Map<String, dynamic>),
  limits: json['limits'] == null
      ? null
      : Limits.fromJson(json['limits'] as Map<String, dynamic>),
  allowedFileTypes: (json['allowed_file_types'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  paperSizes: json['paper_sizes'] == null
      ? null
      : PaperSizes.fromJson(json['paper_sizes'] as Map<String, dynamic>),
  statuses: json['statuses'] == null
      ? null
      : Statuses.fromJson(json['statuses'] as Map<String, dynamic>),
  paymentMethods: json['payment_methods'] == null
      ? null
      : PaymentMethods.fromJson(
          json['payment_methods'] as Map<String, dynamic>,
        ),
  tax: json['tax'] == null
      ? null
      : Tax.fromJson(json['tax'] as Map<String, dynamic>),
  notifications: json['notifications'] == null
      ? null
      : Notifications.fromJson(json['notifications'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
  'prices': instance.prices?.toJson(),
  'services': instance.services?.toJson(),
  'delivery': instance.delivery?.toJson(),
  'limits': instance.limits?.toJson(),
  'allowed_file_types': instance.allowedFileTypes,
  'paper_sizes': instance.paperSizes?.toJson(),
  'statuses': instance.statuses?.toJson(),
  'payment_methods': instance.paymentMethods?.toJson(),
  'tax': instance.tax?.toJson(),
  'notifications': instance.notifications?.toJson(),
};

Delivery _$DeliveryFromJson(Map<String, dynamic> json) => Delivery(
  national: (json['national'] as num?)?.toDouble(),
  baseCost: (json['base_cost'] as num?)?.toInt(),
  perKm: (json['per_km'] as num?)?.toDouble(),
  freeDeliveryMinimum: (json['free_delivery_minimum'] as num?)?.toInt(),
);

Map<String, dynamic> _$DeliveryToJson(Delivery instance) => <String, dynamic>{
  'national': instance.national,
  'base_cost': instance.baseCost,
  'per_km': instance.perKm,
  'free_delivery_minimum': instance.freeDeliveryMinimum,
};

Limits _$LimitsFromJson(Map<String, dynamic> json) => Limits(
  maxFileSizeMb: (json['max_file_size_mb'] as num?)?.toInt(),
  maxPages: (json['max_pages'] as num?)?.toInt(),
  maxCopies: (json['max_copies'] as num?)?.toInt(),
  maxFilesPerOrder: (json['max_files_per_order'] as num?)?.toInt(),
);

Map<String, dynamic> _$LimitsToJson(Limits instance) => <String, dynamic>{
  'max_file_size_mb': instance.maxFileSizeMb,
  'max_pages': instance.maxPages,
  'max_copies': instance.maxCopies,
  'max_files_per_order': instance.maxFilesPerOrder,
};

Notifications _$NotificationsFromJson(Map<String, dynamic> json) =>
    Notifications(
      email: json['email'] as bool?,
      sms: json['sms'] as bool?,
      whatsapp: json['whatsapp'] as bool?,
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'email': instance.email,
      'sms': instance.sms,
      'whatsapp': instance.whatsapp,
    };

PaperSizes _$PaperSizesFromJson(Map<String, dynamic> json) => PaperSizes(
  letter: json['letter'] as String?,
  legal: json['legal'] as String?,
  doubleLetter: json['double_letter'] as String?,
);

Map<String, dynamic> _$PaperSizesToJson(PaperSizes instance) =>
    <String, dynamic>{
      'letter': instance.letter,
      'legal': instance.legal,
      'double_letter': instance.doubleLetter,
    };

PaymentMethods _$PaymentMethodsFromJson(Map<String, dynamic> json) =>
    PaymentMethods(
      cash: json['cash'] as String?,
      card: json['card'] as String?,
      transfer: json['transfer'] as String?,
    );

Map<String, dynamic> _$PaymentMethodsToJson(PaymentMethods instance) =>
    <String, dynamic>{
      'cash': instance.cash,
      'card': instance.card,
      'transfer': instance.transfer,
    };

Prices _$PricesFromJson(Map<String, dynamic> json) => Prices(
  printing: json['printing'] == null
      ? null
      : Copies.fromJson(json['printing'] as Map<String, dynamic>),
  copies: json['copies'] == null
      ? null
      : Copies.fromJson(json['copies'] as Map<String, dynamic>),
  paperType: json['paper_type'] == null
      ? null
      : PaperType.fromJson(json['paper_type'] as Map<String, dynamic>),
  binding: (json['binding'] as List<dynamic>?)
      ?.map((e) => Binding.fromJson(e as Map<String, dynamic>))
      .toList(),
  doubleSided: (json['double_sided'] as num?)?.toDouble(),
  businessCards: (json['business_cards'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PricesToJson(Prices instance) => <String, dynamic>{
  'printing': instance.printing?.toJson(),
  'copies': instance.copies?.toJson(),
  'paper_type': instance.paperType?.toJson(),
  'binding': instance.binding?.map((e) => e.toJson()).toList(),
  'double_sided': instance.doubleSided,
  'business_cards': instance.businessCards,
};

Binding _$BindingFromJson(Map<String, dynamic> json) => Binding(
  maxSheets: (json['max_sheets'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BindingToJson(Binding instance) => <String, dynamic>{
  'max_sheets': instance.maxSheets,
  'price': instance.price,
};

Copies _$CopiesFromJson(Map<String, dynamic> json) => Copies(
  bw: json['bw'] == null
      ? null
      : Bw.fromJson(json['bw'] as Map<String, dynamic>),
  color: json['color'] == null
      ? null
      : Bw.fromJson(json['color'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CopiesToJson(Copies instance) => <String, dynamic>{
  'bw': instance.bw?.toJson(),
  'color': instance.color?.toJson(),
};

Bw _$BwFromJson(Map<String, dynamic> json) => Bw(
  letter: (json['letter'] as List<dynamic>?)
      ?.map((e) => PaperCutting.fromJson(e as Map<String, dynamic>))
      .toList(),
  legal: (json['legal'] as List<dynamic>?)
      ?.map((e) => PaperCutting.fromJson(e as Map<String, dynamic>))
      .toList(),
  doubleLetter: (json['double_letter'] as List<dynamic>?)
      ?.map((e) => PaperCutting.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BwToJson(Bw instance) => <String, dynamic>{
  'letter': instance.letter?.map((e) => e.toJson()).toList(),
  'legal': instance.legal?.map((e) => e.toJson()).toList(),
  'double_letter': instance.doubleLetter?.map((e) => e.toJson()).toList(),
};

PaperCutting _$PaperCuttingFromJson(Map<String, dynamic> json) => PaperCutting(
  min: (json['min'] as num?)?.toInt(),
  max: (json['max'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PaperCuttingToJson(PaperCutting instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'price': instance.price,
    };

PaperType _$PaperTypeFromJson(Map<String, dynamic> json) => PaperType(
  bond: (json['bond'] as num?)?.toInt(),
  photoGlossy: (json['photo_glossy'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PaperTypeToJson(PaperType instance) => <String, dynamic>{
  'bond': instance.bond,
  'photo_glossy': instance.photoGlossy,
};

Services _$ServicesFromJson(Map<String, dynamic> json) => Services(
  paperCutting: (json['paper_cutting'] as List<dynamic>?)
      ?.map((e) => PaperCutting.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ServicesToJson(Services instance) => <String, dynamic>{
  'paper_cutting': instance.paperCutting?.map((e) => e.toJson()).toList(),
};

Statuses _$StatusesFromJson(Map<String, dynamic> json) => Statuses(
  pending: json['pending'] as String?,
  processing: json['processing'] as String?,
  ready: json['ready'] as String?,
  delivered: json['delivered'] as String?,
  cancelled: json['cancelled'] as String?,
);

Map<String, dynamic> _$StatusesToJson(Statuses instance) => <String, dynamic>{
  'pending': instance.pending,
  'processing': instance.processing,
  'ready': instance.ready,
  'delivered': instance.delivered,
  'cancelled': instance.cancelled,
};

Tax _$TaxFromJson(Map<String, dynamic> json) =>
    Tax(iva: (json['iva'] as num?)?.toDouble());

Map<String, dynamic> _$TaxToJson(Tax instance) => <String, dynamic>{
  'iva': instance.iva,
};

PickupLocation _$PickupLocationFromJson(Map<String, dynamic> json) =>
    PickupLocation(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      address: json['address'] as String?,
      zone: json['zone'] as String?,
      phone: json['phone'] as String?,
      openingHours: json['opening_hours'] == null
          ? null
          : OpeningHours.fromJson(
              json['opening_hours'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PickupLocationToJson(PickupLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'zone': instance.zone,
      'phone': instance.phone,
      'opening_hours': instance.openingHours?.toJson(),
    };

OpeningHours _$OpeningHoursFromJson(Map<String, dynamic> json) => OpeningHours(
  lunes: json['lunes'] as String?,
  martes: json['martes'] as String?,
  miercoles: json['miercoles'] as String?,
  jueves: json['jueves'] as String?,
  viernes: json['viernes'] as String?,
  sabado: json['sabado'] as String?,
  domingo: json['domingo'] as String?,
);

Map<String, dynamic> _$OpeningHoursToJson(OpeningHours instance) =>
    <String, dynamic>{
      'lunes': instance.lunes,
      'martes': instance.martes,
      'miercoles': instance.miercoles,
      'jueves': instance.jueves,
      'viernes': instance.viernes,
      'sabado': instance.sabado,
      'domingo': instance.domingo,
    };
