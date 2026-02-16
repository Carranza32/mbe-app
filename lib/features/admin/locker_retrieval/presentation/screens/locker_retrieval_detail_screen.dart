import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/api_exception.dart';
import '../../data/models/locker_retrieval_model.dart';
import '../../providers/locker_retrieval_provider.dart';

class LockerRetrievalDetailScreen extends ConsumerStatefulWidget {
  final LockerRetrievalDetail detail;
  final String token;

  const LockerRetrievalDetailScreen({
    super.key,
    required this.detail,
    required this.token,
  });

  @override
  ConsumerState<LockerRetrievalDetailScreen> createState() =>
      _LockerRetrievalDetailScreenState();
}

class _LockerRetrievalDetailScreenState
    extends ConsumerState<LockerRetrievalDetailScreen> {
  final _pinController = TextEditingController();
  bool _isDelivering = false;
  String? _pinError;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _deliver() async {
    final pin = _pinController.text.trim();
    if (pin.length != 6) {
      setState(() => _pinError = 'Ingresa los 6 dígitos del PIN');
      return;
    }
    setState(() {
      _pinError = null;
      _isDelivering = true;
    });
    try {
      final repo = ref.read(lockerRetrievalRepositoryProvider);
      await repo.deliver(token: widget.token, pin: pin);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.adminDeliveryRegistered),
          backgroundColor: MBETheme.brandRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _pinError = e.message;
          _isDelivering = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pinError = AppLocalizations.of(context)!.adminDeliveryRegisterError;
          _isDelivering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MBETheme.brandBlack,
      ),
      decoration: BoxDecoration(
        color: MBETheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MBETheme.neutralGray.withOpacity(0.3)),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: MBETheme.brandRed, width: 2),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: MBETheme.brandRed),
      ),
    );

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.adminPickupDetail,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: MBETheme.brandBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card resumen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: MBETheme.shadowMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: MBETheme.brandRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Iconsax.box_1,
                          color: MBETheme.brandRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.storeName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: MBETheme.brandBlack,
                              ),
                            ),
                            Text(
                              'Casillero ${d.physicalLockerCode}',
                              style: TextStyle(
                                fontSize: 14,
                                color: MBETheme.neutralGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Cliente',
                    value: d.customerNameMasked,
                  ),
                  _DetailRow(
                    label: AppLocalizations.of(context)!.adminType,
                    value: d.typeLabel,
                  ),
                  _DetailRow(
                    label: 'Piezas',
                    value: '${d.pieceCount}',
                  ),
                  if (d.pinExpiresAt != null)
                    _DetailRow(
                      label: AppLocalizations.of(context)!.adminPinExpires,
                      value: _formatDate(d.pinExpiresAt!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // PIN
            const Text(
              'PIN del cliente (6 dígitos)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MBETheme.brandBlack,
              ),
            ),
            const SizedBox(height: 12),
            Pinput(
              controller: _pinController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onCompleted: (pin) {
                if (pin.length == 6) _deliver();
              },
            ),
            if (_pinError != null) ...[
              const SizedBox(height: 8),
              Text(
                _pinError!,
                style: const TextStyle(
                  color: MBETheme.brandRed,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 28),

            DSButton.primary(
              label: _isDelivering ? AppLocalizations.of(context)!.adminDelivering : AppLocalizations.of(context)!.adminDeliver,
              onPressed: _isDelivering ? null : _deliver,
              isLoading: _isDelivering,
              fullWidth: true,
              icon: Iconsax.tick_circle,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: MBETheme.neutralGray,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: MBETheme.brandBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
