import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/user_role_provider.dart';
import 'package:mbe_orders_app/features/auth/providers/auth_provider.dart';
import '../widgets/external_url_webview.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;
    final customer = user?.customer;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA), // Fondo gris muy suave
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Encabezado Personalizado (Sin AppBar tradicional)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: _buildHeader(context, l10n, isAdmin, user, customer),
              ),
            ),

            // 2. Tarjeta Virtual (Dirección Miami)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: _buildVirtualCard(context, l10n, customer),
              ),
            ),

            // Botón igual a "Crear casillero" (abre WebView registro), debajo de la tarjeta — para reunión; luego se puede esconder
            if (!isAdmin &&
                ((customer?.lockerCode ?? '').trim().isNotEmpty))
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => ExternalUrlWebView(
                                url: _lockerRegistrationUrl,
                                title: l10n.homeLockerRegistrationTitle,
                                scrollToBottomOnLoad: true,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF1A1A2E).withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.box_add,
                                color: Color(0xFF1A1A2E),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.homeCreateLocker,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 3. Título de Sección
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  l10n.homeWhatDoYouWant,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // 4. Grid de Acciones (Bento Grid)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3, // Tarjetas más rectangulares
                children: [
                  _buildActionCard(
                    context,
                    title: l10n.homePreAlert,
                    subtitle: l10n.homePreAlertSubtitle,
                    icon: Iconsax.note_add5,
                    color: AppColors.primary,
                    onTap: () => context.go(
                      isAdmin ? '/admin/pre-alerts' : '/pre-alert',
                    ),
                    isPrimary: true,
                  ),
                  _buildActionCard(
                    context,
                    title: l10n.homeQuote,
                    subtitle: l10n.homeQuoteSubtitle,
                    icon: Iconsax.calculator5,
                    color: Colors.purple,
                    onTap: () => context.go('/quoter'),
                  ),
                  _buildActionCard(
                    context,
                    title: l10n.homeSearchOffers,
                    subtitle: l10n.homeSearchOffersSubtitle,
                    icon: Iconsax.tag,
                    color: Colors.indigo,
                    onTap: () => context.push('/trends'),
                  ),
                  _buildActionCard(
                    context,
                    title: l10n.homeNavPrint,
                    subtitle: l10n.homePrintOrdersSubtitle,
                    icon: Iconsax.printer,
                    color: Colors.teal,
                    onTap: () => context.go('/print-orders/my-orders'),
                  ),
                ],
              ),
            ),

            // Espacio final para que el bottom nav no tape nada
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  /// Obtiene el saludo según la hora del día
  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return l10n.homeGoodMorning;
    } else if (hour >= 12 && hour < 19) {
      return l10n.homeGoodAfternoon;
    } else {
      return l10n.homeGoodEvening;
    }
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isAdmin,
    dynamic user,
    dynamic customer,
  ) {
    // Solo mostrar dinámico si es customer
    if (!isAdmin && customer != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(l10n),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                customer.name.isNotEmpty
                    ? customer.name
                    : user?.name ?? l10n.authUser,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // Logo MBE en lugar del icono de persona
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/logo-mbe_horizontal_3.png',
              height: 32,
              width: 100,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }

    // Para admin, mantener el diseño original
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeAdminPanel,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.homeAdministrator,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(2), // Borde del avatar
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Iconsax.user, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  static const _lockerRegistrationUrl =
      'https://mbe-latam.com/registro/sal/ebox';

  Widget _buildVirtualCard(
    BuildContext context,
    AppLocalizations l10n,
    dynamic customer,
  ) {
    final lockerCode = customer?.lockerCode?.trim() ?? '';
    final hasLocker = lockerCode.isNotEmpty;

    // Sin casillero: mostrar mensaje y botón para crear uno (WebView)
    if (!hasLocker) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A2E).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.box, color: Colors.white54, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.homeNoLocker,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeNoLockerSubtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ExternalUrlWebView(
                        url: _lockerRegistrationUrl,
                        title: l10n.homeLockerRegistrationTitle,
                        scrollToBottomOnLoad: true,
                      ),
                    ),
                  );
                },
                icon: const Icon(Iconsax.box_add, color: Colors.white, size: 20),
                label: Text(
                  l10n.homeCreateLocker,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Con casillero: tarjeta actual
    final tierName = customer?.tierName;
    final hasTier =
        tierName != null && tierName.toString().trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasTier)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.medal_star,
                              color: Color(0xFFFFD700),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tierName!.trim().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    const Icon(Iconsax.box, color: Colors.white54),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeYourLocker,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lockerCode.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        fontFamily: 'Monospace',
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: "2950 NW 77th Ave, Miami, FL"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.homeAddressCopied)),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "2950 NW 77th Ave, Miami, FL",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Iconsax.copy,
                        color: Colors.white.withOpacity(0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? color.withOpacity(0.3)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withOpacity(0.2)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary ? Colors.white : color,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isPrimary
                            ? Colors.white.withOpacity(0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
