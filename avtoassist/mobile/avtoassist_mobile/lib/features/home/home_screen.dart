import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';
import '../auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final l    = AppLocalizations(context);

    final services = [
      _Service('tech_support', l.serviceTechSupport, l.serviceTechSupportDesc,
          Icons.build_outlined,           const Color(0xFFFF7A1A)),
      _Service('tow_truck',    l.serviceTowTruck,    l.serviceTowTruckDesc,
          Icons.local_shipping_outlined,  const Color(0xFFFFB020)),
      _Service('fuel',         l.serviceFuel,        l.serviceFuelDesc,
          Icons.local_gas_station_outlined, const Color(0xFFE5484D)),
      _Service('car_wash',     l.serviceCarWash,     l.serviceCarWashDesc,
          Icons.water_drop_outlined,      const Color(0xFF3DA5FF)),
      _Service('parts',        l.serviceParts,       l.servicePartsDesc,
          Icons.store_outlined,           const Color(0xFF2BD9A6)),
      _Service('workshop',     l.serviceWorkshop,    l.serviceWorkshopDesc,
          Icons.precision_manufacturing_outlined, const Color(0xFFB388FF)),
      _Service('truck',        l.serviceTruckSection, l.serviceTruckSectionDesc,
          Icons.local_shipping_outlined,  const Color(0xFF2BD9A6)),
      _Service('marketplace',  l.marketplace,         l.marketplaceSearch,
          Icons.storefront_outlined,      const Color(0xFFFF7A1A)),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Salomlashuv
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l.greeting,
                              style: const TextStyle(
                                  color: AppColors.steelLight, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(user?.fullName?.split(' ').first ?? user?.phone ?? '',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: AppColors.bone)),
                        ]),
                        Row(children: [
                          const _NotificationBell(),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                gradient: AppColors.amberGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppColors.glow(AppColors.amber),
                              ),
                              child: const Icon(Icons.person,
                                  color: Color(0xFF1A1100), size: 22),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Avtomobillarim kartochkasi — gradient hero
                    GestureDetector(
                      onTap: () => context.push('/vehicles'),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF272D35), Color(0xFF1A1E24)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.amber.withOpacity(0.25)),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              gradient: AppColors.amberGradient,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: AppColors.glow(AppColors.amber),
                            ),
                            child: const Icon(Icons.directions_car_rounded,
                                color: Color(0xFF1A1100), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(l.myVehicles,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.bone,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(l.myVehiclesDesc,
                                  style: const TextStyle(
                                      color: AppColors.steelLight, fontSize: 12)),
                            ]),
                          ),
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.steel,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(Icons.arrow_forward_ios,
                                color: AppColors.amber, size: 13),
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Xizmatlar sarlavhasi
                    Text(l.services,
                        style: const TextStyle(
                            color: AppColors.bone,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Xizmatlar grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.08,
                children: services.map((s) => _ServiceCard(service: s)).toList(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ─── Bildirishnoma qo'ng'irog'i (unread badge bilan) ─────────────────────────
class _NotificationBell extends ConsumerStatefulWidget {
  const _NotificationBell();
  @override
  ConsumerState<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<_NotificationBell> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/notifications/unread-count');
      if (!mounted) return;
      setState(() => _unread = (res.data['count'] as num?)?.toInt() ?? 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await context.push('/notifications');
        _loadCount(); // qaytganda yangilash
      },
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.steelLine),
        ),
        child: Stack(alignment: Alignment.center, children: [
          const Icon(Icons.notifications_none_rounded,
              color: AppColors.bone, size: 22),
          if (_unread > 0)
            Positioned(
              top: 9,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.asphalt, width: 1.5),
                ),
                child: Text(
                  _unread > 9 ? '9+' : '$_unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Service {
  final String key, title, subtitle;
  final IconData icon;
  final Color color;
  _Service(this.key, this.title, this.subtitle, this.icon, this.color);
}

class _ServiceCard extends StatelessWidget {
  final _Service service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (service.key == 'parts') {
          context.push('/catalog/parts');
        } else if (service.key == 'workshop') {
          context.push('/catalog/workshops');
        } else if (service.key == 'truck') {
          context.push('/truck');
        } else if (service.key == 'marketplace') {
          context.push('/marketplace');
        } else {
          context.push('/order/new', extra: service.key);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.steelLine),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: service.color.withOpacity(0.25)),
              ),
              child: Icon(service.icon, color: service.color, size: 21),
            ),
            const Spacer(),
            Text(service.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                    color: AppColors.bone)),
            const SizedBox(height: 3),
            Text(service.subtitle,
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 11, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
