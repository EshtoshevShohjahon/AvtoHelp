import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

// Mijoz ustani tanlashdan oldin uning statistikasi bilan tanishadi.
class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;
  final String? name;
  const ProviderProfileScreen({super.key, required this.providerId, this.name});

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState
    extends ConsumerState<ProviderProfileScreen> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _reviews = [];
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
      final results = await Future.wait([
        api.get('/providers/${widget.providerId}/stats'),
        api.get('/marketplace/provider/${widget.providerId}/reviews'),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = Map<String, dynamic>.from(results[0].data);
        _reviews = List<Map<String, dynamic>>.from(
            results[1].data['reviews'] ?? []);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.providerStatistics),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
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
              : _buildBody(l),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    final stats = _stats!;
    final provider = stats['provider'] as Map<String, dynamic>? ?? {};
    final name = provider['name'] as String? ?? widget.name ?? '';
    final sector = provider['sector'] as String?;
    final rating = (provider['rating'] as num?)?.toDouble() ?? 0;
    final ratingCount = (provider['rating_count'] as num?)?.toInt() ?? 0;
    final isVerified = provider['is_verified'] == true;
    final isOnline = provider['is_online'] == true;
    final totalServices = (stats['total_services'] as num?)?.toInt() ?? 0;
    final vehicles = (stats['serviced_vehicles_count'] as num?)?.toInt() ?? 0;
    final orders = (stats['completed_orders'] as num?)?.toInt() ?? 0;
    final breakdown =
        Map<String, dynamic>.from(stats['service_breakdown'] ?? {});
    final recent = stats['recent_services'] as List<dynamic>? ?? [];

    final entries = breakdown.entries.toList()
      ..sort((a, b) => (b.value as num).compareTo(a.value as num));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.steelLine),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.amberGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.glow(AppColors.amber),
              ),
              child: const Icon(Icons.storefront,
                  color: Color(0xFF1A1100), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(name,
                            style: const TextStyle(
                                color: AppColors.bone,
                                fontWeight: FontWeight.w800,
                                fontSize: 18),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified,
                            color: AppColors.teal, size: 18),
                      ],
                    ]),
                    if (sector != null)
                      Text(_sectorLabel(sector),
                          style: const TextStyle(
                              color: AppColors.amber, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        rating > 0
                            ? '${rating.toStringAsFixed(1)} ($ratingCount)'
                            : '—',
                        style: const TextStyle(
                            color: AppColors.steelLight, fontSize: 13),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? AppColors.teal
                              : AppColors.steelLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(isOnline ? l.statusActive : l.statusResting,
                          style: const TextStyle(
                              color: AppColors.steelLight, fontSize: 12)),
                    ]),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Statistika qatori
        Row(children: [
          Expanded(child: _StatBox(
              value: '$totalServices', label: l.servicesCount,
              icon: Icons.build_outlined, color: AppColors.amber)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(
              value: '$vehicles', label: l.servicedVehicles,
              icon: Icons.directions_car_outlined, color: AppColors.teal)),
          const SizedBox(width: 10),
          Expanded(child: _StatBox(
              value: '$orders', label: l.completedOrders,
              icon: Icons.receipt_long_outlined, color: AppColors.amber)),
        ]),

        if (totalServices == 0) ...[
          const SizedBox(height: 40),
          Center(
            child: Column(children: [
              const Icon(Icons.insights_outlined,
                  color: AppColors.steelLine, size: 56),
              const SizedBox(height: 12),
              Text(l.noStatistics,
                  style: const TextStyle(color: AppColors.steelLight)),
            ]),
          ),
        ],

        // Xizmat turlari taqsimoti
        if (entries.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l.servicesRendered,
              style: const TextStyle(
                  color: AppColors.bone,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entries.map((e) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                ),
                child: Text('${l.serviceTypeLabel(e.key)} · ${e.value}',
                    style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        ],

        // So'nggi xizmatlar
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l.recentServices,
              style: const TextStyle(
                  color: AppColors.bone,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...recent.map((s) {
            final m = s as Map<String, dynamic>;
            final year = m['year'];
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
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.directions_car_outlined,
                      color: AppColors.boneDim, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${m['vehicle'] ?? '—'}'
                          '${year != null ? ' · $year' : ''}',
                          style: const TextStyle(
                              color: AppColors.bone,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${l.serviceTypeLabel(m['service_type'] as String? ?? 'other')} · ${m['service_date'] ?? ''}',
                          style: const TextStyle(
                              color: AppColors.steelLight, fontSize: 11),
                        ),
                      ]),
                ),
              ]),
            );
          }),
        ],

        // Sharhlar
        const SizedBox(height: 20),
        Text(l.reviews,
            style: const TextStyle(
                color: AppColors.bone,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        if (_reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(l.noReviews,
                  style: const TextStyle(color: AppColors.steelLight)),
            ),
          )
        else
          ..._reviews.map((r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.steelLine),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(r['author'] as String? ?? '',
                            style: const TextStyle(
                                color: AppColors.bone,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        const Spacer(),
                        Row(children: List.generate(5, (i) {
                          final filled =
                              i < ((r['rating'] as num?)?.toInt() ?? 0);
                          return Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.amber,
                            size: 14,
                          );
                        })),
                      ]),
                      if ((r['comment'] as String? ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(r['comment'] as String,
                            style: const TextStyle(
                                color: AppColors.steelLight, fontSize: 12)),
                      ],
                    ]),
              )),
        const SizedBox(height: 24),
      ],
    );
  }
}

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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
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
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                color: AppColors.bone,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.steelLight, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
