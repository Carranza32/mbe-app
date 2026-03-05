import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../core/design_system/ds_inputs.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../profile/data/models/address_model.dart';
import '../../../../profile/presentation/widgets/address_form_modal.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/customer_address_model.dart';
import '../../data/models/customer_detail_model.dart';
import '../../data/models/pre_alert_detail_response.dart';
import '../../data/repositories/admin_pre_alerts_repository.dart';
import '../../data/models/boxful_locker_model.dart';
import '../../data/models/boxful_state_model.dart';

/// Modal "Completar información" para paquetes en Disponibles.
/// Define método de entrega (domicilio/casillero), dirección o locker, y contacto.
/// Al guardar, el backend transiciona a solicitud_recoleccion si aplica.
/// [asPage]: si true, se muestra como pantalla completa (sin barra de arrastre, con flecha atrás).
class CompleteDeliveryInfoModal extends ConsumerStatefulWidget {
  final AdminPreAlert package;
  /// Si true, se usa como pantalla push (sin handle, con back)
  final bool asPage;

  const CompleteDeliveryInfoModal({
    super.key,
    required this.package,
    this.asPage = false,
  });

  @override
  ConsumerState<CompleteDeliveryInfoModal> createState() =>
      _CompleteDeliveryInfoModalState();
}

