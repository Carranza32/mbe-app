import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/mbe_theme.dart';
import '../../../../config/router/app_router.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/edit_info_sheet.dart';
import '../widgets/language_selector_sheet.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final languageSubtitle = currentLocale?.languageCode == 'en'
        ? l10n.settingsLanguageSubtitleEn
        : l10n.settingsLanguageSubtitle;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA), // Fondo gris muy suave moderno
      body: authState.when(
        data: (userData) {
          if (userData == null) return Center(child: Text(l10n.profileNoSession));
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. App Bar Personalizado
              SliverAppBar(
                backgroundColor: const Color(0xFFF6F8FA),
                elevation: 0,
                pinned: true,
                centerTitle: false,
                expandedHeight: 0, // No expandible, solo sticky
                title: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    l10n.profileMyProfile,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: MBETheme.brandBlack,
                    ),
                  ),
                ),
                actions: [
                  // Botón sutil de notificaciones o configuración rápida
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.notification,
                        size: 20,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // 2. Contenido Principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Tarjeta de Identidad
                      _buildIdentityCard(context, userData),

                      const SizedBox(height: 32),

                      // Sección Estadísticas Rápidas (solo para clientes, no admin)
                      if (!userData.isAdmin) _buildQuickStats(context),
                      if (!userData.isAdmin) const SizedBox(height: 32),

                      // Agrupación 1: Cuenta
                      _buildSectionTitle(l10n.settingsAccount),
                      _buildSettingsGroup(
                        _buildAccountTiles(context, userData),
                      ),

                      const SizedBox(height: 24),

                      // Agrupación 2: General
                      _buildSectionTitle(l10n.settingsGeneral),
                      _buildSettingsGroup([
                        _SettingsTile(
                          icon: Iconsax.global,
                          title: l10n.settingsLanguage,
                          subtitle: languageSubtitle,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => const LanguageSelectorSheet(),
                            );
                          },
                        ),
                        _SettingsTile(
                          icon: Iconsax.support,
                          title: l10n.profileHelpSupport,
                          subtitle: l10n.profileHelpCenter,
                          onTap: () {},
                          showDivider: false,
                        ),
                      ]),

                      const SizedBox(height: 40),

                      // Botón Cerrar Sesión
                      _buildLogoutButton(context, ref),

                      const SizedBox(height: 40),

                      // Versión de la app
                      Text(
                        l10n.drawerVersion('1.0.2'),
                        style: TextStyle(
                          color: MBETheme.neutralGray.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.profileError(e.toString()))),
      ),
    );
  }

  // --- WIDGETS COMPONENTES ---

  List<Widget> _buildAccountTiles(BuildContext context, User user) {
    final l10n = AppLocalizations.of(context)!;
    final tiles = <Widget>[
      _SettingsTile(
        icon: Iconsax.user_edit,
        title: l10n.profileEditInfo,
        subtitle: l10n.profilePersonalData,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => EditInfoSheet(
              currentName: user.name,
              currentPhone: null,
              isAdmin: user.isAdmin,
            ),
          );
        },
      ),
      _SettingsTile(
        icon: Iconsax.lock,
        title: l10n.profileSecurity,
        subtitle: l10n.profilePasswordAccess,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ChangePasswordSheet(),
          );
        },
        showDivider: user.isAdmin, // sin divisor si es el último (admin)
      ),
    ];
    if (!user.isAdmin) {
      tiles.add(
        _SettingsTile(
          icon: Iconsax.location,
          title: l10n.profileMyAddresses,
          subtitle: l10n.profileManageDeliveries,
          onTap: () => context.push('/profile/addresses'),
          showDivider: false,
        ),
      );
    }
    return tiles;
  }

  Widget _buildIdentityCard(BuildContext context, User user) {
    final l10n = AppLocalizations.of(context)!;
    final initials = _getInitials(user.name);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Avatar con borde y sombra
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: MBETheme.brandBlack,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: MBETheme.brandBlack.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Badge de edición rápida
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: MBETheme.brandRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Iconsax.edit_2,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Textos
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: MBETheme.brandBlack,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: MBETheme.neutralGray.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          // Chip de Rol
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: user.isAdmin
                  ? const Color(0xFFFFF0F2) // Rojo muy suave
                  : const Color(0xFFF0F2F5), // Gris suave
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user.isAdmin ? Iconsax.verify5 : Iconsax.user,
                  size: 16,
                  color: user.isAdmin
                      ? MBETheme.brandRed
                      : MBETheme.neutralGray,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isAdmin ? l10n.profileAdministrator : l10n.profileClientMbe,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: user.isAdmin
                        ? MBETheme.brandRed
                        : MBETheme.neutralGray,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildStatItem(l10n.profilePackages, '12', Iconsax.box),
        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
        _buildStatItem(l10n.profilePoints, '450', Iconsax.star),
        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
        _buildStatItem(l10n.addresses, '2', Iconsax.map),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: MBETheme.brandBlack,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: MBETheme.neutralGray),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: MBETheme.neutralGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9EA3AE),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => _showLogoutDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F2), // Rojo muy claro
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MBETheme.brandRed.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.logout, color: MBETheme.brandRed, size: 20),
            const SizedBox(width: 10),
            Text(
              l10n.authLogout,
              style: TextStyle(
                color: MBETheme.brandRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showLogoutDialog(BuildContext profileContext, WidgetRef ref) {
    final l10n = AppLocalizations.of(profileContext)!;
    showDialog(
      context: profileContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          l10n.drawerLogoutConfirm,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.drawerLogoutMessage,
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.authCancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await ref.read(authProvider.notifier).logout();

              // Usar contexto de la pantalla de perfil (no el del diálogo, que ya está cerrado)
              if (!profileContext.mounted) return;
              ref.invalidate(appRouterProvider);

              await Future.delayed(const Duration(milliseconds: 200));

              if (!profileContext.mounted) return;
              final router = ref.read(appRouterProvider);
              router.go('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MBETheme.brandRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(l10n.authLogout),
          ),
        ],
      ),
    );
  }
}

// Widget interno para cada fila de opción
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: MBETheme.brandBlack, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: MBETheme.brandBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: MBETheme.neutralGray.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: MBETheme.neutralGray.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
