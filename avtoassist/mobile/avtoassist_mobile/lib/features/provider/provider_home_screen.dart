import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/vehicles/vehicle_detail_screen.dart';
import '../../features/orders/route_map_screen.dart';
import '../../widgets/app_widgets.dart';

// ─── Provider bosh ekrani ────────────────────────────────────────────────────
class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});
  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  final _passportCtrl = TextEditingController();
  bool _searching = false;
  bool _isOnline = false;
  bool _togglingStatus = false;
  String? _error;
  Map<String, dynamic>? _foundVehicle;
  List<dynamic> _records = [];
  Map<String, dynamic>? _oilAlert;

  // Statistika
  double _todayEarnings = 0;
  int _totalOrders = 0;
  double _rating = 0;
  bool _statsLoaded = false;

  // Sektor
  String? _sector;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadSector();
  }

  Future<void> _loadSector() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/providers/me');
      if (!mounted) return;
      setState(() => _sector = res.data['sector'] as String?);
    } catch (_) {}
  }

  @override
  void dispose() {
    _passportCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/providers/me/stats');
      if (!mounted) return;
      setState(() {
        _todayEarnings = (res.data['today_earnings'] as num?)?.toDouble() ?? 0;
        _totalOrders = (res.data['total_orders'] as num?)?.toInt() ?? 0;
        _rating = (res.data['rating'] as num?)?.toDouble() ?? 0;
        _isOnline = res.data['is_online'] == true;
        _statsLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _statsLoaded = true);
    }
  }

  Future<void> _toggleStatus() async {
    setState(() => _togglingStatus = true);
    try {
      final api = ref.read(apiClientProvider);
      final newStatus = !_isOnline;
      await api.patch('/providers/me/status',
          data: {'is_online': newStatus});
      if (!mounted) return;
      setState(() {
        _isOnline = newStatus;
        _togglingStatus = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _togglingStatus = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _search() async {
    final tp = _passportCtrl.text.trim().toUpperCase();
    if (tp.isEmpty) return;
    setState(() { _searching = true; _error = null; _foundVehicle = null; });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/providers/vehicle-lookup',
          query: {'tech_passport': tp});
      if (!mounted) return;
      setState(() {
        _foundVehicle = res.data['vehicle'];
        _records = res.data['records'] ?? [];
        _oilAlert = res.data['oil_alert'];
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = e.toString().contains('404')
            ? AppLocalizations(context).vehicleNotFoundPassport
            : e.toString();
      });
    }
  }

  // Har bir sektor uchun o'ziga xos panel: rang, tezkor amallar, qidiruv.
  _SectorPanel _panelFor(BuildContext context, String? sector) {
    final l = AppLocalizations(context);
    final accent = _sectorAccent(sector ?? 'workshop');

    final manageListings = _QuickAction(
      icon: Icons.storefront_outlined,
      title: l.myListings,
      subtitle: l.marketplace,
      onTap: () => context.push('/marketplace/my'),
    );
    final addListing = _QuickAction(
      icon: Icons.add_business_outlined,
      title: l.addListing,
      subtitle: l.setPriceHint,
      onTap: () => context.push('/marketplace/add'),
    );
    final orders = _QuickAction(
      icon: Icons.receipt_long_outlined,
      title: l.activeOrders,
      subtitle: l.setOnlineToReceive,
      onTap: () => context.go('/provider/orders'),
    );

    switch (sector) {
      case 'parts_store':
      case 'tire_shop':
      case 'oil_store':
        return _SectorPanel(
          accent: accent,
          showVehicleSearch: false,
          actions: [manageListings, addListing, orders],
        );
      case 'car_wash':
      case 'tow_truck':
        return _SectorPanel(
          accent: accent,
          showVehicleSearch: false,
          actions: [orders],
        );
      case 'tech_support':
        return _SectorPanel(
          accent: accent,
          showVehicleSearch: true,
          actions: [orders],
        );
      case 'workshop':
      default:
        return _SectorPanel(
          accent: accent,
          showVehicleSearch: true,
          actions: [manageListings],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final l = AppLocalizations(context);
    final cfg = _panelFor(context, _sector);
    final showSearch = cfg.showVehicleSearch;
    return Scaffold(
      appBar: AppBar(
        title: Text(_sector != null ? _sectorLabel(_sector!) : l.providerPanel),
        actions: [
          // Online/Offline toggle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _togglingStatus
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.amber))
                : GestureDetector(
                    onTap: _toggleStatus,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? AppColors.teal.withOpacity(0.15)
                            : AppColors.charcoal,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _isOnline
                                ? AppColors.teal
                                : AppColors.steelLine),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 7, height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isOnline
                                ? AppColors.teal
                                : AppColors.steelLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isOnline ? l.statusActive : l.statusResting,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isOnline
                                  ? AppColors.teal
                                  : AppColors.steelLight),
                        ),
                      ]),
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Salomlashuv + ism + sektor badge
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.steel,
              child: const Icon(Icons.person_outline,
                  color: AppColors.boneDim, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                user?.fullName?.split(' ').first ?? 'Usta',
                style: const TextStyle(
                    color: AppColors.bone,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              if (_sector != null)
                Text(_sectorLabel(_sector!),
                    style: const TextStyle(color: AppColors.amber, fontSize: 11)),
            ])),
          ]),
          const SizedBox(height: 16),

          // Statistika
          _StatsRow(
            todayEarnings: _todayEarnings,
            totalOrders: _totalOrders,
            rating: _rating,
            loaded: _statsLoaded,
          ),
          const SizedBox(height: 16),

          // Sektorga xos banner
          _SectorBanner(sector: _sector ?? 'workshop'),
          const SizedBox(height: 16),

          // Sektorga xos tezkor amallar
          ...cfg.actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuickActionTile(action: a, accent: cfg.accent),
              )),
          if (cfg.actions.isNotEmpty) const SizedBox(height: 6),

          // Vehicle qidirish (faqat ustaxona / texnik yordam uchun)
          if (showSearch) Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.steelLine),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.search, color: AppColors.amber, size: 18),
                const SizedBox(width: 8),
                Text(l.searchClientVehicle,
                    style: const TextStyle(
                        color: AppColors.bone,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
              const SizedBox(height: 4),
              Text(l.enterTechPassport,
                  style: const TextStyle(color: AppColors.steelLight, fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _passportCtrl,
                    style: const TextStyle(
                        color: AppColors.bone,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'AAF1234567',
                      prefixIcon: Icon(Icons.credit_card_outlined,
                          color: AppColors.amber),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searching ? null : _search,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: _searching
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.asphalt))
                      : const Icon(Icons.search, size: 20),
                ),
              ]),
            ]),
          ),

          // Xatolik
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.4)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13))),
              ]),
            ),
          ],

          // Topilgan avtomobil
          if (_foundVehicle != null) ...[
            const SizedBox(height: 16),
            _VehicleInfoCard(
              vehicle: _foundVehicle!,
              oilAlert: _oilAlert,
              records: _records,
              onAddRecord: () async {
                final added = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _ProviderAddRecordScreen(
                      vehicleId: _foundVehicle!['id'],
                      vehicleTitle:
                          '${_foundVehicle!['brand']} ${_foundVehicle!['model']}',
                    ),
                  ),
                );
                if (added == true) _search();
              },
            ),
          ],

          if (showSearch && _foundVehicle == null && !_searching && _error == null) ...[
            const SizedBox(height: 40),
            Center(
              child: Column(children: [
                const Icon(Icons.car_repair, color: AppColors.steelLine, size: 64),
                const SizedBox(height: 16),
                Text(l.vehicleLookupHint,
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 14),
                    textAlign: TextAlign.center),
              ]),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Sektor yordamchi ─────────────────────────────────────────────────────────
String _sectorLabel(String sector) {
  switch (sector) {
    case 'workshop':     return 'Ustaxona / Mexanik';
    case 'parts_store':  return "Ehtiyot qismlar do'koni";
    case 'tire_shop':    return 'Shina va disk';
    case 'oil_store':    return 'Moy va suyuqliklar';
    case 'car_wash':     return 'Avtoyuv';
    case 'tow_truck':    return 'Evakuator';
    case 'tech_support': return 'Texnik yordam';
    default:             return 'Boshqa';
  }
}

IconData _sectorIcon(String sector) {
  switch (sector) {
    case 'workshop':     return Icons.handyman_outlined;
    case 'parts_store':  return Icons.settings_outlined;
    case 'tire_shop':    return Icons.trip_origin_outlined;
    case 'oil_store':    return Icons.opacity_outlined;
    case 'car_wash':     return Icons.local_car_wash_outlined;
    case 'tow_truck':    return Icons.rv_hookup_outlined;
    case 'tech_support': return Icons.build_circle_outlined;
    default:             return Icons.more_horiz;
  }
}

// Har bir sektorga o'ziga xos urg'u rangi (panelni vizual ajratish uchun)
Color _sectorAccent(String sector) {
  switch (sector) {
    case 'workshop':     return const Color(0xFFFF7A1A); // to'q sariq
    case 'parts_store':  return const Color(0xFF2BD9A6); // yashil
    case 'tire_shop':    return const Color(0xFFB388FF); // binafsha
    case 'oil_store':    return const Color(0xFFFFB020); // oltin
    case 'car_wash':     return const Color(0xFF3DA5FF); // ko'k
    case 'tow_truck':    return const Color(0xFFE5484D); // qizil
    case 'tech_support': return const Color(0xFF26C6DA); // moviy
    default:             return AppColors.amber;
  }
}

// Sektorga mos qisqa izoh
String _sectorTagline(String sector) {
  switch (sector) {
    case 'workshop':
      return "Mijoz avtomobilini qidiring, xizmat qaydini qo'shing";
    case 'parts_store':
      return "Ehtiyot qismlar e'lonlarini joylang, narx belgilang";
    case 'tire_shop':
      return "Shina va disk e'lonlarini boshqaring";
    case 'oil_store':
      return "Moy va suyuqliklar e'lonlarini joylang";
    case 'car_wash':
      return "Onlayn bo'ling, yuvish buyurtmalarini qabul qiling";
    case 'tow_truck':
      return "Chaqiruvlarni qabul qiling, yo'nalishni ko'ring";
    case 'tech_support':
      return "Yo'l yordami chaqiruvlarini qabul qiling";
    default:
      return "Buyurtmalar qabul qiling, onlayn bo'ling";
  }
}

// ─── Sektorga xos panel konfiguratsiyasi ─────────────────────────────────────
class _SectorPanel {
  final Color accent;
  final bool showVehicleSearch;
  final List<_QuickAction> actions;
  _SectorPanel({
    required this.accent,
    required this.showVehicleSearch,
    required this.actions,
  });
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  final Color accent;
  const _QuickActionTile({required this.action, required this.accent});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(action.icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(action.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.bone,
                      fontSize: 14)),
              Text(action.subtitle,
                  style: const TextStyle(
                      color: AppColors.steelLight, fontSize: 11)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: AppColors.steelLight, size: 18),
        ]),
      ),
    );
  }
}

