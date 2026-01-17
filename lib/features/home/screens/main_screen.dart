import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/providers/user_role_provider.dart';
import '../../pre_alert/providers/pre_alerts_provider.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  List<NavigationItem> _getNavigationItems(bool isAdmin) {
    if (isAdmin) {
      // Navegación para Admin - 4 opciones
      return [
        NavigationItem(
          icon: Iconsax.home,
          activeIcon: Iconsax.home_15,
          label: 'Inicio',
          route: '/',
        ),
        NavigationItem(
          icon: Iconsax.document_text,
          activeIcon: Iconsax.document_text,
          label: 'Paquetes',
          route: '/admin/pre-alerts',
        ),
        NavigationItem(
          icon: Iconsax.search_normal,
          activeIcon: Iconsax.search_normal_1,
          label: 'Buscar',
          route: '/admin/search',
        ),
        NavigationItem(
          icon: Iconsax.profile_circle,
          activeIcon: Iconsax.profile_circle5,
          label: 'Perfil',
          route: '/profile',
        ),
      ];
    } else {
      // Navegación para Customer - 5 opciones
      return [
        NavigationItem(
          icon: Iconsax.home,
          activeIcon: Iconsax.home_15,
          label: 'Inicio',
          route: '/',
        ),
        NavigationItem(
          icon: Iconsax.printer,
          activeIcon: Iconsax.printer5,
          label: 'Impresiones',
          route: '/print-orders/my-orders',
        ),
        NavigationItem(
          icon: Iconsax.note_add,
          activeIcon: Iconsax.note_add5,
          label: 'Pre-alertar',
          route: '/pre-alert',
        ),
        NavigationItem(
          icon: Iconsax.calculator,
          activeIcon: Iconsax.calculator5,
          label: 'Cotizar',
          route: '/quoter',
        ),
        NavigationItem(
          icon: Iconsax.profile_circle,
          activeIcon: Iconsax.profile_circle5,
          label: 'Perfil',
          route: '/profile',
        ),
      ];
    }
  }

  void _onItemTapped(int index, List<NavigationItem> items) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(items[index].route);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    // Usar watch en lugar de read para que se actualice reactivamente
    final isAdmin = ref.watch(isAdminProvider);
    final items = _getNavigationItems(isAdmin);
    final String location = GoRouterState.of(context).uri.toString();

    // Lógica mejorada para encontrar el índice activo basado en la ruta
    for (int i = 0; i < items.length; i++) {
      final route = items[i].route;
      
      // Caso especial para home '/' que es match exacto
      if (location == '/' && route == '/') {
        setState(() => _selectedIndex = i);
        return;
      }
      
      // Para rutas que no son '/', verificar si la ubicación comienza con la ruta
      if (route != '/' && location.startsWith(route)) {
        // Para rutas admin, asegurarse de que es el match más específico
        if (isAdmin && route.startsWith('/admin')) {
          // Verificar que no sea una subruta más específica
          final nextChar = location.length > route.length 
              ? location[route.length] 
              : null;
          if (nextChar == null || nextChar == '/' || nextChar == '?') {
            setState(() => _selectedIndex = i);
            return;
          }
        } else {
        setState(() => _selectedIndex = i);
        return;
      }
      }
    }
    
    // Si no se encuentra match, mantener el índice actual o poner en 0
    if (_selectedIndex >= items.length) {
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final items = _getNavigationItems(isAdmin);
    
    // Verificar si hay acciones pendientes y el número (solo para usuarios no admin)
    final hasPendingActions = !isAdmin 
        ? ref.watch(hasPendingActionsProvider)
        : false;
    final pendingCount = !isAdmin 
        ? ref.watch(pendingActionsCountProvider)
        : 0;
    
    // Encontrar el índice del ítem "Pre-alertar" para agregar el badge
    final preAlertIndex = items.indexWhere((item) => item.route == '/pre-alert');

    return Scaffold(
      body: widget.child,
      drawer: const AppDrawer(),
      // Usamos NavigationBarTheme para personalizar estilos finos
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          // Fondo de la píldora indicadora (Color primario con transparencia suave)
          indicatorColor: AppColors.primary.withOpacity(0.12),
          // Estilo del texto cuando NO está seleccionado
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            );
          }),
          // Color de los iconos según estado
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 26);
            }
            return const IconThemeData(color: Colors.grey, size: 24);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, items),
          backgroundColor: Colors.white,
          elevation: 0, // Sin sombra dura, se ve más limpio
          // Borde superior sutil para separar del contenido
          surfaceTintColor: Colors.white,
          height: 70, // Altura estándar cómoda
          indicatorShape: const StadiumBorder(), // Forma de píldora redondeada
          destinations: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isPreAlertItem = index == preAlertIndex && hasPendingActions;
            
            return NavigationDestination(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.icon), // Icono normal (outline)
                  if (isPreAlertItem && pendingCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: pendingCount > 9 
                            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                            : const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: pendingCount > 9
                            ? const Text(
                                '9+',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
              selectedIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.activeIcon), // Icono seleccionado (filled)
                  if (isPreAlertItem && pendingCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: pendingCount > 9 
                            ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                            : const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: pendingCount > 9
                            ? const Text(
                                '9+',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
