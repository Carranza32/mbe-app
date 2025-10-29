import 'package:json_annotation/json_annotation.dart';

part 'print_configuration_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PrintConfigurationModel {
  @JsonKey(name: 'pickup_locations')
  final List<PickupLocation>? pickupLocations;
  final Config? config;

  PrintConfigurationModel({this.pickupLocations, this.config});

  factory PrintConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$PrintConfigurationModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrintConfigurationModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Config {
  final Prices? prices;
  final Services? services;
  final Delivery? delivery;
  final Limits? limits;
  @JsonKey(name: 'allowed_file_types')
  final List<String>? allowedFileTypes;
  @JsonKey(name: 'paper_sizes')
  final PaperSizes? paperSizes;
  final Statuses? statuses;
  @JsonKey(name: 'payment_methods')
  final PaymentMethods? paymentMethods;
  final Tax? tax;
  final Notifications? notifications;

  Config({
    this.prices,
    this.services,
    this.delivery,
    this.limits,
    this.allowedFileTypes,
    this.paperSizes,
    this.statuses,
    this.paymentMethods,
    this.tax,
    this.notifications,
  });

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}

@JsonSerializable()
class Delivery {
  final double? national;
  @JsonKey(name: 'base_cost')
  final int? baseCost;
  @JsonKey(name: 'per_km')
  final double? perKm;
  @JsonKey(name: 'free_delivery_minimum')
  final int? freeDeliveryMinimum;

  Delivery({this.national, this.baseCost, this.perKm, this.freeDeliveryMinimum});

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryToJson(this);
}

@JsonSerializable()
class Limits {
  @JsonKey(name: 'max_file_size_mb')
  final int? maxFileSizeMb;
  @JsonKey(name: 'max_pages')
  final int? maxPages;
  @JsonKey(name: 'max_copies')
  final int? maxCopies;
  @JsonKey(name: 'max_files_per_order')
  final int? maxFilesPerOrder;

  Limits({this.maxFileSizeMb, this.maxPages, this.maxCopies, this.maxFilesPerOrder});

  factory Limits.fromJson(Map<String, dynamic> json) => _$LimitsFromJson(json);
  Map<String, dynamic> toJson() => _$LimitsToJson(this);
}

@JsonSerializable()
class Notifications {
  final bool? email;
  final bool? sms;
  final bool? whatsapp;

  Notifications({this.email, this.sms, this.whatsapp});

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}

@JsonSerializable()
class PaperSizes {
  final String? letter;
  final String? legal;
  @JsonKey(name: 'double_letter')
  final String? doubleLetter;

  PaperSizes({this.letter, this.legal, this.doubleLetter});

  factory PaperSizes.fromJson(Map<String, dynamic> json) =>
      _$PaperSizesFromJson(json);
  Map<String, dynamic> toJson() => _$PaperSizesToJson(this);
}

@JsonSerializable()
class PaymentMethods {
  final String? cash;
  final String? card;
  final String? transfer;

  PaymentMethods({this.cash, this.card, this.transfer});

  factory PaymentMethods.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodsFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Prices {
  final Copies? printing;
  final Copies? copies;
  @JsonKey(name: 'paper_type')
  final PaperType? paperType;
  final List<Binding>? binding;
  @JsonKey(name: 'double_sided')
  final double? doubleSided;
  @JsonKey(name: 'business_cards')
  final double? businessCards;

  Prices({
    this.printing,
    this.copies,
    this.paperType,
    this.binding,
    this.doubleSided,
    this.businessCards,
  });

  factory Prices.fromJson(Map<String, dynamic> json) => _$PricesFromJson(json);
  Map<String, dynamic> toJson() => _$PricesToJson(this);
}

@JsonSerializable()
class Binding {
  @JsonKey(name: 'max_sheets')
  final int? maxSheets;
  final double? price;

  Binding({this.maxSheets, this.price});

  factory Binding.fromJson(Map<String, dynamic> json) =>
      _$BindingFromJson(json);
  Map<String, dynamic> toJson() => _$BindingToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Copies {
  final Bw? bw;
  final Bw? color;

  Copies({this.bw, this.color});

  factory Copies.fromJson(Map<String, dynamic> json) => _$CopiesFromJson(json);
  Map<String, dynamic> toJson() => _$CopiesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Bw {
  final List<PaperCutting>? letter;
  final List<PaperCutting>? legal;
  @JsonKey(name: 'double_letter')
  final List<PaperCutting>? doubleLetter;

  Bw({this.letter, this.legal, this.doubleLetter});

  factory Bw.fromJson(Map<String, dynamic> json) => _$BwFromJson(json);
  Map<String, dynamic> toJson() => _$BwToJson(this);
}

@JsonSerializable()
class PaperCutting {
  final int? min;
  final int? max;
  final double? price;

  PaperCutting({this.min, this.max, this.price});

  factory PaperCutting.fromJson(Map<String, dynamic> json) =>
      _$PaperCuttingFromJson(json);
  Map<String, dynamic> toJson() => _$PaperCuttingToJson(this);
}

@JsonSerializable()
class PaperType {
  final int? bond;
  @JsonKey(name: 'photo_glossy')
  final double? photoGlossy;

  PaperType({this.bond, this.photoGlossy});

  factory PaperType.fromJson(Map<String, dynamic> json) =>
      _$PaperTypeFromJson(json);
  Map<String, dynamic> toJson() => _$PaperTypeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Services {
  @JsonKey(name: 'paper_cutting')
  final List<PaperCutting>? paperCutting;

  Services({this.paperCutting});

  factory Services.fromJson(Map<String, dynamic> json) =>
      _$ServicesFromJson(json);
  Map<String, dynamic> toJson() => _$ServicesToJson(this);
}

@JsonSerializable()
class Statuses {
  final String? pending;
  final String? processing;
  final String? ready;
  final String? delivered;
  final String? cancelled;

  Statuses({
    this.pending,
    this.processing,
    this.ready,
    this.delivered,
    this.cancelled,
  });

  factory Statuses.fromJson(Map<String, dynamic> json) =>
      _$StatusesFromJson(json);
  Map<String, dynamic> toJson() => _$StatusesToJson(this);
}

@JsonSerializable()
class Tax {
  final double? iva;

  Tax({this.iva});

  factory Tax.fromJson(Map<String, dynamic> json) => _$TaxFromJson(json);
  Map<String, dynamic> toJson() => _$TaxToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PickupLocation {
  final int? id;
  final String? name;
  final String? address;
  final String? zone;
  final String? phone;
  @JsonKey(name: 'opening_hours')
  final OpeningHours? openingHours;

  PickupLocation({
    this.id,
    this.name,
    this.address,
    this.zone,
    this.phone,
    this.openingHours,
  });

  factory PickupLocation.fromJson(Map<String, dynamic> json) =>
      _$PickupLocationFromJson(json);
  Map<String, dynamic> toJson() => _$PickupLocationToJson(this);
}

@JsonSerializable()
class OpeningHours {
  final String? lunes;
  final String? martes;
  final String? miercoles;
  final String? jueves;
  final String? viernes;
  final String? sabado;
  final String? domingo;

  OpeningHours({
    this.lunes,
    this.martes,
    this.miercoles,
    this.jueves,
    this.viernes,
    this.sabado,
    this.domingo,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) =>
      _$OpeningHoursFromJson(json);
  Map<String, dynamic> toJson() => _$OpeningHoursToJson(this);
}
