import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/context_counts_provider.dart';
import '../../providers/package_selection_provider.dart';
import '../widgets/context_filter_segmented.dart';
import '../widgets/package_list_item.dart';
import '../widgets/package_list_shimmer.dart';
import '../widgets/package_edit_modal.dart';
import '../widgets/complete_delivery_info_modal.dart';
import '../widgets/pickup_delivery_modal.dart';
import '../widgets/delivery_dispatch_sheet.dart';
import 'scan_packages_modal.dart';
import '../widgets/confirm_shipment_group_sheet.dart';
import '../widgets/confirm_delivery_dispatch_sheet.dart';

class AdminPreAlertsListScreen extends ConsumerStatefulWidget {
  const AdminPreAlertsListScreen({super.key});

  @override
  ConsumerState<AdminPreAlertsListScreen> createState() =>
      _AdminPreAlertsListScreenState();
}

class _AdminPreAlertsListScreenState
    extends ConsumerState<AdminPreAlertsListScreen> {
  PackageContext _selectedContext = PackageContext.porRecibir;
  DeliveryMethodSubContext _selectedDeliveryMethodSub =
      DeliveryMethodSubContext.domicilio;
  bool _showOnlyWithoutLocation = false;
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = true; // Controla la visibilidad de los filtros
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Aplicar el filtro inicial cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminPreAlertsProvider.notifier).filterByContext(
            _selectedContext,
            deliveryMethodSub:
                ContextFilterSegmented.hasSubPills(_selectedContext)
                ? _selectedDeliveryMethodSub
                : null,
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Cargar más cuando se acerca al final
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final notifier = ref.read(adminPreAlertsProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore().then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }

    // Detectar dirección del scroll para ocultar/mostrar filtros
    final currentOffset = _scrollController.position.pixels;
    final scrollDelta = currentOffset - _lastScrollOffset;

    // Solo ocultar/mostrar si el scroll es significativo (más de 10px)
    if (scrollDelta.abs() > 10) {
      if (scrollDelta > 0 && _showFilters && currentOffset > 50) {
        // Scrolling hacia abajo - ocultar filtros
        setState(() {
          _showFilters = false;
        });
      } else if (scrollDelta < 0 && !_showFilters) {
        // Scrolling hacia arriba - mostrar filtros
        setState(() {
          _showFilters = true;
        });
      }
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    // Resetear header y scroll cuando vuelven datos tras recarga (p. ej. después de completar acción)
    ref.listen(adminPreAlertsProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasValue && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _showFilters = true;
            _lastScrollOffset = 0;
          });
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
        });
      }
    });

    final alertsState = ref.watch(adminPreAlertsProvider);
    final countsState = ref.watch(contextCountsProvider);
    final solicitudEnvioSubCountsState =
        ref.watch(solicitudEnvioSubCountsProvider);
    final confirmacionesSubCountsState =
        ref.watch(confirmacionesSubCountsProvider);
    final enCaminoSubCountsState = ref.watch(enCaminoSubCountsProvider);

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paquetes para envío',
          style: TextStyle(color: MBETheme.brandBlack),
        ),
        actions: [
          //imagen del logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/images/logo-mbe_horizontal_3.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 100,
                color: MBETheme.brandBlack,
                child: const Center(
                  child: Text(
                    'MBE Mail Boxes Etc.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Iconsax.search_normal, color: MBETheme.brandBlack),
          //   tooltip: 'Buscar',
          //   onPressed: () {
          //     //cambiar menu de Paquetes a Buscar paquetes
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Iconsax.import_1, color: MBETheme.brandBlack),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text('Importar Pre-Alertas')),
          //     );
          //   },
          // ),
        ],
      ),

      // FAB que cambia según el contexto
      floatingActionButton: _buildContextualFAB(context, ref),

      body: Column(
        children: [
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: _showFilters ? Offset.zero : const Offset(0, -1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showFilters ? 1.0 : 0.0,
              child: _showFilters
                  ? ContextFilterSegmented(
                      selectedContext: _selectedContext,
                      onContextChanged: (context) {
                        setState(() {
                          _selectedContext = context;
                          if (ContextFilterSegmented.hasSubPills(context)) {
                            _selectedDeliveryMethodSub =
                                DeliveryMethodSubContext.domicilio;
                          }
                        });
                        ref.read(adminPreAlertsProvider.notifier).filterByContext(
                              context,
                              deliveryMethodSub:
                                  ContextFilterSegmented.hasSubPills(context)
                                  ? _selectedDeliveryMethodSub
                                  : null,
                            );
                        ref.invalidate(contextCountsProvider);
                        ref.invalidate(solicitudEnvioSubCountsProvider);
                        ref.invalidate(confirmacionesSubCountsProvider);
                        ref.invalidate(enCaminoSubCountsProvider);
                      },
                      counts: countsState.value ??
                          {for (final c in PackageContext.values) c: 0},
                      selectedSubContext:
                          ContextFilterSegmented.hasSubPills(_selectedContext)
                          ? _selectedDeliveryMethodSub
                          : null,
                      onSubContextChanged:
                          ContextFilterSegmented.hasSubPills(_selectedContext)
                          ? (sub) {
                              setState(() =>
                                  _selectedDeliveryMethodSub = sub);
                              ref
                                  .read(adminPreAlertsProvider.notifier)
                                  .filterByContext(
                                    _selectedContext,
                                    deliveryMethodSub: sub,
                                  );
                            }
                          : null,
                      subCounts: ContextFilterSegmented.hasSubPills(
                              _selectedContext)
                          ? (_selectedContext ==
                                  PackageContext.solicitudEnvio
                              ? solicitudEnvioSubCountsState.value
                              : _selectedContext ==
                                      PackageContext.confirmacionesDeEnvio
                              ? confirmacionesSubCountsState.value
                              : enCaminoSubCountsState.value)
                          : null,
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Filtros secundarios (opcional, solo en modo avanzado)
          // Por ahora lo dejamos oculto, se puede mostrar con un toggle
          Expanded(
            child: alertsState.when(
              data: (alerts) {
                // Verificar si la lista está vacía (null o sin datos)
                if (alerts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.box_1,
                          size: 64,
                          color: MBETheme.neutralGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay paquetes disponibles',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Esta sección está vacía',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final filteredAlerts =
                    (_showOnlyWithoutLocation &&
                        _selectedContext == PackageContext.disponibles)
                    ? alerts
                          .where(
                            (alert) =>
                                alert.rackNumber == null ||
                                alert.rackNumber!.isEmpty ||
                                alert.segmentNumber == null ||
                                alert.segmentNumber!.isEmpty,
                          )
                          .toList()
                    : alerts;

                final notifier = ref.read(adminPreAlertsProvider.notifier);
                final isLoadingMore = notifier.isLoadingMore;
                final hasMore = notifier.hasMore;

                if (filteredAlerts.isEmpty && !isLoadingMore) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showOnlyWithoutLocation
                              ? Iconsax.location_slash
                              : Iconsax.box_1,
                          size: 64,
                          color: MBETheme.neutralGray.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showOnlyWithoutLocation
                              ? 'No hay paquetes sin ubicación'
                              : 'No hay paquetes disponibles',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showOnlyWithoutLocation
                              ? 'Todos los paquetes tienen ubicación asignada'
                              : 'Esta sección está vacía',
                          style: TextStyle(
                            color: MBETheme.neutralGray.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    await ref.read(adminPreAlertsProvider.notifier).refresh();
                    ref.invalidate(contextCountsProvider);
                    ref.invalidate(solicitudEnvioSubCountsProvider);
                    ref.invalidate(confirmacionesSubCountsProvider);
                    ref.invalidate(enCaminoSubCountsProvider);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount:
                        filteredAlerts.length +
                        (hasMore && isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredAlerts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return PackageListItem(
                        package: filteredAlerts.elementAt(index),
                        context: _selectedContext,
                        onTap: () => _showEditModal(
                          context,
                          filteredAlerts.elementAt(index),
                        ),
                        onCompleteDeliveryInfo:
                            _selectedContext == PackageContext.disponibles
                            ? () => _showCompleteDeliveryInfo(
                                context,
                                filteredAlerts.elementAt(index),
                              )
                            : null,
                      );
                    },
                  ),
                );
              },
              loading: () => const PackageListShimmer(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.danger,
                      size: 48,
                      color: MBETheme.brandRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar paquetes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    DSButton.primary(
                      label: 'Reintentar',
                      onPressed: () => ref.invalidate(adminPreAlertsProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showScanModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => ScanPackagesModal(mode: _selectedContext),
    ).then((result) {
      // Siempre refrescar después de escanear (puede haber cambios)
      ref.invalidate(adminPreAlertsProvider);
      ref.invalidate(contextCountsProvider);
      ref.invalidate(solicitudEnvioSubCountsProvider);
      ref.invalidate(confirmacionesSubCountsProvider);
      ref.invalidate(enCaminoSubCountsProvider);
    });
  }

  void _showEditModal(BuildContext context, AdminPreAlert package) {
    // Al tocar la tarjeta: siempre abrir detalle (edición). En Disponibles, "Completar información" se abre desde el botón de la tarjeta.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PackageEditModal(package: package),
    ).then((result) {
      if (result == true) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
        ref.invalidate(solicitudEnvioSubCountsProvider);
        ref.invalidate(confirmacionesSubCountsProvider);
        ref.invalidate(enCaminoSubCountsProvider);
      }
    });
  }

  void _showCompleteDeliveryInfo(BuildContext context, AdminPreAlert package) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: SafeArea(
                child: CompleteDeliveryInfoModal(package: package, asPage: true),
              ),
            ),
          ),
        )
        .then((result) {
      if (result == true) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
        ref.invalidate(solicitudEnvioSubCountsProvider);
      }
    });
  }

  /// FAB contextual que cambia según el contexto activo
  Widget _buildContextualFAB(BuildContext context, WidgetRef ref) {
    switch (_selectedContext) {
      case PackageContext.porRecibir:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFED1C24), Color(0xFFB91419)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFED1C24).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showScanModal(context, ref),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
            label: const Text(
              "Escanear Recepción",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

      case PackageContext.disponibles:
      case PackageContext.enCamino:
      case PackageContext.entregado:
        return const SizedBox.shrink();

      case PackageContext.solicitudEnvio:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFED1C24), Color(0xFFB91419)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFED1C24).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showConfirmShipmentGroup(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
            label: const Text(
              'Confirmar envío',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

      case PackageContext.confirmacionesDeEnvio:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFFED1C24), Color(0xFFB91419)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFED1C24).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showConfirmDeliveryDispatch(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
            label: const Text(
              'Entregar paquetes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
    }
  }

  /// Mostrar pantalla "Procesar Envío" (Pendiente de confirmar: escanear, Boxful/otro, confirmar grupo)
  void _showConfirmShipmentGroup(BuildContext context) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(
            builder: (context) => const ConfirmShipmentGroupSheet(),
          ),
        )
        .then((result) {
      if (result == true) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
        ref.invalidate(solicitudEnvioSubCountsProvider);
        ref.invalidate(confirmacionesSubCountsProvider);
        ref.invalidate(enCaminoSubCountsProvider);
      }
    });
  }

  /// Mostrar pantalla "Confirmar salida" (Listos para salir: escanear find-for-dispatch, proveedor, firma, confirmar)
  void _showConfirmDeliveryDispatch(BuildContext context) {
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(
            builder: (context) => const ConfirmDeliveryDispatchSheet(),
          ),
        )
        .then((result) {
          if (result == true) {
            ref.invalidate(adminPreAlertsProvider);
            ref.invalidate(contextCountsProvider);
            ref.invalidate(solicitudEnvioSubCountsProvider);
            ref.invalidate(confirmacionesSubCountsProvider);
            ref.invalidate(enCaminoSubCountsProvider);
          }
        });
  }

  /// Procesar entrega directamente desde la lista principal (legacy - mantener por si acaso)
  void _processDeliveryFromList(BuildContext context, WidgetRef ref) {
    final selectionState = ref.read(packageSelectionProvider);
    if (selectionState.isEmpty) return;

    final alertsState = ref.read(adminPreAlertsProvider);
    final allAlerts = alertsState.value ?? [];

    // Obtener los paquetes seleccionados
    // La validación del estado se hace en el backend
    final selectedPackages = allAlerts
        .where((alert) => selectionState.contains(alert.id))
        .toList();

    if (selectedPackages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay paquetes seleccionados'),
          backgroundColor: MBETheme.brandRed,
        ),
      );
      return;
    }

    // Detectar tipos de entrega
    final pickupPackages = selectedPackages
        .where((p) => p.deliveryMethod == 'pickup')
        .toList();
    final deliveryPackages = selectedPackages
        .where((p) => p.deliveryMethod == 'delivery')
        .toList();

    // Si hay mezcla de tipos, mostrar selector
    if (pickupPackages.isNotEmpty && deliveryPackages.isNotEmpty) {
      _showDeliveryTypeSelector(context, pickupPackages, deliveryPackages, ref);
      return;
    }

    // Si todos son del mismo tipo, abrir el modal correspondiente
    if (pickupPackages.isNotEmpty) {
      _showPickupModal(context, pickupPackages, ref);
    } else if (deliveryPackages.isNotEmpty) {
      _showDeliveryModal(context, deliveryPackages, ref);
    }
  }

  /// Mostrar selector cuando hay mezcla de tipos de entrega
  void _showDeliveryTypeSelector(
    BuildContext context,
    List<AdminPreAlert> pickupPackages,
    List<AdminPreAlert> deliveryPackages,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tipos de Entrega Mezclados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tienes ${pickupPackages.length} paquete(s) para Pickup y ${deliveryPackages.length} para Delivery.',
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Cómo deseas procesarlos?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Procesar solo los pickup
              _showPickupModal(context, pickupPackages, ref);
            },
            child: Text('Solo Pickup (${pickupPackages.length})'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Procesar solo los delivery
              _showDeliveryModal(context, deliveryPackages, ref);
            },
            child: Text('Solo Delivery (${deliveryPackages.length})'),
          ),
          DSButton.primary(
            label: 'Ambos por separado',
            onPressed: () {
              Navigator.of(context).pop();
              // Procesar ambos en secuencia
              _showPickupModal(context, pickupPackages, ref).then((_) {
                if (mounted && deliveryPackages.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _showDeliveryModal(context, deliveryPackages, ref);
                  });
                }
              });
            },
          ),
        ],
      ),
    );
  }

  /// Mostrar modal de entrega Pickup
  Future<void> _showPickupModal(
    BuildContext context,
    List<AdminPreAlert> packages,
    WidgetRef ref,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PickupDeliveryModal(packages: packages),
    ).then((result) {
      if (result == true) {
        // Limpiar selección y refrescar
        ref.read(packageSelectionProvider.notifier).clearSelection();
        ref.invalidate(adminPreAlertsProvider);
      }
    });
  }

  /// Mostrar modal de despacho Delivery
  Future<void> _showDeliveryModal(
    BuildContext context,
    List<AdminPreAlert> packages,
    WidgetRef ref,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DeliveryDispatchSheet(packages: packages),
    ).then((result) {
      if (result == true) {
        // Limpiar selección y refrescar
        ref.read(packageSelectionProvider.notifier).clearSelection();
        ref.invalidate(adminPreAlertsProvider);
      }
    });
  }
}
