import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/gradient_card.dart';
import 'quote_detail_screen.dart';

class QuoteSummaryScreen extends StatelessWidget {
  const QuoteSummaryScreen({super.key});

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
                        'Resumen de Cotización',
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
                        children: [
                          // Cards de precio
                          Row(
                            children: [
                              Expanded(
                                child: GradientCard(
                                  gradient: AppColors.blueGradient,
                                  icon: Icons.shopping_cart,
                                  title: 'Precio de tu\ncompra',
                                  value: 'US\$20.00',
                                  shadowColor: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Icono de avión
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowMedium,
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flight,
                                  color: AppColors.textSecondary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GradientCard(
                                  gradient: AppColors.dangerGradient,
                                  icon: Icons.local_shipping,
                                  title: 'Total a pagar\npor envío',
                                  value: 'US\$17.41',
                                  shadowColor: Colors.red.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          CustomButton(
                            text: 'Ver detalle',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuoteDetailScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Info adicional
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.shade100,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: Colors.amber.shade800,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Se debe tomar en cuenta que la factura comercial es la que permite la determinación de los impuestos a pagar en la aduana. QuickBox no es responsable del valor declarado por el cliente.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade900,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Beneficios
                          Container(
                            padding: const EdgeInsets.all(20),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Beneficios incluidos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildBenefitItem('Seguro opcional de \$1.00 por cada \$100 adicionales'),
                                _buildBenefitItem('Cobertura gratis hasta \$200'),
                                _buildBenefitItem('Entrega a domicilio área metropolitana gratis'),
                                _buildBenefitItem('Compras libres de impuestos en El Salvador'),
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

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}