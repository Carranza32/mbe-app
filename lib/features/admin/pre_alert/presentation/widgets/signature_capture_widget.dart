import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:signature/signature.dart';
import '../../../../../config/theme/mbe_theme.dart';

class SignatureCaptureWidget extends StatefulWidget {
  const SignatureCaptureWidget({
    super.key,
  });

  @override
  State<SignatureCaptureWidget> createState() =>
      SignatureCaptureWidgetState();
}

class SignatureCaptureWidgetState extends State<SignatureCaptureWidget> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: MBETheme.brandBlack,
    exportBackgroundColor: Colors.white,
    exportPenColor: MBETheme.brandBlack,
  );

  bool _hasSignature = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSignatureChanged);
  }

  void _onSignatureChanged() {
    setState(() {
      _hasSignature = _controller.points.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSignatureChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Firma del Cliente *',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            if (_hasSignature)
              TextButton.icon(
                onPressed: _clearSignature,
                icon: const Icon(Iconsax.refresh, size: 16),
                label: const Text('Limpiar'),
                style: TextButton.styleFrom(
                  foregroundColor: MBETheme.brandRed,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MBETheme.neutralGray.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
              width: double.infinity,
              height: 200,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Firma en el área de arriba',
          style: TextStyle(
            color: MBETheme.neutralGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _clearSignature() {
    _controller.clear();
    setState(() {
      _hasSignature = false;
    });
  }

  bool get hasSignature => _hasSignature;

  Future<String?> captureSignature() async {
    if (!_hasSignature || _controller.points.isEmpty) return null;

    try {
      final Uint8List? pngBytes = await _controller.toPngBytes();
      if (pngBytes == null) return null;

      // Convertir a base64 usando dart:convert
      final String base64String = base64Encode(pngBytes);
      return base64String;
    } catch (e) {
      return null;
    }
  }
}
