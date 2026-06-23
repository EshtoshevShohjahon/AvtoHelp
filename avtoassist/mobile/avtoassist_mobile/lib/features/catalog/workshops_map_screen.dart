import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

class WorkshopsMapScreen extends ConsumerStatefulWidget {
  const WorkshopsMapScreen({super.key});
  @override
  ConsumerState<WorkshopsMapScreen> createState() => _WorkshopsMapScreenState();
}

class _WorkshopsMapScreenState extends ConsumerState<WorkshopsMapScreen> {
  final _mapController = MapController();
  List<Map<String, dynamic>> _workshops = [];
  Map<String, dynamic>? _selected;
  bool _loading = true;
  String? _error;
  LatLng? _myLocation;
  bool _showList = false;
  String _filter = '';

  // Toshkent markazi (default)
  static const _tashkent = LatLng(41.2995, 69.2401);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Joylashuvni olish
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm != LocationPermission.deniedForever &&
          perm != LocationPermission.denied) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
          ).timeout(const Duration(seconds: 8));
          if (mounted) setState(() => _myLocation = LatLng(pos.latitude, pos.longitude));
        } catch (_) {}
      }

      final api = ref.read(apiClientProvider);
      final res = await api.get('/workshops/all');
      final list = (res.data['workshops'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

      if (!mounted) return;
      setState(() {
        _workshops = list;
        _loading = false;
      });

      // Xaritani joylashuvga moslashtirish
      if (_myLocation != null) {
        _mapController.move(_myLocation!, 12);
      } else if (list.isNotEmpty) {
        _mapController.move(
          LatLng(
            (list.first['lat'] as num).toDouble(),
            (list.first['lng'] as num).toDouble(),
          ),
          11,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter.isEmpty) return _workshops;
    final q = _filter.toLowerCase();
    return _workshops.where((w) {
      final name = (w['name'] as String? ?? '').toLowerCase();
      final addr = (w['address'] as String? ?? '').toLowerCase();
      final spec = ((w['specializations'] as List?) ?? [])
          .join(' ')
          .toLowerCase();
      return name.contains(q) || addr.contains(q) || spec.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    final filtered = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.nearbyWorkshops),
        actions: [
          IconButton(
            icon: Icon(
              _showList ? Icons.map_outlined : Icons.list_outlined,
              color: AppColors.amber,
            ),
            onPressed: () => setState(() => _showList = !_showList),
            tooltip: _showList ? 'Xarita' : "Ro'yxat",
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.amber))
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.wifi_off_outlined,
                        color: AppColors.steelLight, size: 48),
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: AppColors.steelLight),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _load, child: Text(l.retry)),
                  ]))
              : Column(children: [
                  // Qidiruv
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: TextField(
                      style: const TextStyle(color: AppColors.bone),
                      decoration: InputDecoration(
                        hintText: "${l.nearbyWorkshops}...",
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.steelLight, size: 20),
                        suffixIcon: _filter.isNotEmpty
                            ? GestureDetector(
                                onTap: () => setState(() => _filter = ''),
                                child: const Icon(Icons.clear,
                                    color: AppColors.steelLight, size: 18))
                            : null,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ),
                  // Nechta topildi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(children: [
                      Text(
                        '${filtered.length} ta servis',
                        style: const TextStyle(
                            color: AppColors.steelLight, fontSize: 12),
                      ),
                      const Spacer(),
                      if (_myLocation != null)
                        const Row(children: [
                          Icon(Icons.my_location,
                              color: AppColors.teal, size: 13),
                          SizedBox(width: 4),
                          Text('GPS',
                              style: TextStyle(
                                  color: AppColors.teal, fontSize: 12)),
                        ]),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: _showList
                        ? _buildList(filtered, l)
                        : _buildMap(filtered, l),
                  ),
                ]),
    );
  }

  Widget _buildMap(List<Map<String, dynamic>> list, AppLocalizations l) {
    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _myLocation ?? _tashkent,
          initialZoom: 12,
          onTap: (_, __) => setState(() => _selected = null),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'uz.avtohelp.app',
          ),
          // Mening joylashuvim
          if (_myLocation != null)
            MarkerLayer(markers: [
              Marker(
                point: _myLocation!,
                width: 36,
                height: 36,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.teal.withOpacity(0.4),
                          blurRadius: 8)
                    ],
                  ),
                  child: const Icon(Icons.person_pin_circle,
                      color: Colors.white, size: 18),
                ),
              ),
            ]),
          // Servislar markerlari
          MarkerLayer(
            markers: list.map((w) {
              final lat = (w['lat'] as num).toDouble();
              final lng = (w['lng'] as num).toDouble();
              final isSelected = _selected?['id'] == w['id'];
              final specs = (w['specializations'] as List?) ?? [];
              final icon = _specIcon(specs.isNotEmpty ? specs.first as String : '');
              return Marker(
                point: LatLng(lat, lng),
                width: isSelected ? 140 : 36,
                height: isSelected ? 56 : 36,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selected = isSelected ? null : w);
                    _mapController.move(LatLng(lat, lng), 15);
                  },
                  child: isSelected
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.amber,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black38, blurRadius: 6)
                                ],
                              ),
                              child: Text(
                                w['name'] as String? ?? '',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1100)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.location_on,
                                color: AppColors.amber, size: 20),
                          ],
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.charcoal,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.amber, width: 1.5),
                          ),
                          child: Center(
                            child: Text(icon,
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      // Tanlangan servis kartasi
      if (_selected != null)
        Positioned(
          left: 16,
          right: 16,
          bottom: 20,
          child: _WorkshopCard(
            workshop: _selected!,
            l: l,
            onClose: () => setState(() => _selected = null),
          ),
        ),
      // Marker soni
      Positioned(
        top: 8,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.charcoal.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.steelLine),
          ),
          child: Text(
            '${list.length} ta',
            style: const TextStyle(
                color: AppColors.bone,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ]);
  }

  Widget _buildList(List<Map<String, dynamic>> list, AppLocalizations l) {
    if (list.isEmpty) {
      return Center(
        child: Text(l.noServiceHistory,
            style: const TextStyle(color: AppColors.steelLight)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => GestureDetector(
        onTap: () {
          final w = list[i];
          setState(() {
            _selected = w;
            _showList = false;
          });
          _mapController.move(
            LatLng(
              (w['lat'] as num).toDouble(),
              (w['lng'] as num).toDouble(),
            ),
            15,
          );
        },
        child: _WorkshopCard(workshop: list[i], l: l),
      ),
    );
  }

  String _specIcon(String spec) {
    switch (spec) {
      case 'Moyka':           return '🚿';
      case 'Shina':           return '🔧';
      case "Ehtiyot qismlar": return '⚙️';
      case "Yoqilg'i":        return '⛽';
      default:                return '🔩';
    }
  }
}

class _WorkshopCard extends StatelessWidget {
  final Map<String, dynamic> workshop;
  final AppLocalizations l;
  final VoidCallback? onClose;
  const _WorkshopCard({required this.workshop, required this.l, this.onClose});

  @override
  Widget build(BuildContext context) {
    final name = workshop['name'] as String? ?? '';
    final address = workshop['address'] as String? ?? '';
    final phone = workshop['phone'] as String? ?? '';
    final rating = (workshop['rating_avg'] as num?)?.toDouble() ?? 0;
    final specs = (workshop['specializations'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelLine),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.car_repair, color: AppColors.amber, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              if (address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(address,
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
          if (onClose != null)
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close,
                  color: AppColors.steelLight, size: 18),
            ),
        ]),
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: specs.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.teal.withOpacity(0.3)),
            ),
            child: Text(s.toString(),
                style: const TextStyle(
                    color: AppColors.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          )).toList()),
        ],
        if (rating > 0 || phone.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            if (rating > 0) ...[
              const Icon(Icons.star, color: AppColors.amber, size: 14),
              const SizedBox(width: 3),
              Text(rating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: AppColors.amber,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(width: 12),
            ],
            if (phone.isNotEmpty) ...[
              const Icon(Icons.phone_outlined,
                  color: AppColors.steelLight, size: 14),
              const SizedBox(width: 4),
              Text(phone,
                  style: const TextStyle(
                      color: AppColors.steelLight, fontSize: 12)),
            ],
          ]),
        ],
      ]),
    );
  }
}
