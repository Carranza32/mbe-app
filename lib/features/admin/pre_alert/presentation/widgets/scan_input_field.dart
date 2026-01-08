import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../config/theme/mbe_theme.dart';
import 'context_filter_segmented.dart';

class ScanInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onScanPressed;
  final Function(String)? onSubmitted;
  final bool isLoading;
  final PackageContext? mode; // Modo del scanner según el contexto

  const ScanInputField({
    super.key,
    required this.controller,
    required this.onScanPressed,
    this.onSubmitted,
    this.isLoading = false,
    this.mode,
  });

  String _getModeLabel() {
    switch (mode) {
      case PackageContext.porRecibir:
        return 'Modo Recepción';
      case PackageContext.enBodega:
        return 'Modo Ubicación';
      case PackageContext.paraEntregar:
        return 'Modo Entrega';
      case null:
        return '';
    }
  }

  Color _getAccentColor() {
    switch (mode) {
      case PackageContext.porRecibir:
        return Colors.blue; // Azul para recepción
      case PackageContext.enBodega:
        return Colors.amber; // Amarillo para ubicación
      case PackageContext.paraEntregar:
        return Colors.green; // Verde para entrega
      case null:
        return MBETheme.brandBlack;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pill indicadora del modo (centrada horizontalmente arriba del input)
        // if (mode != null)
        //   Center(
        //     child: Container(
        //       margin: const EdgeInsets.only(bottom: 8),
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //       decoration: BoxDecoration(
        //         color: _getAccentColor().withOpacity(0.15),
        //         borderRadius: BorderRadius.circular(12),
        //         border: Border.all(
        //           color: _getAccentColor().withOpacity(0.4),
        //           width: 1,
        //         ),
        //       ),
        //       child: Text(
        //         _getModeLabel(),
        //         style: TextStyle(
        //           color: _getAccentColor(),
        //           fontSize: 11,
        //           fontWeight: FontWeight.w600,
        //           letterSpacing: 0.5,
        //         ),
        //       ),
        //     ),
        //   ),
        // Input flotante estilo "Floating Pill"
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white, // Blanco puro
            borderRadius: BorderRadius.circular(28), // Pill shape
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Iconsax.keyboard, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onSubmitted: onSubmitted,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ingresar código manual...',
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              // Botón de acción dentro del input
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          if (controller.text.isNotEmpty &&
                              onSubmitted != null) {
                            onSubmitted!(controller.text);
                          } else if (!isLoading) {
                            onScanPressed();
                          }
                        },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getAccentColor(),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_rounded,
                            color: _getAccentColor(),
                            size: 24,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