class _CompleteDeliveryInfoModalState
    extends ConsumerState<CompleteDeliveryInfoModal> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  PreAlertDetailResponse? _detail;
  /// Cliente cargado por by-locker-code al abrir (prioritario sobre detail.customer)
  CustomerDetail? _customerFromLockerCode;
  String _deliveryMethod = 'delivery'; // 'delivery' | 'locker' (sin pickup)
  int? _selectedAddressId;
  String _boxfulLockerId = '';
  String? _selectedBoxfulStateId;
  String? _selectedBoxfulCityId;
  List<BoxfulState> _boxfulStates = [];
  List<BoxfulLocker> _boxfulLockers = [];
  bool _loadingStates = false;
  bool _loadingLockers = false;
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactNotesController = TextEditingController();

  CustomerDetail get _customer {
    if (_customerFromLockerCode != null) return _customerFromLockerCode!;
    if (_detail?.customer != null && _detail!.customer.name != 'N/A') return _detail!.customer;
    // Fallback: datos del paquete de la lista o del detalle
    final pkg = _detail?.package ?? widget.package;
    return CustomerDetail(
      id: _detail?.customer.id ?? 0,
      name: pkg.clientName.isNotEmpty ? pkg.clientName : 'N/A',
      email: _detail?.customer.email ?? pkg.contactEmail,
      phone: _detail?.customer.phone ?? pkg.contactPhone,
      lockerCode: _detail?.customer.lockerCode ?? pkg.lockerCode,
      addresses: _detail?.customer.addresses ?? [],
    );
  }
  List<CustomerAddress> get _addresses => _customer.addresses;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _customerFromLockerCode = null;
    });
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      PreAlertDetailResponse? detail;
      try {
        detail = await repository.getPreAlertDetailById(widget.package.id);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
        return;
      }
      if (!mounted) return;

      // Código para by-locker-code: prioridad detalle (customer/package) y luego el paquete de la lista
      final codeFromDetail = detail.customer.lockerCode?.trim().isNotEmpty == true
          ? detail.customer.lockerCode!
          : (detail.package.lockerCode?.trim().isNotEmpty == true
              ? detail.package.lockerCode!
              : (detail.package.eboxCode.trim().isNotEmpty ? detail.package.eboxCode : null));
      final code = codeFromDetail ??
          ((widget.package.lockerCode?.trim().isNotEmpty ?? false)
              ? widget.package.lockerCode!
              : (widget.package.eboxCode.trim().isNotEmpty ? widget.package.eboxCode : null));

      CustomerDetail? customerFromApi;
      if (code != null && code.isNotEmpty) {
        try {
          customerFromApi = await repository.getCustomerByLockerCode(code);
        } catch (_) {
          // Si falla by-locker-code, se usa el cliente del detalle
        }
        if (!mounted) return;
      }

      final customer = customerFromApi ?? detail.customer;
      final pkg = detail.package;
      final nameForContact = customer.name.isNotEmpty && customer.name != 'N/A'
          ? customer.name
          : (pkg.clientName.isNotEmpty ? pkg.clientName : '');
      final emailForContact = (customer.email ?? '').isNotEmpty ? customer.email! : (pkg.contactEmail ?? '');
      final phoneForContact = (customer.phone ?? '').isNotEmpty ? customer.phone! : (pkg.contactPhone ?? '');
      final detailFinal = detail;
      setState(() {
        _detail = detailFinal;
        _customerFromLockerCode = customerFromApi;
        _isLoading = false;
        final method = pkg.deliveryMethod ?? 'delivery';
        _deliveryMethod = method == 'pickup' ? 'delivery' : method;
        _selectedAddressId = detailFinal.package.customerAddressId ??
            customer.defaultAddress?.id;
        _contactNameController.text = detailFinal.package.contactName ?? nameForContact;
        _contactEmailController.text = detailFinal.package.contactEmail ?? emailForContact;
        _contactPhoneController.text = detailFinal.package.contactPhone ?? phoneForContact;
        _contactNotesController.text = detailFinal.package.contactNotes ?? '';
        if (_contactNameController.text.isEmpty && nameForContact.isNotEmpty) {
          _contactNameController.text = nameForContact;
        }
        if (_contactEmailController.text.isEmpty && emailForContact.isNotEmpty) {
          _contactEmailController.text = emailForContact;
        }
        if (_contactPhoneController.text.isEmpty && phoneForContact.isNotEmpty) {
          _contactPhoneController.text = phoneForContact;
        }
      });
      if (_deliveryMethod == 'locker') _loadBoxfulStates();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
      });
    }
  }

  /// Carga departamentos (Boxful states) y opcionalmente preselecciona desde la dirección por defecto.
  Future<void> _loadBoxfulStates() async {
    setState(() => _loadingStates = true);
    try {
      final repo = ref.read(adminPreAlertsRepositoryProvider);
      final list = await repo.getBoxfulStates();
      if (!mounted) return;
      final defaultAddr = _addresses.isNotEmpty ? _addresses.first : null;
      final presetStateId = defaultAddr?.boxfulStateId?.trim().isNotEmpty == true
          ? defaultAddr!.boxfulStateId
          : null;
      final presetCityId = defaultAddr?.boxfulCityId?.trim().isNotEmpty == true
          ? defaultAddr!.boxfulCityId
          : null;
      setState(() {
        _boxfulStates = list;
        _loadingStates = false;
        if (presetStateId != null) _selectedBoxfulStateId = presetStateId;
        if (presetCityId != null) _selectedBoxfulCityId = presetCityId;
        _boxfulLockers = [];
        _boxfulLockerId = '';
      });
      if (_selectedBoxfulCityId != null && _selectedBoxfulCityId!.trim().isNotEmpty) {
        _loadLockers(_selectedBoxfulCityId!);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _boxfulStates = [];
        _loadingStates = false;
      });
    }
  }

  List<BoxfulCity> get _citiesForSelectedState {
    if (_selectedBoxfulStateId == null || _selectedBoxfulStateId!.isEmpty) return [];
    try {
      final state = _boxfulStates.firstWhere((s) => s.id == _selectedBoxfulStateId);
      return state.cities;
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadLockers(String cityId) async {
    if (cityId.trim().isEmpty) {
      setState(() => _boxfulLockers = []);
      return;
    }
    setState(() {
      _loadingLockers = true;
      _boxfulLockers = [];
      _boxfulLockerId = '';
    });
    try {
      final repository = ref.read(adminPreAlertsRepositoryProvider);
      final list = await repository.getBoxfulLockers(cityId);
      if (!mounted) return;
      setState(() {
        _boxfulLockers = list;
        _loadingLockers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _boxfulLockers = [];
        _loadingLockers = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _detail == null) return;

    final contactName = _contactNameController.text.trim();
    final contactEmail = _contactEmailController.text.trim();

    if (contactName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre de contacto es obligatorio'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }
    if (contactEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El email de contacto es obligatorio'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }
    if (_deliveryMethod == 'delivery' && _selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una dirección para envío a domicilio'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }
    if (_deliveryMethod == 'locker' && _boxfulLockerId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona departamento, ciudad y casillero'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updates = <String, dynamic>{
        'delivery_method': _deliveryMethod,
        'contact_name': contactName,
        'contact_email': contactEmail,
        'contact_phone': _contactPhoneController.text.trim().isEmpty
            ? null
            : _contactPhoneController.text.trim(),
        'contact_notes': _contactNotesController.text.trim().isEmpty
            ? null
            : _contactNotesController.text.trim(),
      };

      if (_deliveryMethod == 'delivery') {
        updates['customer_address_id'] = _selectedAddressId;
        updates['boxful_locker_id'] = null;
      } else {
        updates['customer_address_id'] = null;
        updates['boxful_locker_id'] = _boxfulLockerId.trim();
      }

      final repository = ref.read(adminPreAlertsRepositoryProvider);
      await repository.updatePackage(
        id: widget.package.id,
        updates: updates,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Información guardada. El paquete pasará a "Para Entregar".'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPage = widget.asPage;
    final padding = MediaQuery.paddingOf(context);
    final fullHeight = MediaQuery.sizeOf(context).height - padding.top - padding.bottom;
    return Container(
      height: isPage ? fullHeight : MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isPage ? null : const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          if (!isPage) const SizedBox(height: 12),
          if (!isPage)
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
                Row(
                  children: [
                    if (isPage)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completar información',
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
                  ],
                ),
                if (!isPage)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Iconsax.close_circle, color: Colors.black, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _detail == null) {
      return Center(
        child: _loadError != null
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.danger, size: 48, color: MBETheme.brandRed),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    DSButton.primary(
                      label: 'Reintentar',
                      onPressed: _loadDetail,
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: MBESpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // —— CLIENTE ——
            _buildSectionHeader(
              title: 'Cliente',
              icon: Iconsax.user,
            ),
            const SizedBox(height: MBESpacing.sm),
            _buildClientCard(),
            const SizedBox(height: MBESpacing.xl),

            // —— MÉTODO DE ENTREGA ——
            _buildSectionHeader(
              title: 'Método de entrega',
              icon: Iconsax.truck,
            ),
            const SizedBox(height: MBESpacing.sm),
            _buildDeliveryMethodCard(),
            const SizedBox(height: MBESpacing.lg),

            if (_deliveryMethod == 'delivery') _buildAddressesCard(),
            if (_deliveryMethod == 'locker') _buildLockerCard(),
            if (_deliveryMethod == 'delivery' || _deliveryMethod == 'locker')
              const SizedBox(height: MBESpacing.xl),

            // —— CONTACTO ——
            _buildSectionHeader(
              title: 'Datos de contacto',
              icon: Iconsax.call_calling,
              subtitle: 'Completa o corrige los datos para la entrega',
            ),
            const SizedBox(height: MBESpacing.sm),
            _buildContactCard(),
            const SizedBox(height: MBESpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: MBETheme.brandBlack.withOpacity(0.08),
            borderRadius: BorderRadius.circular(MBERadius.medium),
          ),
          child: Icon(icon, color: MBETheme.brandBlack, size: 22),
        ),
        const SizedBox(width: MBESpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MBETheme.neutralGray,
                  letterSpacing: 0.8,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: MBETheme.neutralGray.withOpacity(0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard() {
    final initial = _customer.name.isNotEmpty
        ? _customer.name.trim().substring(0, 1).toUpperCase()
        : '?';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: MBETheme.brandRed.withOpacity(0.12),
            child: Text(
              initial,
              style: const TextStyle(
                color: MBETheme.brandRed,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: MBESpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _customer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: MBETheme.brandBlack,
                  ),
                ),
                if (_customer.email != null && _customer.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Iconsax.sms, size: 14, color: MBETheme.neutralGray),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _customer.email!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: MBETheme.neutralGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_customer.lockerCode != null && _customer.lockerCode!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Iconsax.box, size: 14, color: MBETheme.neutralGray),
                      const SizedBox(width: 6),
                      Text(
                        'Código: ${_customer.lockerCode}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: MBETheme.neutralGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryMethodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: SegmentedButton<String>(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(MBERadius.medium))),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return MBETheme.brandRed;
            return MBETheme.lightGray;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return MBETheme.neutralGray;
          }),
        ),
        segments: const [
          ButtonSegment(
            value: 'delivery',
            label: Text('Domicilio'),
            icon: Icon(Iconsax.home_2, size: 20),
          ),
          ButtonSegment(
            value: 'locker',
            label: Text('Casillero'),
            icon: Icon(Iconsax.box, size: 20),
          ),
        ],
        selected: {_deliveryMethod},
        onSelectionChanged: (Set<String> selected) {
          final newMethod = selected.first;
          setState(() {
            _deliveryMethod = newMethod;
            if (newMethod == 'locker') _loadBoxfulStates();
          });
        },
      ),
    );
  }

  AddressModel _customerAddressToAddressModel(CustomerAddress a) {
    return AddressModel(
      id: a.id,
      name: a.name ?? 'Dirección',
      countryCode: a.countryCode ?? 'SV',
      country: a.country ?? 'SV',
      regionCode: a.regionCode ?? '',
      region: a.region ?? '',
      cityCode: a.cityCode ?? '',
      city: a.city ?? '',
      address: a.address,
      phone: a.phone ?? '',
      isDefault: a.isDefault,
      localityCode: a.localityCode,
      locality: a.locality,
      references: a.references,
    );
  }

  void _showAddressFormModal({CustomerAddress? address}) {
    final customerId = _customer.id;
    if (customerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede crear dirección: cliente no identificado'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormModal(
        address: address != null ? _customerAddressToAddressModel(address) : null,
        onSave: (AddressModel savedAddress) async {
          try {
            final repo = ref.read(adminPreAlertsRepositoryProvider);
            CustomerAddress created;
            if (savedAddress.id == 0) {
              created = await repo.createCustomerAddress(customerId, savedAddress);
            } else {
              created = await repo.updateCustomerAddress(
                customerId,
                savedAddress.id,
                savedAddress,
              );
            }
            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();
            await _loadDetail();
            if (!mounted) return;
            setState(() => _selectedAddressId = created.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dirección "${savedAddress.name}" guardada'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!ctx.mounted) return;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text('Error al guardar: $e'),
                backgroundColor: MBETheme.brandRed,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAddressesCard() {
    if (_addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MBESpacing.lg),
        decoration: BoxDecoration(
          color: MBETheme.lightGray.withOpacity(0.8),
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(color: MBETheme.neutralGray.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.info_circle, color: MBETheme.neutralGray, size: 22),
                const SizedBox(width: MBESpacing.md),
                Expanded(
                  child: Text(
                    'Este cliente no tiene direcciones registradas.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MBETheme.neutralGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MBESpacing.md),
            DSButton.secondary(
              label: 'Agregar dirección',
              icon: Iconsax.add,
              onPressed: () => _showAddressFormModal(),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Selecciona una dirección',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: MBETheme.neutralGray,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: TextButton.icon(
                  onPressed: () => _showAddressFormModal(),
                  icon: const Icon(Iconsax.add, size: 18),
                  label: Text(
                    'Nueva dirección',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: MBETheme.brandRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MBESpacing.md),
          ..._addresses.map((a) {
            final selected = _selectedAddressId == a.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: MBESpacing.sm),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedAddressId = a.id),
                  borderRadius: BorderRadius.circular(MBERadius.medium),
                  child: Container(
                    padding: const EdgeInsets.all(MBESpacing.md),
                    decoration: BoxDecoration(
                      color: selected
                          ? MBETheme.brandRed.withOpacity(0.08)
                          : MBETheme.lightGray.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(MBERadius.medium),
                      border: Border.all(
                        color: selected
                            ? MBETheme.brandRed.withOpacity(0.4)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: a.id,
                          groupValue: _selectedAddressId,
                          onChanged: (v) => setState(() => _selectedAddressId = v),
                          activeColor: MBETheme.brandRed,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (a.name != null && a.name!.isNotEmpty)
                                Text(
                                  a.name!,
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: MBETheme.brandRed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (a.name != null && a.name!.isNotEmpty) const SizedBox(height: 2),
                              Text(
                                a.address,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: MBETheme.brandBlack,
                                ),
                              ),
                              if (a.city != null || a.region != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  [a.city, a.region].whereType<String>().join(', '),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: MBETheme.neutralGray,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.edit_2, size: 20),
                          onPressed: () => _showAddressFormModal(address: a),
                          color: MBETheme.neutralGray,
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLockerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStyledDropdown<String>(
            label: 'Departamento',
            hint: 'Selecciona departamento',
            value: _selectedBoxfulStateId?.trim().isNotEmpty == true ? _selectedBoxfulStateId : null,
            items: _boxfulStates.map((s) => _DropdownItem(s.id, s.name)).toList(),
            onChanged: _loadingStates
                ? null
                : (v) {
                    setState(() {
                      _selectedBoxfulStateId = v;
                      _selectedBoxfulCityId = null;
                      _boxfulLockers = [];
                      _boxfulLockerId = '';
                    });
                  },
            suffix: _loadingStates
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(height: MBESpacing.lg),
          _buildStyledDropdown<String>(
            label: 'Ciudad',
            hint: 'Selecciona ciudad',
            value: _selectedBoxfulCityId?.trim().isNotEmpty == true ? _selectedBoxfulCityId : null,
            items: _citiesForSelectedState.map((c) => _DropdownItem(c.id, c.name)).toList(),
            onChanged: _selectedBoxfulStateId == null || _selectedBoxfulStateId!.isEmpty
                ? null
                : (v) {
                    setState(() => _selectedBoxfulCityId = v);
                    if (v != null && v.trim().isNotEmpty) _loadLockers(v);
                  },
          ),
          const SizedBox(height: MBESpacing.lg),
          _buildStyledDropdown<String>(
            label: 'Casillero',
            hint: _selectedBoxfulCityId == null
                ? 'Selecciona primero departamento y ciudad'
                : (_loadingLockers
                    ? 'Cargando casilleros...'
                    : 'Selecciona casillero'),
            value: _boxfulLockerId.isEmpty ? null : _boxfulLockerId,
            items: _boxfulLockers
                .map((l) => _DropdownItem(l.id, l.name))
                .toList(),
            onChanged: _loadingLockers
                ? null
                : (v) => setState(() => _boxfulLockerId = v ?? ''),
            suffix: _loadingLockers
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<_DropdownItem<T>> items,
    required void Function(T?)? onChanged,
    Widget? suffix,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: MBESpacing.sm),
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: MBETheme.brandBlack,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(MBERadius.large),
            border: Border.all(
              color: MBETheme.neutralGray.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: MBETheme.shadowSm,
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            isExpanded: true,
            hint: Text(
              hint,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MBESpacing.lg,
                vertical: MBESpacing.lg,
              ),
              suffixIcon: suffix,
            ),
            items: items
                .map((item) => DropdownMenuItem<T>(
                      value: item.value,
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            dropdownColor: colorScheme.surface,
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MBESpacing.lg),
      decoration: MBECardDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSInput.text(
            label: 'Nombre de contacto',
            hint: 'Nombre de quien recibe',
            controller: _contactNameController,
            onChanged: (_) {},
            prefixIcon: Iconsax.user,
          ),
          const SizedBox(height: MBESpacing.lg),
          DSInput.email(
            label: 'Email de contacto',
            controller: _contactEmailController,
            onChanged: (_) {},
          ),
          const SizedBox(height: MBESpacing.lg),
          DSInput.phone(
            label: 'Teléfono de contacto',
            controller: _contactPhoneController,
            onChanged: (_) {},
          ),
          const SizedBox(height: MBESpacing.lg),
          DSInput.textArea(
            label: 'Notas adicionales',
            hint: 'Alguna instrucción especial para la entrega...',
            controller: _contactNotesController,
            onChanged: (_) {},
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(MBESpacing.xl, MBESpacing.lg, MBESpacing.xl, MBESpacing.lg + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: MBETheme.shadowTop,
      ),
      child: SafeArea(
        top: false,
        child: DSButton.primary(
          label: _isSaving ? 'Guardando...' : 'Guardar y solicitar recolección',
          fullWidth: true,
          icon: Iconsax.tick_circle,
          onPressed: (_isSaving || _detail == null) ? null : _save,
        ),
      ),
    );
  }
}

class _DropdownItem<T> {
  final T value;
  final String label;
  _DropdownItem(this.value, this.label);
}
