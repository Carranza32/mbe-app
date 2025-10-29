import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

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
                      'Tus Paquetes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.filter),
                    onPressed: () {},
                  ),
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
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.box,
                    value: '5',
                    label: 'En bodega',
                    gradient: AppColors.blueGradient,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    icon: Iconsax.airplane,
                    value: '2',
                    label: 'En tránsito',
                    gradient: AppColors.dangerGradient,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Paquetes section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Todos los paquetes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.sort, size: 18),
                  label: const Text('Ordenar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _PackageCard(
              packageId: 'PKG-001',
              description: 'Ropa y accesorios',
              store: 'Shein',
              weight: 2.5,
              location: 'Miami Warehouse',
              status: 'En bodega',
              statusColor: AppColors.info,
              date: '15 Oct 2024',
            ),
            const SizedBox(height: 12),
            _PackageCard(
              packageId: 'PKG-002',
              description: 'Electrónicos',
              store: 'Amazon',
              weight: 1.8,
              location: 'En vuelo a El Salvador',
              status: 'En tránsito',
              statusColor: AppColors.warning,
              date: '14 Oct 2024',
            ),
            const SizedBox(height: 12),
            _PackageCard(
              packageId: 'PKG-003',
              description: 'Libros',
              store: 'Book Depository',
              weight: 3.2,
              location: 'Miami Warehouse',
              status: 'En bodega',
              statusColor: AppColors.info,
              date: '13 Oct 2024',
            ),
            const SizedBox(height: 12),
            _PackageCard(
              packageId: 'PKG-004',
              description: 'Zapatos deportivos',
              store: 'Nike',
              weight: 1.5,
              location: 'Oficina San Salvador',
              status: 'Listo para recoger',
              statusColor: AppColors.success,
              date: '12 Oct 2024',
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String packageId;
  final String description;
  final String store;
  final double weight;
  final String location;
  final String status;
  final Color statusColor;
  final String date;

  const _PackageCard({
    required this.packageId,
    required this.description,
    required this.store,
    required this.weight,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.date,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.box5,
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
                      packageId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
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
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Iconsax.shop,
                label: store,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Iconsax.weight,
                label: '$weight lbs',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Iconsax.location,
                size: 16,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
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
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}