import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/user_role_provider.dart';
import 'package:mbe_orders_app/features/auth/providers/auth_provider.dart';

class AppDrawer extends HookConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final customer = user?.customer;
    final userName = customer?.name.isNotEmpty == true
        ? customer!.name
        : (user?.name ?? '');
    final lockerCode = customer?.lockerCode ?? '';
    final tierName = customer?.tierName?.trim().isNotEmpty == true
        ? customer!.tierName!
        : l10n.drawerTierStandard;

    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header: acorde con la marca (rojo MBE)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Iconsax.user,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.drawerHello(
                                userName.isNotEmpty ? userName : l10n.authUser,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lockerCode.isNotEmpty ? lockerCode : '—',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.medal_star,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tierName,
                          style: const TextStyle(
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

            // Menú: solo rutas existentes y usables
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  _DrawerSection(
                    title: l10n.drawerSectionMain,
                    items: [
                      _DrawerItem(
                        icon: Iconsax.profile_circle,
                        title: l10n.drawerProfile,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/profile');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.location,
                        title: l10n.drawerAddresses,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/profile/addresses');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.ticket,
                        title: l10n.drawerPromoCodes,
                        onTap: () {
                          Navigator.pop(context);
                          // Sin ruta aún; se puede agregar cuando exista
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DrawerSection(
                    title: l10n.drawerSectionServices,
                    items: [
                      _DrawerItem(
                        icon: Iconsax.trend_up,
                        title: l10n.homeNavTrends,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/trends');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.note_add,
                        title: l10n.drawerPreAlert,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/pre-alert');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.calculator,
                        title: l10n.drawerQuote,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/quoter');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.box,
                        title: l10n.drawerYourPackages,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/packages');
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.printer,
                        title: l10n.homeNavPrint,
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/print-orders/my-orders');
                        },
                      ),
                    ],
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 16),
                    _DrawerSection(
                      title: l10n.drawerSectionAdmin,
                      items: [
                        _DrawerItem(
                          icon: Iconsax.document_text,
                          title: l10n.drawerAdminPreAlerts,
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
                    title: l10n.drawerSectionHelp,
                    items: [
                      _DrawerItem(
                        icon: Iconsax.message_question,
                        title: l10n.drawerFaq,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.sms,
                        title: l10n.drawerContact,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _DrawerItem(
                        icon: Iconsax.document_text,
                        title: l10n.drawerTerms,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.logout,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.drawerLogout,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.drawerVersion('8.18'),
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.drawerLogoutConfirm,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.drawerLogoutMessage),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.authCancel,
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (context.mounted) Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(l10n.drawerLogout),
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<_DrawerItem> items;

  const _DrawerSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 52,
                      endIndent: 16,
                      color: AppColors.divider,
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
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(10),
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
              Icon(Icons.chevron_right, color: AppColors.textHint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
