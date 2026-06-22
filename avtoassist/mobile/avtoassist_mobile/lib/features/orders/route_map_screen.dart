import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

/// Provayderdan mijozning joylashuviga eng qisqa yo'nalishni ko'rsatadi.
/// [origin] berilmasa, qurilmaning GPS koordinatalari ishlatiladi.
class RouteMapScreen extends StatefulWidget {
  final LatLng destination;
  final String destinationLabel;
  final LatLng? origin;

  const RouteMapScreen({
    super.key,
    required this.destination,
    this.destinationLabel = '',
    this.origin,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final _mapController = MapController();
  List<LatLng> _routePoints = [];
  LatLng? _origin;
  bool _loading = true;
  String? _error;
  double? _distanceKm;
  int? _durationMin;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      LatLng origin;
      if (widget.origin != null) {
        origin = widget.origin!;
      } else {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _error = AppLocalizations(context).locationPermissionDenied;
              _loading = false;
            });
          }
          return;
        }
        final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high),
        );
        origin = LatLng(pos.latitude, pos.longitude);
      }
      if (mounted) setState(() => _origin = origin);
      await _fetchRoute(origin, widget.destination);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _fetchRoute(LatLng from, LatLng to) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${from.longitude},${from.latitude};'
          '${to.longitude},${to.latitude}'
          '?overview=full&geometries=geojson';
      final res = await Dio().get(url);
      final route = res.data['routes'][0];
      final coords = route['geometry']['coordinates'] as List;
      final points = coords
          .map((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();
      final distM = (route['distance'] as num).toDouble();
      final durS = (route['duration'] as num).toDouble();
      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _distanceKm = distM / 1000;
        _durationMin = (durS / 60).ceil();
        _loading = false;
      });
      if (points.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(56),
          ),
        );
      }
    } catch (_) {
      // Route fetch failed — still show markers
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.routeToClient),
        actions: [
          if (!_loading && _durationMin != null && _distanceKm != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Text(
                  l.distanceAndTime(_distanceKm!, _durationMin!),
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.amber))
          : (_error != null && _origin == null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.location_off,
                          color: AppColors.danger, size: 52),
                      const SizedBox(height: 14),
                      Text(_error!,
                          style: const TextStyle(
                              color: AppColors.steelLight, fontSize: 14),
                          textAlign: TextAlign.center),
                    ]),
                  ),
                )
              : Stack(children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.destination,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'uz.avtohelp.app',
                      ),
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(polylines: [
                          Polyline(
                            points: _routePoints,
                            color: AppColors.teal,
                            strokeWidth: 5,
                            borderColor: AppColors.asphalt.withOpacity(0.6),
                            borderStrokeWidth: 2,
                          ),
                        ]),
                      MarkerLayer(markers: [
                        // Mijoz (to'sariq pin)
                        Marker(
                          point: widget.destination,
                          width: 48,
                          height: 56,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.amber,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.destinationLabel.isNotEmpty
                                      ? widget.destinationLabel
                                      : l.client,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1100)),
                                ),
                              ),
                              const Icon(Icons.location_on,
                                  color: AppColors.amber, size: 28),
                            ],
                          ),
                        ),
                        // Provayderning joylashuvi (yashil mashina)
                        if (_origin != null)
                          Marker(
                            point: _origin!,
                            width: 44,
                            height: 44,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.teal.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.directions_car,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                      ]),
                    ],
                  ),
                  // Pastki ma'lumot paneli
                  if (_routePoints.isNotEmpty)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.steelLine),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 16)
                          ],
                        ),
                        child: Row(children: [
                          const Icon(Icons.route_outlined,
                              color: AppColors.teal, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                '${_distanceKm!.toStringAsFixed(1)} km',
                                style: const TextStyle(
                                    color: AppColors.bone,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'monospace'),
                              ),
                              Text(
                                '$_durationMin ${l.minutes}',
                                style: const TextStyle(
                                    color: AppColors.steelLight, fontSize: 12),
                              ),
                            ]),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.teal.withOpacity(0.4)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.navigation_outlined,
                                  color: AppColors.teal, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                l.providerEnRoute,
                                style: const TextStyle(
                                    color: AppColors.teal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  // Yo'nalish yuklanmadi xabari
                  if (!_loading && _routePoints.isEmpty && _origin != null)
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.charcoal.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.amber.withOpacity(0.4)),
                        ),
                        child: Text(
                          l.routeFetchFailed,
                          style: const TextStyle(
                              color: AppColors.amber, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ]),
    );
  }
}
