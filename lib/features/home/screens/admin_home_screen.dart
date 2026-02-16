import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mbe_orders_app/config/theme/mbe_theme.dart';
import 'package:mbe_orders_app/l10n/app_localizations.dart';
import 'package:mbe_orders_app/features/auth/providers/auth_provider.dart';
import 'package:mbe_orders_app/features/admin/pre_alert/providers/admin_kpis_provider.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class AdminHomeScreen extends HookConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipperTwo(),
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFFED1C24), const Color(0xFFB91419)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFED1C24).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                // Refrescar los KPIs cuando se hace pull down
                ref.invalidate(adminKPIsProvider);
                await ref.read(adminKPIsProvider.future);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildAdminHeader(context, ref, l10n),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _buildDailyStats(context, ref, l10n),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l10n.adminQuickOps,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1C24),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;
                        final cellWidth = (width - 16) / 2;
                        // Altura suficiente para icono + título + subtítulo sin overflow
                        const minCellHeight = 160.0;
                        final aspectRatio = cellWidth / minCellHeight;
                        return SliverGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: aspectRatio,
                          children: [
                            _buildActionCard(
                              context,
                              title: l10n.adminReception,
                              subtitle: l10n.adminReceptionSubtitle,
                              icon: Iconsax.import_1,
                              accentColor: MBETheme.brandBlack,
                              onTap: () => context.go('/admin/pre-alerts'),
                            ),
                            _buildActionCard(
                              context,
                              title: l10n.adminDelivery,
                              subtitle: l10n.adminDeliverySubtitle,
                              icon: Iconsax.box_tick,
                              accentColor: MBETheme.brandBlack,
                              onTap: () => context.go('/admin/locker-retrieval'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: Container(
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(30),
      //     gradient: const LinearGradient(
      //       colors: [Color(0xFFED1C24), Color(0xFFB91419)],
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: const Color(0xFFED1C24).withOpacity(0.4),
      //         blurRadius: 20,
      //         offset: const Offset(0, 10),
      //       ),
      //     ],
      //   ),
      //   child: FloatingActionButton.extended(
      //     onPressed: () {},
      //     backgroundColor: Colors.transparent,
      //     elevation: 0,
      //     icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
      //     label: const Text(
      //       "Escanear",
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontWeight: FontWeight.w600,
      //         fontSize: 16,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildAdminHeader(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final authState = ref.watch(authProvider);
    final user = authState.value;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF0A0B0F),
                    child: user?.name != null
                        ? Text(
                            user!.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : const Icon(
                            Iconsax.user,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/images/logo-mbe_horizontal_3.png',
              width: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'MBE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.search_normal,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.adminSearchPlaceholder,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyStats(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final kpisAsync = ref.watch(adminKPIsProvider);

    return kpisAsync.when(
      data: (kpis) => Column(
        children: [
          // Primera fila: Alertados Hoy y Recibidos Hoy
          Row(
            children: [
              Expanded(
                child: _buildLargeStatCard(
                  context,
                  label: l10n.adminAlertedToday,
                  value: kpis.createdToday.toString(),
                  icon: Iconsax.note_add,
                  iconColor: MBETheme.brandBlack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLargeStatCard(
                  context,
                  label: l10n.adminReceivedToday,
                  value: kpis.receivedToday.toString(),
                  icon: Iconsax.box_time,
                  iconColor: MBETheme.brandBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segunda fila: En Bodega y Salidas
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  context,
                  l10n.adminInWarehouse,
                  kpis.totalWarehouse.toString(),
                  MBETheme.brandBlack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStat(
                  context,
                  l10n.adminDepartures,
                  kpis.departuresToday.toString(),
                  MBETheme.brandBlack,
                ),
              ),
            ],
          ),
        ],
      ),
      loading: () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLargeStatCard(
                  context,
                  label: l10n.adminAlertedToday,
                  value: '...',
                  icon: Iconsax.note_add,
                  iconColor: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLargeStatCard(
                  context,
                  label: l10n.adminReceivedToday,
                  value: '...',
                  icon: Iconsax.box_time,
                  iconColor: MBETheme.brandBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  context,
                  l10n.adminInWarehouse,
                  '...',
                  MBETheme.brandBlack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStat(
                  context,
                  l10n.adminDepartures,
                  '...',
                  MBETheme.brandBlack,
                ),
              ),
            ],
          ),
        ],
      ),
      error: (error, stackTrace) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLargeStatCard(
                  context,
                  label: l10n.adminAlertedToday,
                  value: '0',
                  icon: Iconsax.note_add,
                  iconColor: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildLargeStatCard(
                  context,
                  label: l10n.adminReceivedToday,
                  value: '0',
                  icon: Iconsax.box_time,
                  iconColor: MBETheme.brandBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  context,
                  l10n.adminInWarehouse,
                  '0',
                  MBETheme.brandBlack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMiniStat(
                  context,
                  l10n.adminDepartures,
                  '0',
                  MBETheme.brandBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1C24),
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      height: 73,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
              letterSpacing: -1,
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
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: accentColor.withOpacity(0.1),
        highlightColor: accentColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1C24),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
