import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/product_category_model.dart';
import '../../data/models/product_item_model.dart';
import '../../data/models/status_history_model.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../../providers/package_edit_manager.dart';
import '../../providers/product_categories_provider.dart';
import '../../providers/status_history_provider.dart';

class PackageEditModal extends ConsumerStatefulWidget {
  final AdminPreAlert package;

  const PackageEditModal({super.key, required this.package});

  @override
  ConsumerState<PackageEditModal> createState() => _PackageEditModalState();
}

class _PackageEditModalState extends ConsumerState<PackageEditModal> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isLoadingPackage = false;

  // Controllers
  late TextEditingController _trackingController;
  late TextEditingController _eboxController;
  late TextEditingController _clientNameController;
  late TextEditingController _totalController;
  late TextEditingController _productCountController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _contactNotesController;
  late TextEditingController _receiverNameController;
  late TextEditingController _receiverEmailController;
  late TextEditingController _receiverPhoneController;

  String? _selectedDeliveryMethod;
  String? _selectedFile;
  File? _selectedFileObject;
  List<ProductItem> _products = [];

  @override
  void initState() {
    super.initState();
    _loadFullPackage();
    // Inicializar con datos básicos mientras carga
    _initializeControllers(widget.package);
  }

  void _initializeControllers(AdminPreAlert package) {
    _trackingController = TextEditingController(
      text: package.trackingNumber,
    );
    _eboxController = TextEditingController(text: package.eboxCode);
    _clientNameController = TextEditingController(
      text: package.clientName,
    );
    _totalController = TextEditingController(
      text: package.total.toStringAsFixed(2),
    );
    _productCountController = TextEditingController(
      text: package.productCount.toString(),
    );
    _contactNameController = TextEditingController(
      text: package.contactName ?? '',
    );
    _contactEmailController = TextEditingController(
      text: package.contactEmail ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: package.contactPhone ?? '',
    );
    _contactNotesController = TextEditingController(
      text: package.contactNotes ?? '',
    );
    _receiverNameController = TextEditingController(
      text: package.receiverName ?? '',
    );
    _receiverEmailController = TextEditingController(
      text: package.receiverEmail ?? '',
    );
    _receiverPhoneController = TextEditingController(
      text: package.receiverPhone ?? '',
    );
    _selectedDeliveryMethod = package.deliveryMethod;
    
    // Inicializar productos si vienen en el paquete
    _initializeProducts(package);
  }
  
  void _initializeProducts(AdminPreAlert package) {
    // Inicializar con productos vacíos basados en productCount
    _products = List.generate(
      package.productCount > 0 ? package.productCount : 1,
      (index) => ProductItem(quantity: 0, price: 0.0),
    );
  }
  
  void _loadProductsFromPackage(AdminPreAlert package) {
    // Cargar productos reales si vienen en el paquete
    if (package.products != null && package.products!.isNotEmpty) {
      setState(() {
        _products = package.products!.map((p) => ProductItem(
          productCategoryId: p.productCategoryId,
          productCategoryName: p.productCategoryName,
          quantity: p.quantity,
          price: p.price,
          description: p.description,
          weight: p.weight,
          // Si el producto no tiene weightType, usar el del paquete general
          weightType: p.weightType ?? package.weightType,
        )).toList();
      });
    } else {
      // Si no hay productos, inicializar basado en productCount
      final currentCount = _products.length;
      final packageCount = package.productCount;
      
      if (packageCount > currentCount) {
        _products.addAll(
          List.generate(
            packageCount - currentCount,
            (index) => ProductItem(quantity: 0, price: 0.0),
          ),
        );
      } else if (packageCount < currentCount) {
        _products = _products.take(packageCount).toList();
      }
    }
  }
  
  void _updateProductCount(int newCount) {
    if (newCount < 0) return;
    
    setState(() {
      if (newCount > _products.length) {
        // Agregar productos vacíos
        _products.addAll(
          List.generate(
            newCount - _products.length,
            (index) => ProductItem(quantity: 0, price: 0.0),
          ),
        );
      } else if (newCount < _products.length) {
        // Remover productos extra
        _products = _products.take(newCount).toList();
      }
    });
  }

  Future<void> _loadFullPackage() async {
    if (!mounted) return;
    setState(() => _isLoadingPackage = true);
    
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final fullPackage = await repository.getPreAlertById(widget.package.id);
      
      if (!mounted) return;
      
      setState(() {
        _isLoadingPackage = false;
        // Actualizar controllers con datos completos
        // Disposing old controllers first
        _trackingController.dispose();
        _eboxController.dispose();
        _clientNameController.dispose();
        _totalController.dispose();
        _productCountController.dispose();
        _contactNameController.dispose();
        _contactEmailController.dispose();
        _contactPhoneController.dispose();
        _contactNotesController.dispose();
        _receiverNameController.dispose();
        _receiverEmailController.dispose();
        _receiverPhoneController.dispose();
        _initializeControllers(fullPackage);
        // Cargar productos si vienen en el paquete
        _loadProductsFromPackage(fullPackage);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPackage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar paquete: ${e.toString()}'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _eboxController.dispose();
    _clientNameController.dispose();
    _totalController.dispose();
    _productCountController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactNotesController.dispose();
    _receiverNameController.dispose();
    _receiverEmailController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detectar altura del teclado para mover los botones
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92, // 92% de altura
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // 1. MANIJA PARA ARRASTRAR
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // 2. HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Editar Paquete',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    Text(
                      widget.package.trackingNumber,
                      style: TextStyle(
                        color: MBETheme.neutralGray.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[100],
                    child: const Icon(
                      Iconsax.close_circle,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. FORMULARIO SCROLLABLE
          Expanded(
            child: _isLoadingPackage
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Sección: Info Básica ---
                    _buildSectionHeader('Información Básica'),
                    _buildModernInput(
                      controller: _trackingController,
                      label: 'Tracking Number',
                      icon: Iconsax.barcode,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInput(
                      controller: _eboxController,
                      label: 'Código Ebox',
                      icon: Iconsax.box,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInput(
                      controller: _clientNameController,
                      label: 'Cliente',
                      icon: Iconsax.user,
                      isRequired: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernInput(
                            controller: _totalController,
                            label: 'Total (\$)',
                            icon: Iconsax.dollar_circle,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernInput(
                            controller: _productCountController,
                            label: 'Cant. Items',
                            icon: Iconsax.box_1,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            onChanged: (value) {
                              final count = int.tryParse(value) ?? 0;
                              _updateProductCount(count);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    
                    // --- Sección: Productos ---
                    _buildSectionHeader('Productos'),
                    ..._buildProductFields(),

                    const SizedBox(height: 24),

                    // --- Sección: Entrega ---
                    _buildSectionHeader('Método de Entrega'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedDeliveryMethod,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Iconsax.truck, color: Colors.blueAccent),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pickup',
                            child: Text('Pickup (Tienda)'),
                          ),
                          DropdownMenuItem(
                            value: 'delivery',
                            child: Text('Delivery (Domicilio)'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedDeliveryMethod = value),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Sección: Contacto ---
                    _buildSectionHeader('Contacto & Notas'),
                    _buildModernInput(
                      controller: _contactNameController,
                      label: 'Nombre Contacto',
                      icon: Iconsax.user_tag,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInput(
                      controller: _contactEmailController,
                      label: 'Email',
                      icon: Iconsax.sms,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInput(
                      controller: _contactPhoneController,
                      label: 'Teléfono',
                      icon: Iconsax.call,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildModernInput(
                      controller: _contactNotesController,
                      label: 'Notas internas',
                      icon: Iconsax.note,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),

                    // --- Sección: Historial de Estados ---
                    _buildSectionHeader('Historial de Estados'),
                    _buildStatusHistory(),

                    const SizedBox(height: 24),

                    // --- Sección: Documentos ---
                    _buildSectionHeader('Adjuntos'),
                    _buildFilePicker(),

                    // Espacio extra al final para que no quede pegado
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // 4. BOTÓN DE ACCIÓN (FLOTANTE SOBRE TECLADO)
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: DSButton.primary(
              label: _isLoading
                  ? 'Guardando...'
                  : _isUploading
                  ? 'Subiendo archivo...'
                  : 'Guardar Cambios',
              fullWidth: true,
              icon: Iconsax.tick_circle,
              onPressed: (_isLoading || _isUploading) ? null : _saveChanges,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE ESTILO ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: MBETheme.neutralGray.withOpacity(0.7),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7), // Gris muy suave estilo Apple
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          icon: Icon(icon, color: Colors.black87, size: 20),
          border: InputBorder.none, // Sin bordes feos
          contentPadding: maxLines > 1
              ? const EdgeInsets.symmetric(vertical: 8)
              : null,
        ),
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Requerido' : null
            : null,
      ),
    );
  }

  Widget _buildFilePicker() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedFile != null
              ? Colors.blue.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedFile != null ? Colors.blue : Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedFile != null ? Colors.blue : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedFile != null
                    ? Iconsax.document_text5
                    : Iconsax.document_upload,
                color: _selectedFile != null ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFile ?? 'Subir Documento',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedFile != null
                          ? Colors.blue
                          : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_selectedFile == null)
                    Text(
                      'PDF, Imágenes o Facturas',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ),
            if (_selectedFile != null)
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () => setState(() {
                  _selectedFile = null;
                  _selectedFileObject = null;
                }),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductFields() {
    if (_products.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MBETheme.lightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, color: MBETheme.neutralGray, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ingresa la cantidad de productos para agregar los campos',
                  style: TextStyle(
                    color: MBETheme.neutralGray,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return List.generate(_products.length, (index) {
      return _buildProductItem(index);
    });
  }

  Widget _buildProductItem(int index) {
    final product = _products[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: MBETheme.brandBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Producto ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (_products.length > 1)
                IconButton(
                  icon: const Icon(Iconsax.trash, size: 18),
                  color: Colors.redAccent,
                  onPressed: () {
                    setState(() {
                      _products.removeAt(index);
                      _productCountController.text = _products.length.toString();
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Selector de categoría de producto
          _buildProductCategorySelector(
            index,
            product.productCategoryId,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProductInput(
                  initialValue: product.quantity > 0 ? product.quantity.toString() : '',
                  label: 'Cantidad',
                  icon: Iconsax.box_1,
                  keyboardType: TextInputType.number,
                  isRequired: true,
                  onChanged: (value) {
                    final qty = int.tryParse(value) ?? 0;
                    setState(() {
                      _products[index] = product.copyWith(quantity: qty);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProductInput(
                  initialValue: product.price > 0 ? product.price.toStringAsFixed(2) : '',
                  label: 'Precio (\$)',
                  icon: Iconsax.dollar_circle,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: true,
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    setState(() {
                      _products[index] = product.copyWith(price: price);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProductInput(
            initialValue: product.description ?? '',
            label: 'Descripción del Producto',
            icon: Iconsax.note_text,
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                _products[index] = product.copyWith(description: value);
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProductInput(
                  initialValue: product.weight != null ? product.weight!.toStringAsFixed(2) : '',
                  label: 'Peso',
                  icon: Iconsax.weight,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    setState(() {
                      _products[index] = product.copyWith(weight: weight);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonFormField<String>(
                    value: product.weightType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Peso',
                      labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      icon: const Icon(Iconsax.ruler, color: Colors.black87, size: 20),
                      border: InputBorder.none,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'LB', child: Text('LB')),
                      DropdownMenuItem(value: 'KG', child: Text('KG')),
                      DropdownMenuItem(value: 'OZ', child: Text('OZ')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _products[index] = product.copyWith(weightType: value);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCategorySelector(
    int productIndex,
    int? selectedCategoryId,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        // Cargar categorías iniciales
        final categoriesState = ref.watch(productCategoriesProvider());

        return categoriesState.when(
          data: (initialCategories) {
            ProductCategory? selectedCategory;
            if (selectedCategoryId != null && initialCategories.isNotEmpty) {
              try {
                selectedCategory = initialCategories.firstWhere(
                  (cat) => cat.id == selectedCategoryId,
                );
              } catch (e) {
                // Si no se encuentra, buscar de nuevo con el ID
                selectedCategory = null;
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownSearch<ProductCategory>(
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Buscar categoría...',
                      prefixIcon: const Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  menuProps: const MenuProps(
                    backgroundColor: Colors.white,
                    elevation: 8,
                  ),
                ),
                asyncItems: (String? search) async {
                  // Búsqueda del servidor
                  final provider = productCategoriesProvider(
                    search: search?.isEmpty == true ? null : search,
                    perPage: 50,
                  );
                  final result = await ref.read(provider.future);
                  return result;
                },
                items: initialCategories,
                selectedItem: selectedCategory,
                itemAsString: (category) => category.name,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Producto *',
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    icon: const Icon(Iconsax.box, color: Colors.black87, size: 20),
                    border: InputBorder.none,
                  ),
                ),
                onChanged: (category) {
                  if (category != null) {
                    setState(() {
                      _products[productIndex] = _products[productIndex].copyWith(
                        productCategoryId: category.id,
                        productCategoryName: category.name,
                      );
                    });
                  }
                },
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Cargando categorías...'),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.danger, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al cargar categorías',
                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductInput({
    required String initialValue,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          icon: Icon(icon, color: Colors.black87, size: 20),
          border: InputBorder.none,
          contentPadding: maxLines > 1
              ? const EdgeInsets.symmetric(vertical: 8)
              : null,
        ),
        validator: isRequired
            ? (value) => value == null || value.isEmpty ? 'Requerido' : null
            : null,
      ),
    );
  }

  // --- WIDGETS DE UI ---

  Widget _buildStatusHistory() {
    return Consumer(
      builder: (context, ref, child) {
        final historyState = ref.watch(statusHistoryProvider(widget.package.id));

        return historyState.when(
          data: (history) {
            if (history.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MBETheme.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle,
                        color: MBETheme.neutralGray, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No hay historial de estados disponible',
                        style: TextStyle(
                          color: MBETheme.neutralGray,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                children: List.generate(history.length, (index) {
                  final item = history[index];
                  final isLast = index == history.length - 1;
                  return _buildHistoryItem(item, isLast);
                }),
              ),
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MBETheme.lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Cargando historial...'),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.danger, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error al cargar historial',
                    style: TextStyle(color: Colors.red[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(StatusHistoryItem item, bool isLast) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final dateStr = dateFormat.format(item.changedAt);

    // Determinar el color del badge según el color del estado
    Color badgeColor = MBETheme.brandBlack;
    if (item.status.color != null) {
      switch (item.status.color) {
        case 'success':
          badgeColor = Colors.green;
          break;
        case 'warning':
          badgeColor = Colors.orange;
          break;
        case 'error':
        case 'danger':
          badgeColor = MBETheme.brandRed;
          break;
        case 'info':
          badgeColor = Colors.blue;
          break;
        case 'primary':
          badgeColor = MBETheme.brandBlack;
          break;
        default:
          badgeColor = MBETheme.brandBlack;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea vertical y punto
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado y fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.status.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: MBETheme.neutralGray,
                      ),
                    ),
                  ],
                ),
                // Estado anterior (si existe)
                if (item.previousStatus != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Desde: ${item.previousStatus!.label}',
                    style: TextStyle(
                      fontSize: 11,
                      color: MBETheme.neutralGray.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                // Notas (si existen)
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MBETheme.lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Iconsax.note_text,
                            size: 14, color: MBETheme.neutralGray),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: TextStyle(
                              fontSize: 12,
                              color: MBETheme.brandBlack.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Usuario que hizo el cambio
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.user,
                        size: 12, color: MBETheme.neutralGray),
                    const SizedBox(width: 4),
                    Text(
                      '${item.changedBy.name} (${item.changedBy.email})',
                      style: TextStyle(
                        fontSize: 11,
                        color: MBETheme.neutralGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LÓGICA DE NEGOCIO (Igual que antes) ---

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = result.files.single.name;
          _selectedFileObject = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final updates = <String, dynamic>{
        'track_number': _trackingController.text.trim(),
        'package_code': _eboxController.text.trim().isEmpty
            ? null
            : _eboxController.text.trim(),
        'total': double.tryParse(_totalController.text.trim()) ?? 0.0,
        'product_count': int.tryParse(_productCountController.text.trim()) ?? 0,
        'delivery_method': _selectedDeliveryMethod,
        'contact_name': _contactNameController.text.trim().isEmpty
            ? null
            : _contactNameController.text.trim(),
        'contact_email': _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        'contact_phone': _contactPhoneController.text.trim().isEmpty
            ? null
            : _contactPhoneController.text.trim(),
        'contact_notes': _contactNotesController.text.trim().isEmpty
            ? null
            : _contactNotesController.text.trim(),
        'receiver_name': _receiverNameController.text.trim().isEmpty
            ? null
            : _receiverNameController.text.trim(),
        'receiver_email': _receiverEmailController.text.trim().isEmpty
            ? null
            : _receiverEmailController.text.trim(),
        'receiver_phone': _receiverPhoneController.text.trim().isEmpty
            ? null
            : _receiverPhoneController.text.trim(),
        'is_different_receiver': _receiverNameController.text.trim().isNotEmpty
            ? 1
            : 0,
        'products': _products
            .where((p) => p.productCategoryId != null && p.quantity > 0)
            .map((p) => p.toJson())
            .toList(),
      };

      if (!mounted) return;
      final editManager = ref.read(packageEditManagerProvider.notifier);
      final success = await editManager.updatePackage(
        packageId: widget.package.id,
        updates: updates,
      );

      if (!mounted) return;
      if (!success) throw Exception('Error al actualizar');

      if (_selectedFileObject != null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isUploading = true;
        });
        final uploadSuccess = await editManager.uploadDocument(
          packageId: widget.package.id,
          filePath: _selectedFileObject!.path,
        );
        if (!mounted) return;
        if (!uploadSuccess) throw Exception('Error al subir documento');
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guardado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: MBETheme.brandRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }
}
