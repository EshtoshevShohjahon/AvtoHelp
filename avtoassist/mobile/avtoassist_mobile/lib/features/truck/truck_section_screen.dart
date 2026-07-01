import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

// ─── Yuk avtomobillari bosh bo'limi ─────────────────────────────────────────
class TruckSectionScreen extends ConsumerWidget {
  const TruckSectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations(context);

    final services = [
      _TruckService(
        key: 'truck_repair',
        icon: '🔧',
        title: l.truckRepair,
        desc: l.truckRepairDesc,
        color: const Color(0xFFFF7A1A),
      ),
      _TruckService(
        key: 'truck_tow',
        icon: '🚛',
        title: l.truckTow,
        desc: l.truckTowDesc,
        color: const Color(0xFFFF7A1A),
      ),
      _TruckService(
        key: 'truck_tire',
        icon: '⚫',
        title: l.truckTire,
        desc: l.truckTireDesc,
        color: const Color(0xFF2BD9A6),
      ),
      _TruckService(
        key: 'truck_fuel',
        icon: '⛽',
        title: l.truckFuel,
        desc: l.truckFuelDesc,
        color: const Color(0xFF2BD9A6),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.truckSection),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2A1A), Color(0xFF0D1F0D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Text('🚛', style: TextStyle(fontSize: 42)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.truckSection,
                      style: const TextStyle(
                          color: AppColors.bone,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(l.serviceTruckSectionDesc,
                      style: const TextStyle(
                          color: AppColors.steelLight, fontSize: 12)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Moy turlari ma'lumotnomasi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              const Icon(Icons.oil_barrel_outlined,
                  color: AppColors.amber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.truckOilTypes,
                    style: const TextStyle(
                        color: AppColors.amber, fontSize: 12)),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Xizmat kartalari
          Text(l.services,
              style: const TextStyle(
                  color: AppColors.steelLight,
                  fontSize: 12,
                  letterSpacing: 0.5)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
            children: services
                .map((s) => _TruckServiceCard(service: s))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Ustaxonalar xaritasi
          _TruckWorkshopsPreview(),
        ],
      ),
    );
  }
}

class _TruckService {
  final String key, icon, title, desc;
  final Color color;
  const _TruckService({
    required this.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });
}

class _TruckServiceCard extends StatelessWidget {
  final _TruckService service;
  const _TruckServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/order/new', extra: service.key),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.steelLine),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: service.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: service.color.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Text(service.icon,
                  style: const TextStyle(fontSize: 21)),
            ),
          ),
          const Spacer(),
          Text(service.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.bone)),
          const SizedBox(height: 3),
          Text(service.desc,
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ─── Yuk mashina ustaxonalari xaritasi (preview) ─────────────────────────────
class _TruckWorkshopsPreview extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TruckWorkshopsPreview> createState() =>
      _TruckWorkshopsPreviewState();
}

class _TruckWorkshopsPreviewState
    extends ConsumerState<_TruckWorkshopsPreview> {
  final _mapCtrl = MapController();
  List<Map<String, dynamic>> _workshops = [];
  bool _loading = true;
  LatLng? _myLoc;
  static const _tashkent = LatLng(41.2995, 69.2401);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.deniedForever &&
          perm != LocationPermission.denied) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          ).timeout(const Duration(seconds: 6));
          if (mounted) setState(() => _myLoc = LatLng(pos.latitude, pos.longitude));
        } catch (_) {}
      }
      final api = ref.read(apiClientProvider);
      final res = await api.get('/workshops/all',
          query: {'category': 'truck'});
      final list = (res.data['workshops'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
      if (!mounted) return;
      setState(() {
        _workshops = list;
        _loading = false;
      });
      if (_myLoc != null) _mapCtrl.move(_myLoc!, 11);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(l.truckWorkshops,
            style: const TextStyle(
                color: AppColors.bone,
                fontWeight: FontWeight.w600,
                fontSize: 15)),
        const Spacer(),
        Text('${_workshops.length} ta',
            style: const TextStyle(
                color: AppColors.steelLight, fontSize: 12)),
      ]),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 260,
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.amber))
              : FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _myLoc ?? _tashkent,
                    initialZoom: 11,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'uz.avtohelp.app',
                    ),
                    if (_myLoc != null)
                      MarkerLayer(markers: [
                        Marker(
                          point: _myLoc!,
                          width: 32,
                          height: 32,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.my_location,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ]),
                    MarkerLayer(
                      markers: _workshops.map((w) {
                        final lat = (w['lat'] as num).toDouble();
                        final lng = (w['lng'] as num).toDouble();
                        return Marker(
                          point: LatLng(lat, lng),
                          width: 36,
                          height: 36,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A2A1A),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.teal, width: 1.5),
                            ),
                            child: const Center(
                              child: Text('🚛',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),
      ),
      const SizedBox(height: 10),
      if (_workshops.isNotEmpty)
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _workshops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final w = _workshops[i];
              final specs = (w['specializations'] as List?) ?? [];
              return Container(
                width: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.steelLine),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(w['name'] as String? ?? '',
                      style: const TextStyle(
                          color: AppColors.bone,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    w['address'] as String? ??
                        (specs.isNotEmpty ? specs.first.toString() : ''),
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              );
            },
          ),
        ),
      const SizedBox(height: 20),
    ]);
  }
}
