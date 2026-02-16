import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../../../../l10n/app_localizations.dart';

/// Mismo enfoque que ReceptionScanScreen: MobileScanner sin permission_handler.
/// El plugin mobile_scanner gestiona el permiso de cámara al iniciar.
class LockerRetrievalScanModal extends StatefulWidget {
  final void Function(String token) onTokenScanned;

  const LockerRetrievalScanModal({
    super.key,
    required this.onTokenScanned,
  });

  @override
  State<LockerRetrievalScanModal> createState() =>
      _LockerRetrievalScanModalState();
}

class _LockerRetrievalScanModalState extends State<LockerRetrievalScanModal> {
  late MobileScannerController _scannerController;
  final TextEditingController _tokenController = TextEditingController();
  bool _isFlashOn = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _handleScan(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.trim().isNotEmpty) {
        _submitToken(barcode.rawValue!.trim());
        break;
      }
    }
  }

  void _submitToken(String value) {
    if (_isProcessing || value.isEmpty) return;
    setState(() => _isProcessing = true);
    widget.onTokenScanned(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Iconsax.close_circle),
                  color: MBETheme.brandBlack,
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.adminScanQRPasteToken,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          // Zona de cámara (igual que recepción: MobileScanner directo, sin permission_handler)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _scannerController,
                      onDetect: _handleScan,
                    ),
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          _scannerController.toggleTorch();
                          setState(() => _isFlashOn = !_isFlashOn);
                        },
                        icon: Icon(
                          _isFlashOn ? Iconsax.flash_1 : Iconsax.flash_slash,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Input manual
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              decoration: BoxDecoration(
                color: MBETheme.lightGray,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _tokenController,
                decoration: InputDecoration(
                  hintText: 'Pegar token o URL del correo',
                  prefixIcon: const Icon(
                    Iconsax.link,
                    color: MBETheme.brandBlack,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 14,
                  ),
                ),
                onSubmitted: _submitToken,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () {
                        final v = _tokenController.text.trim();
                        if (v.isNotEmpty) _submitToken(v);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MBETheme.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isProcessing ? AppLocalizations.of(context)!.adminSearching : AppLocalizations.of(context)!.adminContinue),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
