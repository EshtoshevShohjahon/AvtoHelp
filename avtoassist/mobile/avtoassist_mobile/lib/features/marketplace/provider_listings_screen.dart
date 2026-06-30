import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';

class ProviderListingsScreen extends ConsumerStatefulWidget {
  const ProviderListingsScreen({super.key});
  @override
  ConsumerState<ProviderListingsScreen> createState() =>
      _ProviderListingsScreenState();
}

class _ProviderListingsScreenState
    extends ConsumerState<ProviderListingsScreen> {
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
      final res = await api.get('/marketplace/my');
      if (!mounted) return;
      setState(() {
        _listings =
            List<Map<String, dynamic>>.from(res.data['listings'] ?? []);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> listing) async {
    final l = AppLocalizations(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text(l.confirmDelete,
            style: const TextStyle(color: AppColors.bone)),
        content: Text(listing['title'] ?? '',
            style: const TextStyle(color: AppColors.steelLight)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel,
                  style: const TextStyle(color: AppColors.steelLight))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete,
                  style: const TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.delete('/marketplace/${listing['id']}');
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.myListings),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.amber),
            onPressed: () async {
              final added =
                  await context.push<bool>('/marketplace/add');
              if (added == true) _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amber,
        onPressed: () async {
          final added = await context.push<bool>('/marketplace/add');
          if (added == true) _load();
        },
        child: const Icon(Icons.add, color: AppColors.asphalt),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.amber))
          : _listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store_outlined,
                          color: AppColors.steelLight, size: 48),
                      const SizedBox(height: 12),
                      Text(l.noListings,
                          style: const TextStyle(
                              color: AppColors.steelLight)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final added = await context
                              .push<bool>('/marketplace/add');
                          if (added == true) _load();
                        },
                        child: Text(l.addListing),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.amber,
                  backgroundColor: AppColors.charcoal,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _listings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = _listings[i];
                      final images =
                          List<String>.from(item['images'] ?? []);
                      final isActive = item['is_active'] as bool? ?? true;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.steelLine),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Row(children: [
                          // Thumbnail
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(13)),
                            child: SizedBox(
                              width: 90,
                              height: 90,
                              child: images.isNotEmpty
                                  ? Image.network(images.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                              color: AppColors.steel,
                                              child: const Icon(
                                                  Icons.image_outlined,
                                                  color:
                                                      AppColors.steelLight)))
                                  : Container(
                                      color: AppColors.steel,
                                      child: const Icon(
                                          Icons.image_outlined,
                                          color: AppColors.steelLight)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                        child: Text(
                                            item['title'] ?? '',
                                            style: const TextStyle(
                                                color: AppColors.bone,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.teal
                                              : AppColors.steelLine,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${_fmtNum(item['price'])} so\'m',
                                        style: const TextStyle(
                                            color: AppColors.amber,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      Text(
                                          '${item['views'] ?? 0} ko\'rish',
                                          style: const TextStyle(
                                              color: AppColors.steelLight,
                                              fontSize: 11)),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.steelLight,
                                            size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            minWidth: 28, minHeight: 28),
                                        onPressed: () async {
                                          final updated =
                                              await context.push<bool>(
                                            '/marketplace/edit/${item['id']}',
                                            extra: item,
                                          );
                                          if (updated == true) _load();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline,
                                            color: AppColors.danger,
                                            size: 18),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                            minWidth: 28, minHeight: 28),
                                        onPressed: () => _delete(item),
                                      ),
                                    ]),
                                  ]),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
    );
  }

  String _fmtNum(dynamic n) {
    if (n == null) return '0';
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
