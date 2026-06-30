import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/app_widgets.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
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
      final res = await api.get('/notifications');
      if (!mounted) return;
      setState(() {
        _items = List<Map<String, dynamic>>.from(res.data['notifications'] ?? []);
        _loading = false;
      });
      // Ko'rilgan deb belgilaymiz (xatosi e'tiborga olinmaydi)
      _markAllRead();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(apiClientProvider).post('/notifications/read-all');
      ref.read(unreadCountProvider.notifier).clear();
    } catch (_) {}
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'order_status': return Icons.receipt_long_outlined;
      case 'review':       return Icons.star_outline_rounded;
      default:             return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notifications),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.amber))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none_rounded,
                          color: AppColors.steelLight, size: 52),
                      const SizedBox(height: 12),
                      Text(l.noNotifications,
                          style: const TextStyle(color: AppColors.steelLight)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.amber,
                  backgroundColor: AppColors.charcoal,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = _items[i];
                      final unread = n['is_read'] != true;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: unread
                                  ? AppColors.amber.withOpacity(0.4)
                                  : AppColors.steelLine),
                        ),
                        child: Row(children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.amber.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_iconFor(n['type'] as String? ?? ''),
                                color: AppColors.amber, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n['title'] as String? ?? '',
                                      style: const TextStyle(
                                          color: AppColors.bone,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  if ((n['body'] as String? ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(n['body'] as String,
                                        style: const TextStyle(
                                            color: AppColors.steelLight,
                                            fontSize: 12)),
                                  ],
                                ]),
                          ),
                          if (unread)
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ]),
                      );
                    },
                  ),
                ),
    );
  }
}
