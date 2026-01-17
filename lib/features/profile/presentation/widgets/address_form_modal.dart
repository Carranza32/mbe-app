import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../core/design_system/ds_buttons.dart';
import '../../../../core/design_system/ds_inputs.dart'; // Asegúrate de que tus DSInput soporten estilo moderno
import '../../data/models/address_model.dart';
import '../../data/models/geo_model.dart';
import '../../data/repositories/geo_repository.dart';

class AddressFormModal extends ConsumerStatefulWidget {
  final AddressModel? address;
  final Function(AddressModel) onSave;

  const AddressFormModal({Key? key, this.address, required this.onSave})
    : super(key: key);

  @override
  ConsumerState<AddressFormModal> createState() => _AddressFormModalState();
}

class _AddressFormModalState extends ConsumerState<AddressFormModal> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _referencesController;

  // Ubicación
  String _countryCode = 'SV';
  String? _regionCode;
  String? _region;
  String? _cityCode;
  String? _city;
  String? _localityCode;
  String? _locality;

  // Data Lists
  List<GeoOption> _regions = [];
  List<GeoOption> _cities = [];
  List<GeoOption> _localities = [];

  // UI States
  bool _loadingRegions = false;
  bool _loadingCities = false;
  bool _loadingLocalities = false;
  bool _isLocalityDisabled = true;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _nameController = TextEditingController(text: address?.name ?? '');
    _addressController = TextEditingController(text: address?.address ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _referencesController = TextEditingController(
      text: address?.references ?? '',
    );

    if (address != null) {
      _regionCode = address.regionCode;
      _region = address.region;
      _cityCode = address.cityCode;
      _city = address.city;
      _localityCode = address.localityCode;
      _locality = address.locality;
      _isDefault = address.isDefault;
    }

    // Carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRegions());
  }

  Future<void> _loadRegions() async {
    setState(() => _loadingRegions = true);
    try {
      final regions = await ref
          .read(geoRepositoryProvider)
          .getAdm1(_countryCode);
      if (mounted) {
        setState(() {
          _regions = regions;
          _loadingRegions = false;
        });
        if (widget.address != null && _regionCode != null) _loadCities();
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRegions = false);
    }
  }

  Future<void> _loadCities() async {
    if (_regionCode == null) return;
    setState(() => _loadingCities = true);
    try {
      final cities = await ref
          .read(geoRepositoryProvider)
          .getAdm2(_countryCode, _regionCode!);
      if (mounted) {
        setState(() {
          _cities = cities;
          _loadingCities = false;
          // Solo limpiar localidades si NO estamos editando
          if (widget.address == null) {
            _localities = [];
            _localityCode = null;
            _locality = null;
            _isLocalityDisabled = true;
          } else {
            // Mantener los valores mientras cargamos (no limpiar localityCode/locality)
            _localities = [];
            _isLocalityDisabled = true;
          }
        });

        // Si estamos editando y ya tenemos cityCode, cargar localidades
        if (widget.address != null && _cityCode != null) {
          await _loadLocalities();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  Future<void> _loadLocalities() async {
    if (_regionCode == null || _cityCode == null) {
      setState(() {
        _localities = [];
        _isLocalityDisabled = true;
        // Solo limpiar si NO estamos editando
        if (widget.address == null) {
          _localityCode = null;
          _locality = null;
        }
      });
      return;
    }

    // Guardar el valor actual de localidad si estamos editando
    final savedLocalityCode = widget.address != null ? _localityCode : null;
    final savedLocality = widget.address != null ? _locality : null;

    setState(() => _loadingLocalities = true);
    try {
      final localities = await ref
          .read(geoRepositoryProvider)
          .getAdm3(_countryCode, _regionCode!, _cityCode!);
      if (mounted) {
        setState(() {
          _localities = localities;
          _isLocalityDisabled = localities.isEmpty;
          _loadingLocalities = false;

          // Si estamos editando y tenemos un localityCode guardado, restaurarlo
          if (widget.address != null && savedLocalityCode != null) {
            // Verificar que el código existe en la lista cargada
            final exists = localities.any((l) => l.code == savedLocalityCode);
            if (exists) {
              _localityCode = savedLocalityCode;
              _locality = savedLocality;
            } else {
              // Si no existe, limpiar
              _localityCode = null;
              _locality = null;
            }
          } else if (localities.isEmpty) {
            // Si no hay localidades, limpiar la selección
            _localityCode = null;
            _locality = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _localities = [];
          _isLocalityDisabled = true;
          _loadingLocalities = false;
          // Si estamos editando, mantener los valores guardados
          if (widget.address == null) {
            _localityCode = null;
            _locality = null;
          }
        });
      }
    }
  }

  bool _isFormValid() {
    // Validar que todos los campos requeridos estén completos
    if (_nameController.text.trim().isEmpty) return false;
    if (_countryCode.isEmpty || _countryCode.length != 2) return false;
    if (_regionCode == null || _regionCode!.isEmpty) return false;
    if (_region == null || _region!.isEmpty) return false;
    if (_cityCode == null || _cityCode!.isEmpty) return false;
    if (_city == null || _city!.isEmpty) return false;
    if (_addressController.text.trim().isEmpty) return false;
    if (_phoneController.text.trim().isEmpty) return false;

    return true;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar campos requeridos
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El nombre de la dirección es requerido"),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    if (_regionCode == null || _regionCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar un departamento"),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    if (_cityCode == null || _cityCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar un municipio"),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La dirección es requerida"),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El teléfono es requerido"),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Validar formato de teléfono
    final phoneRegex = RegExp(r'^(\d{4}-\d{4}|\d{8}|\+\d{1,3}\d{4,14})$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Formato de teléfono inválido"),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Crear dirección y guardar
    final address = AddressModel(
      id: widget.address?.id ?? 0,
      name: _nameController.text.trim(),
      countryCode: _countryCode,
      country: _countryCode, // Usar el código del país como country también
      regionCode: _regionCode!,
      region: _region!,
      cityCode: _cityCode!,
      city: _city!,
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      isDefault: _isDefault,
      references: _referencesController.text.trim().isEmpty
          ? null
          : _referencesController.text.trim(),
      localityCode: _localityCode,
      locality: _locality,
    );

    widget.onSave(address);

    // Solo cerrar el modal después de guardar exitosamente
    // El cierre se manejará en AddressesSection después de que se guarde
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height:
          MediaQuery.of(context).size.height * 0.92, // Casi pantalla completa
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // 1. Manija y Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Editar Dirección' : 'Nueva Dirección',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Completa los datos para tus envíos",
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: const Icon(
                      Iconsax.close_circle,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 2. Formulario Scrollable
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Cerrar el teclado al tocar fuera de los campos
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre (Alias)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: _buildRequiredLabel("ALIAS DE LA DIRECCIÓN"),
                      ),
                      DSInput.text(
                        hint: 'Ej. Casa, Oficina, Bodega...',
                        controller: _nameController,
                        prefixIcon: Iconsax.tag,
                        required: true,
                        label: '',
                        onChanged: (String p1) {
                          setState(
                            () {},
                          ); // Actualizar para habilitar/deshabilitar botón
                        },
                      ),

                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: _buildRequiredLabel("UBICACIÓN"),
                      ),

                      // Departamento
                      _buildDropdown(
                        hint: "Departamento",
                        value: _regionCode,
                        isLoading: _loadingRegions,
                        items: _regions
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.code,
                                child: Text(r.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _regionCode = val as String?;
                            _region = _regions
                                .firstWhere((r) => r.code == val)
                                .label;
                            _cityCode = null; // Reset ciudad
                            _city = null;
                            _cities = [];
                          });
                          _loadCities();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Municipio
                      _buildDropdown(
                        hint: "Municipio",
                        value: _cityCode,
                        isLoading: _loadingCities,
                        isDisabled: _regionCode == null,
                        items: _cities
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.code,
                                child: Text(c.label),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _cityCode = val as String?;
                            _city = _cities
                                .firstWhere((c) => c.code == val)
                                .label;
                            // Limpiar localidades cuando cambia el municipio
                            _localities = [];
                            _localityCode = null;
                            _locality = null;
                          });
                          _loadLocalities();
                        },
                      ),

                      // Distrito/Subzona (ADM3) - Opcional
                      if (_cities.isNotEmpty && _cityCode != null) ...[
                        const SizedBox(height: 16),
                        _buildDropdown(
                          hint: "Distrito / Subzona (Opcional)",
                          value: _localityCode,
                          isLoading: _loadingLocalities,
                          isDisabled: _isLocalityDisabled || _cityCode == null,
                          items: _localities
                              .map(
                                (l) => DropdownMenuItem(
                                  value: l.code,
                                  child: Text(l.label),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _localityCode = val as String?;
                              _locality = _localities
                                  .firstWhere((l) => l.code == val)
                                  .label;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: _buildRequiredLabel("DETALLES"),
                      ),

                      // Dirección exacta
                      DSInput.textArea(
                        hint: 'Calle, pasaje, número de casa, colonia...',
                        controller: _addressController,
                        required: true,
                        maxLines: 3,
                        label: '',
                        onChanged: (String p1) {
                          setState(
                            () {},
                          ); // Actualizar para habilitar/deshabilitar botón
                        },
                      ),

                      const SizedBox(height: 16),

                      // Referencias
                      DSInput.textArea(
                        hint: 'Referencias (Portón negro, frente al parque...)',
                        controller: _referencesController,
                        maxLines: 2,
                        label: '',
                        onChanged: (String p1) {},
                      ),

                      const SizedBox(height: 16),

                      // Teléfono
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: _buildRequiredLabel("TELÉFONO"),
                      ),
                      DSInput.phone(
                        hint: '2222-2222 o 7777-7777',
                        controller: _phoneController,
                        required: true,
                        label: '',
                        onChanged: (String p1) {
                          setState(
                            () {},
                          ); // Actualizar para habilitar/deshabilitar botón
                        },
                      ),

                      const SizedBox(height: 24),

                      // Switch Default
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _isDefault
                              ? Colors.green.withOpacity(0.05)
                              : const Color(0xFFF5F5F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isDefault
                                ? Colors.green
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isDefault
                                    ? Colors.green
                                    : Colors.grey[400],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.star,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Dirección Principal",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _isDefault
                                          ? Colors.green[800]
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "Usar para mis próximos envíos",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _isDefault,
                              activeColor: Colors.green,
                              onChanged: (val) =>
                                  setState(() => _isDefault = val),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40), // Espacio final
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Botón de Guardar
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
              label: isEditing ? 'Actualizar' : 'Guardar Dirección',
              icon: Iconsax.tick_circle,
              fullWidth: true,
              isLoading: _isLoading,
              onPressed: (_isLoading || !_isFormValid()) ? null : _handleSave,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildRequiredLabel(String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.0,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(
              color: MBETheme.brandRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required dynamic value,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey[100] : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          value: value,
          items: items,
          onChanged: isDisabled ? null : onChanged,
          hint: isLoading
              ? Row(
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Cargando...",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                )
              : Text(
                  hint,
                  style: TextStyle(
                    color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
          isExpanded: true,
          icon: Icon(
            Iconsax.arrow_down_1,
            size: 18,
            color: isDisabled ? Colors.grey[300] : Colors.black87,
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope', // O tu fuente
          ),
        ),
      ),
    );
  }
}
