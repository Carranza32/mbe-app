import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/design_system/ds_buttons.dart';
import '../../../../../config/theme/mbe_theme.dart';
import '../../data/models/admin_pre_alert_model.dart';
import '../../data/models/package_status.dart';
import '../../providers/admin_pre_alerts_provider.dart';
import '../../providers/context_counts_provider.dart';
import '../../providers/package_selection_provider.dart';
import '../../providers/package_status_provider.dart';
import '../widgets/context_filter_segmented.dart';
import '../widgets/package_list_item.dart';
import '../widgets/package_list_shimmer.dart';
import '../widgets/package_edit_modal.dart';
import '../widgets/package_location_edit_modal.dart';
import '../widgets/pickup_delivery_modal.dart';
import '../widgets/delivery_dispatch_sheet.dart';
import 'scan_packages_modal.dart';
import 'quick_delivery_scan_modal.dart';
import 'search_pre_alerts_screen.dart';

class AdminPreAlertsListScreen extends ConsumerStatefulWidget {
  const AdminPreAlertsListScreen({super.key});

  @override
  ConsumerState<AdminPreAlertsListScreen> createState() =>
      _AdminPreAlertsListScreenState();
}

class _AdminPreAlertsListScreenState
    extends ConsumerState<AdminPreAlertsListScreen> {
  PackageContext _selectedContext = PackageContext.porRecibir;
  PackageStatus? selectedFilter; // Para filtros secundarios
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
      ref
          .read(adminPreAlertsProvider.notifier)
          .filterByContext(_selectedContext);
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
    final alertsState = ref.watch(adminPreAlertsProvider);
    final countsState = ref.watch(contextCountsProvider);
    final selectionState = ref.watch(packageSelectionProvider);
    final selectedCount = selectionState.length;
    final isSelectionMode = selectedCount > 0;

    return Scaffold(
      backgroundColor: MBETheme.lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Paquetes Para Envío',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: MBETheme.brandBlack,
          ),
        ),
        actions: [
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
      floatingActionButton: isSelectionMode
          ? null
          : _buildContextualFAB(context, ref),

      // CAMBIO UX: Barra de acciones contextual (Solo aparece si hay selección)
      bottomSheet: isSelectionMode
          ? _buildSelectionActionBar(context, ref, selectedCount)
          : null,

      body: Column(
        children: [
          // Segmented Control para contextos principales (con animación)
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
                          selectedFilter = null; // Reset filtros secundarios
                        });
                        // Aplicar filtro en el provider
                        ref
                            .read(adminPreAlertsProvider.notifier)
                            .filterByContext(context);
                      },
                      counts:
                          countsState.value ??
                          {
                            PackageContext.porRecibir: 0,
                            PackageContext.enBodega: 0,
                            PackageContext.paraEntregar: 0,
                          },
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
                        _selectedContext == PackageContext.enBodega)
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
                  onRefresh: () =>
                      ref.read(adminPreAlertsProvider.notifier).refresh(),
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

  // Widget auxiliar para la barra inferior de selección
  Widget _buildSelectionActionBar(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$count seleccionados",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                  InkWell(
                    onTap: () => ref
                        .read(packageSelectionProvider.notifier)
                        .clearSelection(),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Limpiar selección",
                        style: TextStyle(
                          color: MBETheme.brandRed,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DSButton.primary(
                label: 'Exportar',
                icon: Iconsax.export,
                onPressed: () => _exportSelected(context, ref),
              ),
            ),
          ],
        ),
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
    );
  }

  Future<void> _exportSelected(BuildContext context, WidgetRef ref) async {
    final selection = ref.read(packageSelectionProvider);
    if (selection.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Paquetes'),
        content: Text(
          '¿Exportar ${selection.length} paquete(s) seleccionado(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          DSButton.primary(
            label: 'Exportar',
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // TODO: Revisar lógica de exportación - podría ser una acción que no cambia estado
    // o cambiar a un estado específico según la lógica de negocio
    final statusManager = ref.read(packageStatusManagerProvider.notifier);
    final success = await statusManager.updateStatus(
      packageIds: selection.toList(),
      newStatus: PackageStatus
          .listaParaRecibir, // Temporal - revisar lógica de negocio
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${selection.length} paquete(s) exportado(s) exitosamente'
                : 'Error al exportar paquetes',
          ),
          backgroundColor: success ? Colors.green : MBETheme.brandRed,
        ),
      );

      if (success) {
        ref.read(packageSelectionProvider.notifier).clearSelection();
      }
    }
  }

  void _showEditModal(BuildContext context, AdminPreAlert package) {
    // Si estamos en "En Bodega", usar modal de ubicación
    if (_selectedContext == PackageContext.enBodega) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PackageLocationEditModal(package: package),
      ).then((result) {
        if (result == true) {
          ref.invalidate(adminPreAlertsProvider);
          ref.invalidate(contextCountsProvider);
        }
      });
    } else {
      // Para otras secciones, usar modal de edición normal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PackageEditModal(package: package),
      ).then((result) {
        if (result == true) {
          ref.invalidate(adminPreAlertsProvider);
          ref.invalidate(contextCountsProvider);
        }
      });
    }
  }

  /// FAB contextual que cambia según el contexto activo
  Widget _buildContextualFAB(BuildContext context, WidgetRef ref) {
    switch (_selectedContext) {
      case PackageContext.porRecibir:
        return FloatingActionButton.extended(
          onPressed: () => _showScanModal(context, ref),
          backgroundColor: MBETheme.brandBlack,
          icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
          label: const Text(
            "Escanear Recepción",
            style: TextStyle(color: Colors.white),
          ),
        );

      case PackageContext.enBodega:
        // return FloatingActionButton.extended(
        //   onPressed: () {
        //     // Abrir modal de asignación de rack
        //     // Por ahora usamos el scan modal, pero se puede cambiar
        //     _showScanModal(context, ref);
        //   },
        //   backgroundColor: MBETheme.brandBlack,
        //   icon: const Icon(Iconsax.location, color: Colors.white),
        //   label: const Text(
        //     "Asignar Rack",
        //     style: TextStyle(color: Colors.white),
        //   ),
        // );
        return const SizedBox.shrink();

      case PackageContext.paraEntregar:
        return FloatingActionButton.extended(
          onPressed: () => _showQuickDeliveryScan(context),
          backgroundColor: MBETheme.brandBlack,
          icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
          label: const Text(
            "Escanear retiro",
            style: TextStyle(color: Colors.white),
          ),
        );
    }
  }

  /// Mostrar modal de escaneo rápido para entregas
  void _showQuickDeliveryScan(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickDeliveryScanModal(),
    ).then((result) {
      if (result == true) {
        ref.invalidate(adminPreAlertsProvider);
        ref.invalidate(contextCountsProvider);
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
