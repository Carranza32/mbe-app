import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class PreAlertScreen extends StatelessWidget {
  const PreAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar personalizado
        Container(
          color: Colors.white,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Pre-alertar Compra',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        
        // Contenido
        Expanded(
          child: Container(
            color: AppColors.backgroundLight,
            child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.blueGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.info_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Notifícanos tu compra antes de que llegue a Miami',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Información de la tienda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _InputField(
              label: 'Nombre de la tienda',
              hint: 'Ej: Amazon, eBay, Shein',
              icon: Iconsax.shop,
            ),
            const SizedBox(height: 16),

            _InputField(
              label: 'Número de tracking',
              hint: 'Ej: 1Z999AA10123456784',
              icon: Iconsax.scan_barcode,
            ),

            const SizedBox(height: 32),

            const Text(
              'Detalles del paquete',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _InputField(
              label: 'Descripción del contenido',
              hint: 'Ej: Ropa, electrónicos, juguetes',
              icon: Iconsax.note_text,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Valor (USD)',
                    hint: '\$0.00',
                    icon: Iconsax.dollar_circle,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InputField(
                    label: 'Peso (lbs)',
                    hint: '0.0',
                    icon: Iconsax.weight,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'Pre-alertar Paquete',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paquete pre-alertado exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Pre-alertas recientes
            const Text(
              'Pre-alertas Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _PreAlertCard(
              store: 'Amazon',
              tracking: 'TK123456789',
              status: 'Pendiente',
              date: '15 Oct 2024',
            ),
            const SizedBox(height: 12),
            _PreAlertCard(
              store: 'Shein',
              tracking: 'TK987654321',
              status: 'Recibido',
              date: '14 Oct 2024',
            ),
          ],
        ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _InputField({
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.divider,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreAlertCard extends StatelessWidget {
  final String store;
  final String tracking;
  final String status;
  final String date;

  const _PreAlertCard({
    required this.store,
    required this.tracking,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pendiente';
    final statusColor = isPending ? AppColors.warning : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.shop,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tracking,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
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
}