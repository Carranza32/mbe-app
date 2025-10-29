import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

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
                      'Rastrear Paquete',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer para centrar el título
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
            // Buscador
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Ingresa el número de tracking',
                  prefixIcon: const Icon(
                    Iconsax.search_normal,
                    color: AppColors.primary,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.scan_barcode,
                      color: Colors.white,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Paquetes recientes
            const Text(
              'Paquetes Recientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _TrackingCard(
              trackingNumber: 'TK123456789',
              status: 'En tránsito',
              statusColor: AppColors.info,
              date: '15 Oct 2024',
              icon: Iconsax.airplane,
            ),
            const SizedBox(height: 12),
            _TrackingCard(
              trackingNumber: 'TK987654321',
              status: 'En bodega Miami',
              statusColor: AppColors.warning,
              date: '14 Oct 2024',
              icon: Iconsax.home,
            ),
            const SizedBox(height: 12),
            _TrackingCard(
              trackingNumber: 'TK456789123',
              status: 'Entregado',
              statusColor: AppColors.success,
              date: '10 Oct 2024',
              icon: Iconsax.tick_circle,
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

class _TrackingCard extends StatelessWidget {
  final String trackingNumber;
  final String status;
  final Color statusColor;
  final String date;
  final IconData icon;

  const _TrackingCard({
    required this.trackingNumber,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trackingNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}