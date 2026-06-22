import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  final String serviceType;
  const NewOrderScreen({super.key, required this.serviceType});
  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  String? _problemType;
  double? _lat, _lng;
  String _pickupAddress = '';
  double? _destLat, _destLng;
  String _destAddress = '';
  bool _loading = false;
  bool _locating = false;

  final _destCtrl = TextEditingController();

  static const _problems = {
    'tech_support': ['Dvigatel', 'Akkumulyator', 'Shina yorildi', 'Start bermayapti', 'Boshqa'],
    'tow_truck':    ['Avtohalokat', 'Dvigatel to\'xtadi', 'Boshqa'],
    'fuel':         ['Benzin', 'Dizel', 'Gaz'],
    'car_wash':     ['Tez yuvish', 'To\'liq tozalash', 'Salon tozalash'],
  };

  static const _prices = {
    'tech_support': '45 000 — 120 000',
    'tow_truck':    '80 000 — 250 000',
    'fuel':         '10 000 — 30 000',
    'car_wash':     '25 000 — 60 000',
  };

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _destCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() { _locating = false; _pickupAddress = AppLocalizations(context).locationDenied; });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _pickupAddress =
            '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        _locating = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _locating = false; _pickupAddress = AppLocalizations(context).locationFailed; });
    }
  }

  Future<void> _submit() async {
    if (_lat == null) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final data = {
        'service_type': widget.serviceType,
        'problem_type': _problemType,
        'pickup_lat': _lat,
        'pickup_lng': _lng,
        'pickup_address': _pickupAddress,
        if (widget.serviceType == 'tow_truck') ...{
          'destination_lat': _destLat ?? _lat,
          'destination_lng': _destLng ?? _lng,
          'destination_address': _destAddress,
        },
      };
      final res = await api.post('/orders', data: data);
      if (!mounted) return;
      final orderId = res.data['order']['id'];
      context.go('/order/tracking/$orderId');
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    final problems = _problems[widget.serviceType] ?? [];
    final price    = _prices[widget.serviceType]   ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_serviceTitle(l)),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(children: [
          Container(height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppColors.amber, AppColors.amber.withOpacity(0)]),
              )),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (problems.isNotEmpty) ...[  
                    _SectionLabel(l.problemType),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8,
                      children: problems.map((p) => GestureDetector(
                        onTap: () => setState(() => _problemType = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: _problemType == p
                                ? AppColors.amber
                                : AppColors.charcoal,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                                color: _problemType == p
                                    ? AppColors.amber
                                    : AppColors.steelLine),
                          ),
                          child: Text(p,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: _problemType == p
                                      ? const Color(0xFF1A1100)
                                      : AppColors.boneDim,
                                  fontWeight: _problemType == p
                                      ? FontWeight.w600
                                      : FontWeight.normal)),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 22),
                  ],
                  _SectionLabel(l.pickupLocation),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.steelLine),
                    ),
                    child: Row(children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.amber),
                      const SizedBox(width: 10),
                      Expanded(child: _locating
                          ? Text(l.locating,
                              style: const TextStyle(color: AppColors.steelLight))
                          : Text(_pickupAddress,
                              style: const TextStyle(
                                  color: AppColors.bone, fontSize: 13))),
                      IconButton(
                        icon: const Icon(Icons.my_location,
                            color: AppColors.steelLight, size: 20),
                        onPressed: _getLocation,
                      ),
                    ]),
                  ),
                  if (_lat != null && _lng != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 180,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(_lat!, _lng!),
                            initialZoom: 15,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.pinchZoom |
                                  InteractiveFlag.drag,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'uz.avtohelp.app',
                            ),
                            MarkerLayer(markers: [
                              Marker(
                                point: LatLng(_lat!, _lng!),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on,
                                    color: AppColors.amber, size: 40),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (widget.serviceType == 'tow_truck') ...[
                    _SectionLabel(l.destinationLocation),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _destCtrl,
                      style: const TextStyle(color: AppColors.bone),
                      decoration: InputDecoration(
                          hintText: l.towTruckDestHint,
                          prefixIcon: const Icon(Icons.flag_outlined,
                              color: AppColors.teal)),
                      onChanged: (v) => setState(() => _destAddress = v),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.charcoal,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.steelLine),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(l.estimatedPrice,
                              style: const TextStyle(
                                  color: AppColors.steelLight, fontSize: 11,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text('$price ${l.soum}',
                              style: const TextStyle(
                                  color: AppColors.teal,
                                  fontFamily: 'monospace', fontSize: 14)),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                          Text(l.estimatedTime,
                              style: const TextStyle(
                                  color: AppColors.steelLight, fontSize: 11,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          const Text('~12',
                              style: TextStyle(
                                  fontFamily: 'monospace', fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.bone)),
                          Text(l.minutes,
                              style: const TextStyle(
                                  color: AppColors.steelLight, fontSize: 10,
                                  letterSpacing: 0.5)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ElevatedButton(
              onPressed: (_lat != null && !_loading) ? _submit : null,
              child: _loading
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.asphalt))
                  : Text(l.requestService),
            ),
          ),
        ]),
      ),
    );
  }

  String _serviceTitle(AppLocalizations l) {
    switch (widget.serviceType) {
      case 'tech_support': return l.serviceTechSupport;
      case 'tow_truck':    return l.serviceTowTruck;
      case 'fuel':         return l.serviceFuel;
      case 'car_wash':     return l.serviceCarWash;
      default:             return widget.serviceType;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.steelLight, fontSize: 12, letterSpacing: 0.5));
}
