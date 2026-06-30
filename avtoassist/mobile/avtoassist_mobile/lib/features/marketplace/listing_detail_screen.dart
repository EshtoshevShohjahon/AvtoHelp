import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  final String listingId;
  final Map<String, dynamic>? initialData;
  const ListingDetailScreen({super.key, required this.listingId, this.initialData});

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  Map<String, dynamic>? _listing;
  bool _loading = true;
  int _imageIndex = 0;
  bool _favorited = false;

  Future<void> _toggleFavorite() async {
    final prev = _favorited;
    setState(() => _favorited = !prev); // optimistik
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.dio.post('/marketplace/${widget.listingId}/favorite');
      if (mounted) {
        setState(() => _favorited = res.data['favorited'] == true);
      }
    } catch (_) {
      if (mounted) setState(() => _favorited = prev); // qaytarish
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _listing = widget.initialData;
      _loading = false;
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/marketplace/${widget.listingId}');
      if (!mounted) return;
      setState(() {
        _listing = Map<String, dynamic>.from(res.data['listing'] ?? {});
        _favorited = _listing?['is_favorited'] == true;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    if (_loading && _listing == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.amber)),
      );
    }
    if (_listing == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => context.pop())),
        body: Center(child: Text(l.noListings, style: const TextStyle(color: AppColors.steelLight))),
      );
    }

    final listing = _listing!;
    final images = List<String>.from(listing['images'] ?? []);
    final provider = listing['provider'] as Map<String, dynamic>?;
    final bizName = provider?['business_name'] as String? ?? '';
    final address = provider?['address'] as String? ?? '';
    final rating = (provider?['rating'] as num?)?.toStringAsFixed(1) ?? '';
    final priceType = listing['price_type'] ?? 'fixed';
    final price = listing['price'];
    final priceStr = priceType == 'negotiable'
        ? l.negotiable
        : '${priceType == 'from' ? '${l.fromPrice} ' : ''}${_fmtNum(price)} ${listing['price_unit'] ?? 'so\'m'}';

    return Scaffold(
      appBar: AppBar(
        title: Text(listing['title'] ?? ''),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _favorited ? Icons.favorite : Icons.favorite_border,
              color: _favorited ? AppColors.danger : AppColors.bone,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image gallery
          if (images.isNotEmpty)
            Stack(children: [
              SizedBox(
                height: 280,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _imageIndex = i),
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.charcoal,
                      child: const Center(
                          child: Icon(Icons.image_outlined,
                              color: AppColors.steelLight, size: 48)),
                    ),
                  ),
                ),
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _imageIndex == i ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _imageIndex == i ? AppColors.amber : AppColors.steelLine,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ),
            ])
          else
            Container(
              height: 220,
              color: AppColors.charcoal,
              child: const Center(
                  child: Icon(Icons.image_outlined,
                      color: AppColors.steelLight, size: 64)),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Type badge
              Row(children: [
                _Badge(_typeLabel(listing['listing_type'], l)),
                const SizedBox(width: 8),
                _Badge(_vehicleLabel(listing['vehicle_category'], l),
                    color: AppColors.teal),
              ]),
              const SizedBox(height: 12),
              Text(listing['title'] ?? '',
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.2)),
              const SizedBox(height: 14),
              // Price — prominent card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: priceType == 'negotiable'
                        ? [AppColors.teal.withOpacity(0.18), AppColors.teal.withOpacity(0.05)]
                        : [AppColors.amber.withOpacity(0.18), AppColors.amber.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: (priceType == 'negotiable' ? AppColors.teal : AppColors.amber)
                          .withOpacity(0.35)),
                ),
                child: Row(children: [
                  Icon(
                    priceType == 'negotiable'
                        ? Icons.handshake_outlined
                        : Icons.sell_outlined,
                    color: priceType == 'negotiable' ? AppColors.teal : AppColors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(priceStr,
                        style: TextStyle(
                            color: priceType == 'negotiable'
                                ? AppColors.teal
                                : AppColors.amber,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5)),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              if ((listing['description'] as String? ?? '').isNotEmpty) ...[
                Text(l.description,
                    style: const TextStyle(
                        color: AppColors.steelLight,
                        fontSize: 11,
                        letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(listing['description'] ?? '',
                    style: const TextStyle(
                        color: AppColors.bone, fontSize: 14, height: 1.5)),
                const SizedBox(height: 20),
              ],
              // Provider info
              if (bizName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.steelLine),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.seller.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.steelLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.amberGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.glow(AppColors.amber),
                        ),
                        child: const Icon(Icons.storefront,
                            color: Color(0xFF1A1100), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bizName,
                                style: const TextStyle(
                                    color: AppColors.bone,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            if (address.isNotEmpty)
                              Text(address,
                                  style: const TextStyle(
                                      color: AppColors.steelLight,
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                          ])),
                      if (rating.isNotEmpty)
                        Row(children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.amber, size: 16),
                          Text(rating,
                              style: const TextStyle(
                                  color: AppColors.amber,
                                  fontWeight: FontWeight.bold)),
                        ]),
                    ]),
                  ]),
                ),
                const SizedBox(height: 20),
              ],
              // Views
              Row(children: [
                const Icon(Icons.remove_red_eye_outlined,
                    color: AppColors.steelLight, size: 14),
                const SizedBox(width: 4),
                Text('${listing['views'] ?? 0} ta ko\'rishlar',
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 12)),
              ]),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton.icon(
            onPressed: () => _showContact(context, provider, l),
            icon: const Icon(Icons.phone_outlined),
            label: Text(l.contactSeller),
          ),
        ),
      ),
    );
  }

  void _showContact(BuildContext context, Map<String, dynamic>? provider,
      AppLocalizations l) {
    final phone = provider?['phone'] as String? ?? '';
    final name = provider?['business_name'] as String? ?? '';
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.phoneUnavailable),
            backgroundColor: AppColors.danger),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.steelLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 12),
            if (name.isNotEmpty)
              Text(name,
                  style: const TextStyle(
                      color: AppColors.bone,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(phone,
                style: const TextStyle(
                    color: AppColors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final uri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                icon: const Icon(Icons.phone, size: 18),
                label: Text(l.callNow),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phone));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(l.phoneCopied),
                        backgroundColor: AppColors.teal),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(l.copyNumber),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _typeLabel(String? t, AppLocalizations l) {
    switch (t) {
      case 'service': return l.marketplaceServices;
      case 'part':    return l.marketplaceParts;
      case 'oil':     return l.marketplaceOil;
      case 'tire':    return l.marketplaceTire;
      default:        return t ?? '';
    }
  }

  String _vehicleLabel(String? v, AppLocalizations l) {
    switch (v) {
      case 'light': return l.lightCar;
      case 'truck': return l.truckSection;
      default:      return l.all;
    }
  }

  String _fmtNum(dynamic n) {
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, {this.color = AppColors.amber});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Text(label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}
