import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/models/models.dart';
import '../../widgets/app_widgets.dart';

// ─── Ehtiyot qismlar do'konlari ──────────────────────────────
class PartsScreen extends ConsumerStatefulWidget {
  const PartsScreen({super.key});
  @override
  ConsumerState<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends ConsumerState<PartsScreen> {
  List<PartsStoreModel> _stores = [];
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
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition();
      } catch (_) {}
      final lat = pos?.latitude  ?? 41.2995;
      final lng = pos?.longitude ?? 69.2401;
      final api = ref.read(apiClientProvider);
      final res = await api.get('/parts-stores/nearby',
          query: {'lat': lat, 'lng': lng, 'radius': 25});
      final list = (res.data['stores'] as List)
          .map((e) => PartsStoreModel.fromJson(e))
          .toList();
      if (!mounted) return;
      setState(() { _stores = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.nearbyStores)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
            : _error != null
                ? _ErrorView(error: _error!, onRetry: _load, l: l)
                : _stores.isEmpty
                    ? Center(child: Text(l.noOrdersYet,
                        style: const TextStyle(color: AppColors.steelLight)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _stores.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _StoreCard(store: _stores[i], l: l),
                      ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final PartsStoreModel store;
  final AppLocalizations l;
  const _StoreCard({required this.store, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.store_outlined, color: AppColors.amber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(store.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14))),
              Text(l.distance(store.distanceKm),
                  style: const TextStyle(
                      color: AppColors.steelLight,
                      fontFamily: 'monospace',
                      fontSize: 12)),
            ]),
            if (store.address != null) ...[
              const SizedBox(height: 3),
              Text(store.address!,
                  style: const TextStyle(
                      color: AppColors.boneDim, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            const _TagRow(tags: ['Mavjud', 'Ehtiyot qismlar']),
          ]),
        ),
      ]),
    );
  }
}

// ─── Ustaxonalar ───────────────────────────────────────
class WorkshopsScreen extends ConsumerStatefulWidget {
  const WorkshopsScreen({super.key});
  @override
  ConsumerState<WorkshopsScreen> createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends ConsumerState<WorkshopsScreen> {
  List<WorkshopModel> _workshops = [];
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
      Position? pos;
      try { pos = await Geolocator.getCurrentPosition(); } catch (_) {}
      final lat = pos?.latitude  ?? 41.2995;
      final lng = pos?.longitude ?? 69.2401;
      final api = ref.read(apiClientProvider);
      final res = await api.get('/workshops/nearby',
          query: {'lat': lat, 'lng': lng, 'radius': 25});
      final list = (res.data['workshops'] as List)
          .map((e) => WorkshopModel.fromJson(e))
          .toList();
      if (!mounted) return;
      setState(() { _workshops = list; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.nearbyWorkshops)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
            : _error != null
                ? _ErrorView(error: _error!, onRetry: _load, l: l)
                : _workshops.isEmpty
                    ? Center(child: Text(l.noOrdersYet,
                        style: const TextStyle(color: AppColors.steelLight)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _workshops.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _WorkshopCard(w: _workshops[i], l: l),
                      ),
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final WorkshopModel w;
  final AppLocalizations l;
  const _WorkshopCard({required this.w, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.steelLine),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.precision_manufacturing_outlined,
              color: AppColors.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(w.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14))),
              Text(l.distance(w.distanceKm),
                  style: const TextStyle(
                      color: AppColors.steelLight,
                      fontFamily: 'monospace',
                      fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star, color: AppColors.amber, size: 13),
              const SizedBox(width: 3),
              Text('${w.ratingAvg.toStringAsFixed(1)} (${w.ratingCount})',
                  style: const TextStyle(
                      color: AppColors.boneDim, fontSize: 12)),
            ]),
            if (w.specializations.isNotEmpty) ...[
              const SizedBox(height: 8),
              _TagRow(tags: w.specializations.take(3).toList()),
            ],
          ]),
        ),
      ]),
    );
  }
}

// ─── Yordamchi widgetlar ───────────────────────────────────
class _TagRow extends StatelessWidget {
  final List<String> tags;
  const _TagRow({required this.tags});
  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, children: tags.map((t) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.steel,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(t,
          style: const TextStyle(
              color: AppColors.boneDim, fontSize: 10.5)),
    )).toList());
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final AppLocalizations l;
  const _ErrorView({required this.error, required this.onRetry, required this.l});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off_outlined,
              color: AppColors.steelLight, size: 48),
          const SizedBox(height: 16),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.steelLight)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: Text(l.retry)),
        ]),
      ),
    );
  }
}