class _SectorBanner extends StatelessWidget {
  final String sector;
  const _SectorBanner({required this.sector});

  @override
  Widget build(BuildContext context) {
    final color = _sectorAccent(sector);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.16), color.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(_sectorIcon(sector), color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_sectorLabel(sector),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 2),
          Text(
            _sectorTagline(sector),
            style: const TextStyle(color: AppColors.steelLight, fontSize: 11),
          ),
        ])),
      ]),
    );
  }
}

// ─── Statistika qatori ────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final double todayEarnings;
  final int totalOrders;
  final double rating;
  final bool loaded;
  const _StatsRow({
    required this.todayEarnings,
    required this.totalOrders,
    required this.rating,
    required this.loaded,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Row(children: [
      Expanded(child: _StatCard(
        icon: Icons.payments_outlined,
        iconColor: AppColors.teal,
        label: l.todayEarnings,
        value: loaded ? '${todayEarnings.toStringAsFixed(0)} ${l.soum}' : '—',
      )),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(
        icon: Icons.receipt_long_outlined,
        iconColor: AppColors.amber,
        label: l.totalOrders,
        value: loaded ? '$totalOrders' : '—',
      )),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(
        icon: Icons.star_outlined,
        iconColor: AppColors.amber,
        label: l.myRating,
        value: loaded ? (rating > 0 ? rating.toStringAsFixed(1) : '—') : '—',
      )),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelLine),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                color: AppColors.bone,
                fontWeight: FontWeight.w800,
                fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                color: AppColors.steelLight, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

// ─── Provider buyurtmalar ekrani ─────────────────────────────────────────────
class ProviderOrdersScreen extends ConsumerStatefulWidget {
  const ProviderOrdersScreen({super.key});
  @override
  ConsumerState<ProviderOrdersScreen> createState() =>
      _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState
    extends ConsumerState<ProviderOrdersScreen> {
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/providers/orders');
      if (!mounted) return;
      setState(() {
        _orders = res.data['orders'] ?? [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      final api = ref.read(apiClientProvider);
      await api.patch('/orders/$orderId/status', data: {'status': status});
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _showRoute(Map<String, dynamic> order) async {
    final pickupLat = (order['pickup_lat'] as num?)?.toDouble();
    final pickupLng = (order['pickup_lng'] as num?)?.toDouble();
    if (pickupLat == null || pickupLng == null) return;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RouteMapScreen(
          destination: LatLng(pickupLat, pickupLng),
          destinationLabel: order['client_name'] as String? ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.activeOrders)),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
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
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.amber,
                  child: _orders.isEmpty
                      ? ListView(children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.receipt_long_outlined,
                                      color: AppColors.steelLight, size: 56),
                                  const SizedBox(height: 12),
                                  Text(l.noActiveOrders,
                                      style: const TextStyle(
                                          color: AppColors.steelLight,
                                          fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Text(l.setOnlineToReceive,
                                      style: const TextStyle(
                                          color: AppColors.steel, fontSize: 12),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ),
                        ])
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _OrderCard(
                            order: _orders[i],
                            onAccept: () => _updateOrderStatus(
                                _orders[i]['id'], 'accepted'),
                            onDecline: () => _updateOrderStatus(
                                _orders[i]['id'], 'cancelled'),
                            onUpdateStatus: (s) =>
                                _updateOrderStatus(_orders[i]['id'], s),
                            onShowRoute: () => _showRoute(_orders[i]),
                          ),
                        ),
                ),
    );
  }
}

// ─── Buyurtma kartasi ─────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final void Function(String status) onUpdateStatus;
  final VoidCallback onShowRoute;
  const _OrderCard({
    required this.order,
    required this.onAccept,
    required this.onDecline,
    required this.onUpdateStatus,
    required this.onShowRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    final status = order['status'] as String? ?? 'searching';
    final isNew = status == 'searching';
    final serviceType = order['service_type'] as String? ?? '';
    final address = order['pickup_address'] as String? ?? '';
    final clientName = order['client_name'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isNew ? AppColors.amber.withOpacity(0.6) : AppColors.steelLine,
            width: isNew ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Sarlavha
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isNew ? AppColors.amber : AppColors.teal).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isNew ? '🔔 ${l.newOrderAlert}' : _statusLabel(status, l),
              style: TextStyle(
                  color: isNew ? AppColors.amber : AppColors.teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          Text(_serviceLabel(serviceType, l),
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 12)),
        ]),
        const SizedBox(height: 12),

        // Manzil
        Row(children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.amber, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(address.isNotEmpty ? address : '—',
                style: const TextStyle(color: AppColors.bone, fontSize: 13)),
          ),
        ]),

        if (clientName.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.person_outline,
                color: AppColors.steelLight, size: 16),
            const SizedBox(width: 6),
            Text(clientName,
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 12)),
          ]),
        ],

        if (isNew) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDecline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                child: Text(l.decline),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onAccept,
                child: Text(l.accept),
              ),
            ),
          ]),
        ] else ...[
          const SizedBox(height: 12),
          // Yo'nalish tugmasi (qabul qilingan va yo'lda holatlarida)
          if (status == 'accepted' || status == 'en_route') ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShowRoute,
                icon: const Icon(Icons.route_outlined, size: 16),
                label: Text(l.showRoute),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  side: const BorderSide(color: AppColors.teal),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Aktiv buyurtma uchun holat tugmalari
          Row(children: [
            if (status == 'accepted')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('en_route'),
                  icon: const Icon(Icons.place_outlined, size: 16),
                  label: Text(l.arrived),
                ),
              ),
            if (status == 'en_route')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('in_progress'),
                  icon: const Icon(Icons.play_arrow_outlined, size: 16),
                  label: Text(l.startWork),
                ),
              ),
            if (status == 'in_progress')
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onUpdateStatus('completed'),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(l.finishWork),
                ),
              ),
          ]),
        ],
      ]),
    );
  }

  String _statusLabel(String status, AppLocalizations l) {
    switch (status) {
      case 'accepted':    return l.orderAccepted;
      case 'en_route':    return l.arrived;
      case 'in_progress': return l.orderInProgress;
      case 'completed':   return l.orderCompleted;
      default:            return status;
    }
  }

  String _serviceLabel(String t, AppLocalizations l) {
    switch (t) {
      case 'tech_support': return l.serviceTechSupport;
      case 'tow_truck':    return l.serviceTowTruck;
      case 'fuel':         return l.serviceFuel;
      case 'car_wash':     return l.serviceCarWash;
      default:             return t;
    }
  }
}

