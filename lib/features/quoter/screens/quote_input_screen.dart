import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import 'quote_summary_screen.dart';

class QuoteInputScreen extends StatelessWidget {
  const QuoteInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          // Header con gradiente
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                // AppBar personalizado
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        'assets/images/flag.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Cotizador',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'VP8.18',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Código de cliente
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tu código de cliente',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SAL4279XJ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Formulario
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
                          const Text(
                            'Ingresa los datos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Completa la información para cotizar tu envío',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          const CustomInputField(
                            label: 'Valor de mercadería',
                            hint: 'Ingresa el valor',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            suffixText: 'USD',
                          ),

                          const SizedBox(height: 20),

                          const CustomInputField(
                            label: 'Peso',
                            hint: 'Ingresa el peso',
                            icon: Icons.scale,
                            keyboardType: TextInputType.number,
                            suffixText: 'kg',
                          ),

                          const SizedBox(height: 20),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tipo de producto',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(
                                      Icons.category,
                                      color: AppColors.primary,
                                    ),
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
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  value: 'Abrelatas: 10%',
                                  items: [
                                    'Abrelatas: 10%',
                                    'Electrónicos: 15%',
                                    'Ropa: 20%',
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {},
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          CustomButton(
                            text: 'Cotizar',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QuoteSummaryScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

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
                                    'La factura comercial es la que permite la determinación de los impuestos a pagar en la aduana.',
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
    );
  }
}