import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/providers/user_role_provider.dart';

class AppDrawer extends HookConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    
    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header del drawer con gradiente
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola! mario',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'SAL4279XJ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.medal_star,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Estándar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DrawerSection(
                    title: 'Principal',
                    items: [
                      _DrawerItem(
                        icon: Iconsax.profile_circle,
                        title: 'Perfil',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.location,
                        title: 'Direcciones registradas',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.ticket,
                        title: 'Códigos promocionales',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.warning_2,
                        title: 'Materiales restringidos',
                        iconColor: AppColors.warning,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DrawerSection(
                    title: 'Servicios',
                    items: [
                      _DrawerItem(
                        icon: Iconsax.radar,
                        title: 'Rastrear paquete',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/tracking');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.note_add,
                        title: 'Pre-alertar',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/pre-alert');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.calculator,
                        title: 'Cotizar',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/quoter');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.box,
                        title: 'Tus paquetes',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/packages');
                        },
                      ),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 16),
                    _DrawerSection(
                      title: 'Administración',
                      items: [
                        _DrawerItem(
                          icon: Iconsax.box,
                          title: 'Admin - Pre-Alerts',
                          iconColor: AppColors.warning,
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/admin/pre-alerts');
                          },
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _DrawerSection(
                    title: 'Cuenta',
                    items: [
                      _DrawerItem(
                        icon: Iconsax.card,
                        title: 'Métodos de pago',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.crown_1,
                        title: 'Planes Premium',
                        iconColor: AppColors.warning,
                        badge: 'Nuevo',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.notification,
                        title: 'Notificaciones',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.note_text,
                        title: 'Historial',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DrawerSection(
                    title: 'Ayuda',
                    items: [
                      _DrawerItem(
                        icon: Iconsax.message_question,
                        title: 'Preguntas frecuentes',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.sms,
                        title: 'Contáctanos',
                        onTap: () {},
                      ),
                      _DrawerItem(
                        icon: Iconsax.document_text,
                        title: 'Términos y Condiciones',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.logout,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Versión 8.18',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<_DrawerItem> items;

  const _DrawerSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 52,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.iconColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}