// ─── Topilgan avtomobil kartasi + tarix ──────────────────────────────────────
class _VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final Map<String, dynamic>? oilAlert;
  final List<dynamic> records;
  final VoidCallback onAddRecord;

  const _VehicleInfoCard({
    required this.vehicle,
    required this.oilAlert,
    required this.records,
    required this.onAddRecord,
  });

  @override
  Widget build(BuildContext context) {
    final brand = vehicle['brand'] ?? '';
    final model = vehicle['model'] ?? '';
    final plate = vehicle['plate_number'] ?? '';
    final year = vehicle['year'];
    final currentKm = vehicle['current_odometer'] ?? 0;
    final l = AppLocalizations(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.teal.withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car_rounded,
                color: AppColors.teal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$brand $model',
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 3),
              Text(
                [
                  plate,
                  if (year != null) '$year',
                  '$currentKm km',
                ].join(' · '),
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 12),
              ),
            ]),
          ),
          const Icon(Icons.check_circle, color: AppColors.teal, size: 22),
        ]),
      ),

      if (oilAlert != null) ...[
        const SizedBox(height: 10),
        _OilAlertBanner(alert: oilAlert!),
      ],

      const SizedBox(height: 16),

      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onAddRecord,
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: Text(l.addServiceRecord),
        ),
      ),

      const SizedBox(height: 16),

      Builder(builder: (ctx) {
        final loc = AppLocalizations(ctx);
        return Row(children: [
          Text(loc.serviceHistory,
              style: const TextStyle(
                  color: AppColors.bone,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(loc.recordsCount(records.length),
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 12)),
        ]);
      }),
      const SizedBox(height: 10),

      if (records.isEmpty)
        Builder(builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.steelLine),
          ),
          child: Center(
            child: Text(AppLocalizations(ctx).noServiceHistory,
                style: const TextStyle(color: AppColors.steelLight)),
          ),
        ))
      else
        ...records.map((r) => ServiceRecordModel.fromJson(r)).map(
              (r) => _HistoryTile(record: r),
            ),
    ]);
  }
}

