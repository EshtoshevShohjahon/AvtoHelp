import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/models/models.dart';
import '../../widgets/app_widgets.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TrackingScreen({super.key, required this.orderId});
  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _radarCtrl;
  io.Socket? _socket;
  OrderModel? _order;
  bool _sheetVisible = false;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _loadOrder();
    _connectSocket();
  }

  Future<void> _loadOrder() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get('/orders/${widget.orderId}');
      final order = OrderModel.fromJson(res.data['order']);
      if (!mounted) return;
      setState(() {
        _order = order;
        if (order.status != 'searching') {
          _found = true;
          _sheetVisible = true;
          _radarCtrl.stop();
        }
      });
    } catch (_) {}
  }

  void _connectSocket() {
    _socket = io.io(
      'http://10.0.2.2:4000',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );
    _socket!.onConnect((_) {
      _socket!.emit('join_order', widget.orderId);
    });
    _socket!.on('order_update', (data) {
      if (!mounted) return;
      setState(() {
        if (data['status'] != 'searching') {
          _found      = true;
          _sheetVisible = true;
          _radarCtrl.stop();
        }
      });
      _loadOrder();
    });
  }

  Future<void> _cancel() async {
    try {
      final api = ref.read(apiClientProvider);
      await api.patch('/orders/${widget.orderId}/status',
          data: {'status': 'cancelled', 'cancel_reason': 'Mijoz bekor qildi'});
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()),
              backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    _socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations(context);

    return Scaffold(
      body: Stack(children: [
        // Xarita foni
        Container(
          decoration: BoxDecoration(
            color: AppColors.asphalt,
            image: DecorationImage(
              image: const AssetImage('assets/map_bg.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  AppColors.asphalt.withOpacity(0.7), BlendMode.darken),
              onError: (_, __) {},
            ),
          ),
        ),

        // Grid chiziqlar (xarita o'rnida)
        CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),

        // Orqaga tugmasi
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.steelLine),
              ),
              child: const Icon(Icons.chevron_left,
                  color: AppColors.bone, size: 22),
            ),
          ),
        ),

        // Radar animatsiyasi
        if (!_found)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RadarWidget(controller: _radarCtrl),
                const SizedBox(height: 20),
                Text(l.searching,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.bone)),
                const SizedBox(height: 6),
                Text(l.searchingDesc,
                    style: const TextStyle(
                        color: AppColors.steelLight, fontSize: 13)),
              ],
            ),
          ),

        // Topildi badge
        if (_found && !_sheetVisible)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: AppColors.teal.withOpacity(0.4),
                        blurRadius: 24, spreadRadius: 4)],
                  ),
                  child: const Icon(Icons.check,
                      color: Color(0xFF06231B), size: 30),
                ),
                const SizedBox(height: 14),
                Text(l.providerFound,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.bone)),
              ],
            ),
          ),

        // Bekor qilish tugmasi (qidirilmoqda holatida)
        if (!_found)
          Positioned(
            bottom: 120,
            left: 0, right: 0,
            child: Center(
              child: OutlinedButton(
                onPressed: _cancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                child: Text(l.cancelOrder),
              ),
            ),
          ),

        // Pastki karta (provider topilganda)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          left: 0, right: 0,
          bottom: _sheetVisible ? 0 : -280,
          child: _ProviderSheet(order: _order, l: l),
        ),
      ]),
    );
  }
}

// Radar to'lqin animatsiyasi
class _RadarWidget extends StatelessWidget {
  final AnimationController controller;
  const _RadarWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, height: 150,
      child: Stack(alignment: Alignment.center, children: [
        ...List.generate(3, (i) => AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final progress = ((controller.value + i / 3) % 1.0);
            return Transform.scale(
              scale: 0.3 + progress * 1.6,
              child: Opacity(
                opacity: (1 - progress) * 0.7,
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.amber, width: 1.5),
                  ),
                ),
              ),
            );
          },
        )),
        Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
                color: AppColors.amber.withOpacity(0.4),
                blurRadius: 20)],
          ),
          child: const Icon(Icons.directions_car,
              color: Color(0xFF1A1100), size: 28),
        ),
      ]),
    );
  }
}

// Xarita grid chiziqlar
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.steelLine.withOpacity(0.4)
      ..strokeWidth = 0.5;
    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

// Pastki karta (provider ma'lumotlari + qo'ng'iroq/chat)
class _ProviderSheet extends StatelessWidget {
  final OrderModel? order;
  final AppLocalizations l;
  const _ProviderSheet({this.order, required this.l});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.steelLine)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: AppColors.steelLine,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.steel,
            child: const Icon(Icons.person_outline,
                color: AppColors.boneDim, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sardor A.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.star, color: AppColors.amber, size: 13),
                const SizedBox(width: 3),
                const Text('4.9 · Texnik usta',
                    style: TextStyle(
                        color: AppColors.boneDim, fontSize: 12)),
              ]),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(l.etaMinutes(8),
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal)),
            Text(l.providerEnRoute.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.steelLight, fontSize: 10,
                    letterSpacing: 0.5)),
          ]),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone_outlined, size: 16),
              label: Text(l.call),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.chat_bubble_outline, size: 16,
                  color: Color(0xFF1A1100)),
              label: Text(l.chat),
            ),
          ),
        ]),
      ]),
    );
  }
}
