// lib/features/pre_alert/providers/products_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'products_provider.g.dart';

class Product {
  final String id;
  final String name;

  Product({required this.id, required this.name});
}

@riverpod
class Products extends _$Products {
  @override
  Future<List<Product>> build() async {
    // TODO: Reemplazar con API real
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Product(id: '1', name: 'Chaqueta'),
      Product(id: '2', name: 'Zapatos'),
      Product(id: '3', name: 'Pantalón'),
      Product(id: '4', name: 'Camisa'),
      Product(id: '5', name: 'Electrónicos'),
      Product(id: '6', name: 'Libro'),
      Product(id: '7', name: 'Juguete'),
      Product(id: '8', name: 'Accesorio'),
      Product(id: '9', name: 'Ropa deportiva'),
      Product(id: '10', name: 'Otros'),
    ];
  }
}