// ─── Moy ogohlantirish banner ─────────────────────────────────────────────────
class _OilAlertBanner extends StatelessWidget {
  final Map<String, dynamic> alert;
  const _OilAlertBanner({required this.alert});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    final isUrgent = alert['alert'] == true;
    final kmLeft = alert['km_left'] ?? 0;
    final color = isUrgent ? AppColors.danger : AppColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(isUrgent ? Icons.warning_amber_rounded : Icons.oil_barrel_outlined,
            color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            isUrgent
                ? '⚠️ ${l.oilChangeRequired} ${l.oilKmLeftUrgent(kmLeft)}'
                : '🛢️ ${l.oilChangeReminder}: ${l.oilKmLeftNormal(kmLeft)}',
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

// ─── Tarix qatori ─────────────────────────────────────────────────────────────
class _HistoryTile extends StatelessWidget {
  final ServiceRecordModel record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.steel,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build_outlined,
              color: AppColors.amber, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.serviceTypeLabel(record.serviceType),
                style: const TextStyle(
                    color: AppColors.bone,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              [
                record.serviceDate,
                '${record.odometerKm} km',
                if (record.workshopName != null) record.workshopName!,
              ].join(' · '),
              style: const TextStyle(
                  color: AppColors.steelLight, fontSize: 11),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Provider tomonidan xizmat qo'shish ──────────────────────────────────────
class _ProviderAddRecordScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehicleTitle;
  const _ProviderAddRecordScreen(
      {required this.vehicleId, required this.vehicleTitle});

  @override
  ConsumerState<_ProviderAddRecordScreen> createState() =>
      _ProviderAddRecordScreenState();
}

class _ProviderAddRecordScreenState
    extends ConsumerState<_ProviderAddRecordScreen> {
  String _serviceType = 'inspection';
  final _dateCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split('T').first);
  final _odometerCtrl = TextEditingController();
  final _workshopCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _nextKmCtrl = TextEditingController();
  bool _loading = false;

  static const _typeKeys = [
    'oil_change', 'inspection', 'tire', 'brake',
    'engine', 'battery', 'transmission', 'other',
  ];

  @override
  void initState() {
    super.initState();
    _odometerCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _odometerCtrl.dispose();
    _workshopCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    _nextKmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.amber),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() => _dateCtrl.text = d.toIso8601String().split('T').first);
    }
  }

  Future<void> _save() async {
    if (_odometerCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final user = ref.read(authProvider).user;
      await api.post(
        '/providers/vehicle-lookup/${widget.vehicleId}/service-records',
        data: {
          'service_type': _serviceType,
          'service_date': _dateCtrl.text.trim(),
          'odometer_km': int.tryParse(_odometerCtrl.text.trim()) ?? 0,
          if (_workshopCtrl.text.isNotEmpty)
            'workshop_name': _workshopCtrl.text.trim(),
          'mechanic_name': user?.fullName ?? '',
          if (_costCtrl.text.isNotEmpty)
            'cost': double.tryParse(_costCtrl.text.trim()),
          if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
          if (_serviceType == 'oil_change' && _nextKmCtrl.text.isNotEmpty)
            'next_service_km': int.tryParse(_nextKmCtrl.text.trim()),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicleTitle,
            style: const TextStyle(fontSize: 15)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l.addServiceRecord,
                style: TextStyle(
                    color: AppColors.amber.withOpacity(0.8),
                    fontSize: 12)),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.serviceType,
                style: const TextStyle(color: AppColors.steelLight, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _typeKeys.map((key) {
                final sel = _serviceType == key;
                return GestureDetector(
                  onTap: () => setState(() => _serviceType = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.amber.withOpacity(0.15)
                          : AppColors.charcoal,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? AppColors.amber : AppColors.steelLine),
                    ),
                    child: Text(l.serviceTypeLabel(key),
                        style: TextStyle(
                            color: sel ? AppColors.amber : AppColors.boneDim,
                            fontSize: 13,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _pickDate,
              child: TextField(
                controller: _dateCtrl,
                enabled: false,
                style: const TextStyle(color: AppColors.bone),
                decoration: InputDecoration(
                  labelText: l.dateLabel,
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      color: AppColors.amber),
                ),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _odometerCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                labelText: l.odometerKm,
                hintText: '45000',
                prefixIcon: const Icon(Icons.speed_outlined, color: AppColors.amber),
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 14),

            if (_serviceType == 'oil_change') ...[
              TextField(
                controller: _nextKmCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.bone),
                decoration: InputDecoration(
                  labelText: l.nextOilChangeKm,
                  hintText: '50000',
                  prefixIcon: const Icon(Icons.update, color: AppColors.amber),
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 14),
            ],

            TextField(
              controller: _workshopCtrl,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                labelText: l.workshopName,
                hintText: 'Toshkent STO',
                prefixIcon: const Icon(Icons.store_outlined,
                    color: AppColors.steelLight),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _costCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.bone),
              decoration: InputDecoration(
                labelText: l.cost,
                hintText: '85000',
                prefixIcon: const Icon(Icons.payments_outlined,
                    color: AppColors.steelLight),
                suffixText: l.soum,
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _notesCtrl,
              style: const TextStyle(color: AppColors.bone),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l.notes,
                prefixIcon: const Icon(Icons.notes, color: AppColors.steelLight),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_odometerCtrl.text.isNotEmpty && !_loading) ? _save : null,
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.asphalt))
                    : Text(l.save),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
