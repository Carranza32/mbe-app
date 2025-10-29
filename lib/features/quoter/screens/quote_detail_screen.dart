import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../widgets/service_item.dart';

class QuoteDetailScreen extends StatelessWidget {
  const QuoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Header con gradiente
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // AppBar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Detalle de Cotización',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Código de cliente
                Text(
                  'Tu código de cliente',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'SAL4279XJ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // Contenido principal
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Servicios QuickBox
                          const Text(
                            'Servicios QuickBox',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(16),
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
                            child: const Column(
                              children: [
                                ServiceItem(
                                  title: 'Flete Quickbox',
                                  price: 'US\$8.48',
                                ),
                                SizedBox(height: 12),
                                ServiceItem(
                                  title: 'Gestión aeropuerto',
                                  price: 'US\$4.52',
                                ),
                                SizedBox(height: 12),
                                ServiceItem(
                                  title: 'Cobro administrativo cuenta ajena',
                                  price: 'US\$0.12',
                                ),
                                SizedBox(height: 12),
                                ServiceItem(
                                  title: 'Retta',
                                  price: 'US\$0.68',
                                ),
                                SizedBox(height: 16),
                                Divider(),
                                SizedBox(height: 12),
                                ServiceItem(
                                  title: 'Total Servicios QuickBox',
                                  price: 'US\$13.80',
                                  showInfo: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Impuestos
                          const Text(
                            'Impuestos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(16),
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
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Arancel',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Abrelatas: 10%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const ServiceItem(
                                  title: 'DAI',
                                  price: 'US\$0.00',
                                ),
                                const SizedBox(height: 12),
                                const ServiceItem(
                                  title: 'IVA - CIF',
                                  price: 'US\$3.61',
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                                const ServiceItem(
                                  title: 'Total Impuestos',
                                  price: 'US\$3.61',
                                  showInfo: false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Total a pagar
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: AppColors.dangerGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.local_shipping,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Total a pagar\npor envío',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Text(
                                  'US\$17.41',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Info adicional
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Los impuestos calculados son aproximados. El monto final será determinado por la aduana al momento de la liberación.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade900,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}