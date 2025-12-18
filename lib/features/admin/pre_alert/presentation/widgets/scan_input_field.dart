import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_inputs.dart';
import '../../../../../config/theme/mbe_theme.dart';

class ScanInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onScanPressed;
  final Function(String)? onSubmitted;
  final bool isLoading;

  const ScanInputField({
    super.key,
    required this.controller,
    required this.onScanPressed,
    this.onSubmitted,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DSInput.text(
            label: 'Escanea código',
            hint: 'Ingresa o escanea el código del paquete',
            controller: controller,
            onChanged: (_) {},
            prefixIcon: Iconsax.scan_barcode,
            suffixIcon: Iconsax.scan,
            onSuffixTap: onScanPressed,
            keyboardType: TextInputType.text,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: MBETheme.brandBlack,
            borderRadius: BorderRadius.circular(12),
            boxShadow: MBETheme.shadowMd,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onScanPressed,
              borderRadius: BorderRadius.circular(12),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : const Icon(
                      Iconsax.scan_barcode,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

