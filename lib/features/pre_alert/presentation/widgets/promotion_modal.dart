import 'package:flutter/material.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/core/design_system/ds_buttons.dart';
import '../../data/models/promotion_model.dart';
import '../../data/models/pre_alert_model.dart';
import '../../data/repositories/pre_alerts_repository.dart';
import '../../providers/pre_alert_complete_provider.dart';

class PromotionModal extends ConsumerStatefulWidget {
  final PreAlert preAlert;

  const PromotionModal({
    Key? key,
    required this.preAlert,
  }) : super(key: key);

  @override
  ConsumerState<PromotionModal> createState() => _PromotionModalState();
}

class _PromotionModalState extends ConsumerState<PromotionModal> {
  PromotionModel? _promotion;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPromotion();
  }

  Future<void> _loadPromotion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final completeState = ref.read(preAlertCompleteProvider(widget.preAlert));
      final repository = ref.read(preAlertsRepositoryProvider);

      // Validar que se haya seleccionado método de entrega
      if (completeState.deliveryMethod == null) {
        setState(() {
          _error = 'Por favor selecciona un método de entrega primero';
          _isLoading = false;
        });
        return;
      }

      // Obtener store_id desde la tienda seleccionada o usar 1 por defecto
      final storeId = completeState.selectedStoreId ?? 1;
      
      // Determinar appliesTo según el método
      final appliesTo = completeState.isDelivery ? 'delivery' : 'subtotal';
      final deliveryCost = completeState.isDelivery ? 2.0 : 0.0;

      final request = BestPromotionRequest(
        storeId: storeId,
        serviceType: 'pre_alert',
        subtotal: widget.preAlert.totalValue,
        deliveryCost: deliveryCost,
        appliesTo: appliesTo,
      );

      final response = await repository.getBestPromotion(request: request);

      setState(() {
        _promotion = response?.data;
        _isLoading = false;
        // Si no hay promoción (null), no es un error
        if (response == null || response.data == null) {
          _error = null;
        }
      });
    } catch (e) {
        setState(() {
          _error = AppLocalizations.of(context)!.preAlertErrorLoadingPromotion(e.toString());
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MBERadius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: MBESpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MBETheme.neutralGray.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(MBERadius.small),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(MBESpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(MBESpacing.md),
                    decoration: BoxDecoration(
                      color: MBETheme.brandBlack,
                      borderRadius: BorderRadius.circular(MBERadius.medium),
                    ),
                    child: const Icon(
                      Iconsax.discount_shape,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: MBESpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.preAlertPromotionsAvailable,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Aprovecha nuestras ofertas especiales',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(MBESpacing.xxxl),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(MBESpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      size: 48,
                      color: MBETheme.brandRed,
                    ),
                    const SizedBox(height: MBESpacing.md),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: MBESpacing.lg),
                    ElevatedButton.icon(
                      onPressed: _loadPromotion,
                      icon: const Icon(Iconsax.refresh),
                      label: Text(l10n.preAlertRetry),
                    ),
                  ],
                ),
              )
            else if (_promotion == null)
              Padding(
                padding: const EdgeInsets.all(MBESpacing.xl),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.tag,
                      size: 48,
                      color: MBETheme.neutralGray,
                    ),
                    const SizedBox(height: MBESpacing.md),
                    Text(
                      l10n.preAlertNoPromotions,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildPromotionContent(context, _promotion!),

            // Footer
            Padding(
              padding: const EdgeInsets.all(MBESpacing.lg),
              child: SafeArea(
                top: false,
                child: DSButton.primary(
                  label: l10n.preAlertClose,
                  onPressed: () => Navigator.pop(context),
                  fullWidth: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionContent(BuildContext context, PromotionModel promotion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(MBESpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(MBESpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MBETheme.brandBlack.withValues(alpha: 0.05),
              MBETheme.brandBlack.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(MBERadius.large),
          border: Border.all(
            color: MBETheme.brandBlack.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge de promoción
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MBESpacing.md,
                    vertical: MBESpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: MBETheme.brandBlack,
                    borderRadius: BorderRadius.circular(MBERadius.small),
                  ),
                  child: Text(
                    'PROMOCIÓN',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: MBESpacing.sm),
                Icon(
                  Iconsax.discount_shape,
                  color: MBETheme.brandBlack,
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: MBESpacing.lg),

            // Nombre de la promoción
            Text(
              promotion.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: MBETheme.brandBlack,
              ),
            ),

            const SizedBox(height: MBESpacing.sm),

            // Descripción
            Text(
              promotion.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: MBESpacing.lg),

            // Descuento estimado
            Container(
              padding: const EdgeInsets.all(MBESpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MBERadius.medium),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    color: const Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: MBESpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.preAlertEstimatedSavings,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$${promotion.estimatedDiscount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
