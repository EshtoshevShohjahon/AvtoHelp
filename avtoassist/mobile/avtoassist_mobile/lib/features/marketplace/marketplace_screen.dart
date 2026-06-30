import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;
  String _vehicleCat = 'all';
  String _listingType = 'all';
  final _searchCtrl = TextEditingController();
  String _q = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    setState(() => _q = v);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final query = <String, dynamic>{};
      if (_vehicleCat != 'all') query['vehicle_category'] = _vehicleCat;
      if (_listingType != 'all') query['listing_type'] = _listingType;
      if (_q.isNotEmpty) query['q'] = _q;
      final res = await api.get('/marketplace', query: query);
      if (!mounted) return;
      setState(() {
        _listings = List<Map<String, dynamic>>.from(res.data['listings'] ?? []);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.marketplace),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.danger),
            onPressed: () => context.push('/marketplace/favorites'),
          ),
        ],
      ),
      body: Column(children: [
        Container(height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.amber, AppColors.amber.withOpacity(0)]),
            )),
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppColors.bone),
            decoration: InputDecoration(
              hintText: l.marketplaceSearch,
              prefixIcon: const Icon(Icons.search, color: AppColors.steelLight),
              suffixIcon: _q.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.steelLight),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _q = '');
                        _load();
                      })
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            _FilterChip(l.all, _vehicleCat == 'all' && _listingType == 'all',
                () { setState(() { _vehicleCat = 'all'; _listingType = 'all'; }); _load(); }),
            const SizedBox(width: 8),
            _FilterChip(l.lightCar, _vehicleCat == 'light',
                () { setState(() { _vehicleCat = 'light'; }); _load(); }),
            const SizedBox(width: 8),
            _FilterChip(l.truckSection, _vehicleCat == 'truck',
                () { setState(() { _vehicleCat = 'truck'; }); _load(); }),
            const SizedBox(width: 8),
            _FilterChip(l.marketplaceServices, _listingType == 'service',
                () { setState(() { _listingType = 'service'; _vehicleCat = 'all'; }); _load(); }),
            const SizedBox(width: 8),
            _FilterChip(l.marketplaceParts, _listingType == 'part',
                () { setState(() { _listingType = 'part'; _vehicleCat = 'all'; }); _load(); }),
            const SizedBox(width: 8),
            _FilterChip(l.marketplaceOil, _listingType == 'oil',
                () { setState(() { _listingType = 'oil'; _vehicleCat = 'all'; }); _load(); }),
            const SizedBox(width: 8),
            _FilterChip(l.marketplaceTire, _listingType == 'tire',
                () { setState(() { _listingType = 'tire'; _vehicleCat = 'all'; }); _load(); }),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
              : _listings.isEmpty
                  ? Center(child: Text(l.noListings,
                      style: const TextStyle(color: AppColors.steelLight)))
                  : RefreshIndicator(
                      color: AppColors.amber,
                      backgroundColor: AppColors.charcoal,
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _listings.length,
                        itemBuilder: (_, i) => _ListingCard(
                          listing: _listings[i],
                          onTap: () => context.push(
                            '/marketplace/${_listings[i]['id']}',
                            extra: _listings[i],
                          ),
                        ),
                      ),
                    ),
        ),
      ]),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.amber : AppColors.charcoal,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: selected ? AppColors.amber : AppColors.steelLine),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              color: selected ? const Color(0xFF1A1100) : AppColors.boneDim,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
    ),
  );
}

// ─── Sevimlilar ekrani ────────────────────────────────────────────
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});
  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Map<String, dynamic>> _listings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/marketplace/favorites');
      if (!mounted) return;
      setState(() {
        _listings = List<Map<String, dynamic>>.from(res.data['listings'] ?? []);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.favorites),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
          : _listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite_border,
                          color: AppColors.steelLight, size: 48),
                      const SizedBox(height: 12),
                      Text(l.noFavorites,
                          style: const TextStyle(color: AppColors.steelLight)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.amber,
                  backgroundColor: AppColors.charcoal,
                  onRefresh: _load,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: _listings.length,
                    itemBuilder: (_, i) => _ListingCard(
                      listing: _listings[i],
                      onTap: () async {
                        await context.push(
                          '/marketplace/${_listings[i]['id']}',
                          extra: _listings[i],
                        );
                        _load(); // qaytganda yangilash (sevimli o'zgargan bo'lishi mumkin)
                      },
                    ),
                  ),
                ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onTap;
  const _ListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(listing['images'] ?? []);
    final price = listing['price'];
    final priceType = listing['price_type'] ?? 'fixed';
    final provider = listing['provider'] as Map<String, dynamic>?;
    final bizName = provider?['business_name'] as String? ?? '';
    final rating = (provider?['rating'] as num?)?.toStringAsFixed(1) ?? '';

    String priceLabel = '';
    if (priceType == 'from') priceLabel = 'dan ';
    if (priceType == 'negotiable') priceLabel = '';

    final priceStr = priceType == 'negotiable'
        ? 'Kelishuv'
        : '$priceLabel${_formatNum(price)} so\'m';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.steelLine),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image + narx badge
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: images.isNotEmpty
                    ? Image.network(
                        images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            // Narx badge — rasmning ustida
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: priceType == 'negotiable'
                      ? AppColors.teal
                      : AppColors.amber,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(priceStr,
                    style: const TextStyle(
                        color: Color(0xFF1A1100),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5)),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(listing['title'] ?? '',
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.25),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              if (bizName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.storefront_outlined,
                      color: AppColors.steelLight, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(bizName,
                        style: const TextStyle(
                            color: AppColors.steelLight, fontSize: 10.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (rating.isNotEmpty) ...[
                    const Icon(Icons.star_rounded,
                        color: AppColors.amber, size: 12),
                    const SizedBox(width: 1),
                    Text(rating,
                        style: const TextStyle(
                            color: AppColors.amber,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600)),
                  ]
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.steel,
    child: const Center(
        child: Icon(Icons.image_outlined,
            color: AppColors.steelLight, size: 36)),
  );

  String _formatNum(dynamic n) {
    if (n == null) return '';
    final num v = n is num ? n : num.tryParse(n.toString()) ?? 0;
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
