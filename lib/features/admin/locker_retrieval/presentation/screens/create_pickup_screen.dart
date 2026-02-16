import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../core/network/api_exception.dart';
import '../../data/models/admin_store_model.dart';
import '../../data/models/locker_retrieval_model.dart';
import '../../providers/locker_retrieval_provider.dart';

class CreatePickupScreen extends ConsumerStatefulWidget {
  final List<AdminStoreModel> stores;
  final AdminStoreModel? initialStore;

  const CreatePickupScreen({
    super.key,
    required this.stores,
    this.initialStore,
  });

  @override
  ConsumerState<CreatePickupScreen> createState() => _CreatePickupScreenState();
}

class _CreatePickupScreenState extends ConsumerState<CreatePickupScreen> {
  AdminStoreModel? _store;
  PhysicalLockerModel? _physicalLocker;
  LockerAccountModel? _lockerAccount;
  String _type = 'package';
  final _notesController = TextEditingController();
  final _pieceCountController = TextEditingController(text: '1');

  List<PhysicalLockerModel> _lockers = [];
  List<LockerAccountModel> _accounts = [];
  bool _loadingLockers = false;
  bool _loadingAccounts = false;
  bool _submitting = false;
  String? _lockersError;
  String? _accountsError;

  @override
  void initState() {
    super.initState();
    _store =
        widget.initialStore ??
        (widget.stores.isNotEmpty ? widget.stores.first : null);
    if (_store != null) _loadLockersAndAccounts(_store!.id);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _pieceCountController.dispose();
    super.dispose();
  }

  Future<void> _loadLockersAndAccounts(int storeId) async {
    setState(() {
      _loadingLockers = true;
      _loadingAccounts = true;
      _lockersError = null;
      _accountsError = null;
      _physicalLocker = null;
      _lockerAccount = null;
      _lockers = [];
      _accounts = [];
    });
    final repo = ref.read(lockerRetrievalRepositoryProvider);
    try {
      final lockers = await repo.getPhysicalLockers(storeId);
      if (mounted) {
        setState(() {
          _lockers = lockers;
          _loadingLockers = false;
          _physicalLocker = lockers.isNotEmpty ? lockers.first : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lockersError = e is ApiException
              ? e.message
              : 'Error al cargar casilleros';
          _loadingLockers = false;
        });
      }
    }
    try {
      final accounts = await repo.getLockerAccounts(storeId: storeId);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          _loadingAccounts = false;
          _lockerAccount = accounts.isNotEmpty ? accounts.first : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _accountsError = e is ApiException
              ? e.message
              : AppLocalizations.of(context)!.adminErrorLoadingAccounts;
          _loadingAccounts = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_store == null || _physicalLocker == null || _lockerAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminCompleteStoreLockerAccount),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final pieceCount = int.tryParse(_pieceCountController.text.trim()) ?? 1;
    if (pieceCount < 1 || pieceCount > 99) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Piezas debe ser entre 1 y 99'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final repo = ref.read(lockerRetrievalRepositoryProvider);
      await repo.createPickup(
        storeId: _store!.id,
        physicalLockerId: _physicalLocker!.id,
        lockerAccountId: _lockerAccount!.id,
        type: _type,
        pieceCount: pieceCount,
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Iconsax.tick_circle, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Retiro creado. Se envió el PIN por email al cliente.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: MBETheme.brandRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stores.isEmpty) {
      return Scaffold(
        backgroundColor: MBETheme.lightGray,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Crear retiro',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: MBETheme.brandBlack,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(child: Text(AppLocalizations.of(context)!.adminNoStoresAvailable)),
      );
    }

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Crear retiro',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionLabel(AppLocalizations.of(context)!.preAlertStoreLabel),
            const SizedBox(height: 8),
            DropdownButtonFormField<AdminStoreModel>(
              value: _store,
              isExpanded: true,
              decoration: _inputDecoration(),
              items: widget.stores
                  .map(
                    (s) => DropdownMenuItem<AdminStoreModel>(
                      value: s,
                      child: Text(
                        s.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _store = v);
                _loadLockersAndAccounts(v.id);
              },
            ),
            const SizedBox(height: 20),

            _sectionLabel('Casillero físico'),
            const SizedBox(height: 8),
            _loadingLockers
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _lockersError != null
                ? Text(
                    _lockersError!,
                    style: const TextStyle(
                      color: MBETheme.brandRed,
                      fontSize: 13,
                    ),
                  )
                : DropdownButtonFormField<PhysicalLockerModel>(
                    value: _physicalLocker,
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: _lockers
                        .map(
                          (l) => DropdownMenuItem<PhysicalLockerModel>(
                            value: l,
                            child: Text(
                              l.code,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _physicalLocker = v),
                  ),
            const SizedBox(height: 20),

            _sectionLabel(AppLocalizations.of(context)!.adminLockerAccount),
            const SizedBox(height: 8),
            _loadingAccounts
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _accountsError != null
                ? Text(
                    _accountsError!,
                    style: const TextStyle(
                      color: MBETheme.brandRed,
                      fontSize: 13,
                    ),
                  )
                : DropdownButtonFormField<LockerAccountModel>(
                    value: _lockerAccount,
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: _accounts
                        .map(
                          (a) => DropdownMenuItem<LockerAccountModel>(
                            value: a,
                            child: Text(
                              '${a.code} - ${a.customerName}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _lockerAccount = v),
                  ),
            const SizedBox(height: 20),

            _sectionLabel(AppLocalizations.of(context)!.adminType),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  decoration: BoxDecoration(
                    color: MBETheme.lightGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: MBETheme.neutralGray.withOpacity(0.4),
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'package',
                          label: Text('Paquete'),
                          icon: Icon(Iconsax.box_1, size: 18),
                        ),
                        ButtonSegment(
                          value: 'correspondence',
                          label: Text('Correspondencia'),
                          icon: Icon(Iconsax.document, size: 18),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) => setState(() => _type = s.first),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected))
                            return MBETheme.brandRed;
                          return Colors.white;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected))
                            return Colors.white;
                          return MBETheme.brandBlack;
                        }),
                        side: WidgetStateProperty.all(
                          BorderSide(color: MBETheme.neutralGray.withOpacity(0.25)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            _sectionLabel('Cantidad de piezas (1-99)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pieceCountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
                _PieceCountFormatter(),
              ],
              decoration: _inputDecoration(hint: '1'),
            ),
            const SizedBox(height: 20),

            _sectionLabel('Notas (opcional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              maxLength: 500,
              decoration: _inputDecoration(hint: 'Máx. 500 caracteres'),
            ),
            const SizedBox(height: 28),

            DSButton.primary(
              label: _submitting ? AppLocalizations.of(context)!.adminCreating : AppLocalizations.of(context)!.adminCreatePickup,
              onPressed: _submitting ? null : _submit,
              isLoading: _submitting,
              fullWidth: true,
              icon: Iconsax.add_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: MBETheme.neutralGray,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    const borderRadius = BorderRadius.all(Radius.circular(12));
    final borderColor = MBETheme.neutralGray.withOpacity(0.4);
    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: borderColor, width: 1.2),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: MBETheme.neutralGray.withOpacity(0.8)),
      filled: true,
      fillColor: MBETheme.lightGray,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: MBETheme.brandRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      border: border,
    );
  }
}

class _PieceCountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final n = int.tryParse(newValue.text);
    if (n == null || n < 1) return oldValue;
    if (n > 99)
      return TextEditingValue(
        text: '99',
        selection: const TextSelection.collapsed(offset: 2),
      );
    return newValue;
  }
}
