import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _items = [
    NavigationItem(
      icon: Iconsax.home,
      activeIcon: Iconsax.home_15,
      label: 'Inicio',
      route: '/',
    ),
    NavigationItem(
      icon: Iconsax.radar,
      activeIcon: Iconsax.printer,
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
    // NavigationItem(
    //   icon: Iconsax.box,
    //   activeIcon: Iconsax.box,
    //   label: 'Paquetes',
    //   route: '/packages',
    // ),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(_items[index].route);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final String location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _items.length; i++) {
      if (location == _items[i].route) {
        setState(() {
          _selectedIndex = i;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      drawer: const AppDrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: _items.map((item) {
            final isSelected = _items[_selectedIndex] == item;
            return BottomNavigationBarItem(
              icon: Icon(item.icon, size: 24),
              activeIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  item.activeIcon,
                  size: 24,
                  color: Colors.white,
                ),
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