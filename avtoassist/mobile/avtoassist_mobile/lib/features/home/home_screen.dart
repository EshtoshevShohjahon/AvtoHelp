import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
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
          Icons.local_shipping_outlined,  const Color(0xFFFF7A1A)),
      _Service('fuel',         l.serviceFuel,        l.serviceFuelDesc,
          Icons.local_gas_station_outlined, const Color(0xFFFF7A1A)),
      _Service('car_wash',     l.serviceCarWash,     l.serviceCarWashDesc,
          Icons.water_drop_outlined,      const Color(0xFF2BD9A6)),
      _Service('parts',        l.serviceParts,       l.servicePartsDesc,
          Icons.store_outlined,           const Color(0xFF2BD9A6)),
      _Service('workshop',     l.serviceWorkshop,    l.serviceWorkshopDesc,
          Icons.precision_manufacturing_outlined, AppColors.steelLight),
    ];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bone)),
                        ]),
                        const CircleAvatar(
                          backgroundColor: AppColors.steel,
                          child: Icon(Icons.person_outline,
                              color: AppColors.boneDim),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.steelLine),
                      ),
                      child: Row(children: [
                        const Icon(Icons.search,
                            color: AppColors.steelLight, size: 18),
                        const SizedBox(width: 10),
                        Text(l.searchHint,
                            style: const TextStyle(
                                color: AppColors.steelLight, fontSize: 14)),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: services.map((s) => _ServiceCard(service: s)).toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.recentOrder,
                        style: const TextStyle(
                            color: AppColors.steelLight,
                            fontSize: 12,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    const _RecentOrderCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        } else {
          context.push('/order/new', extra: service.key);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.steelLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(service.icon, color: service.color, size: 19),
            ),
            const Spacer(),
            Text(service.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: AppColors.bone)),
            const SizedBox(height: 3),
            Text(service.subtitle,
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.3),
                blurRadius: 6, spreadRadius: 2)],
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Akkumulyator almashtirish',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            SizedBox(height: 2),
            Text('Yakunlandi · 3 kun oldin',
                style: TextStyle(color: AppColors.steelLight, fontSize: 11)),
          ],
        )),
        const Text('85 000 so\'m',
            style: TextStyle(
                fontFamily: 'monospace',
                color: AppColors.teal,
                fontSize: 12.5)),
      ]),
    );
  }
}
