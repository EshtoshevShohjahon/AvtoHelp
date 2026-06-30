import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/network/api_client.dart';
import '../auth/auth_provider.dart';

// O'qilmagan bildirishnomalar sonini boshqaradi: REST orqali yuklaydi va
// socket orqali jonli yangilab turadi (user_<id> xonasiga qo'shilib).
class NotificationsController extends StateNotifier<int> {
  final Ref ref;
  io.Socket? _socket;
  String? _userId;

  NotificationsController(this.ref) : super(0) {
    _bootstrap();
    // Foydalanuvchi o'zgarganda (login/logout) qayta ulanamiz
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.user?.id != next.user?.id) {
        _bootstrap();
      }
    });
  }

  Future<void> _bootstrap() async {
    final user = ref.read(authProvider).user;
    _userId = user?.id;
    if (_userId == null) {
      _disconnect();
      state = 0;
      return;
    }
    await refresh();
    _connect();
  }

  Future<void> refresh() async {
    try {
      final res =
          await ref.read(apiClientProvider).get('/notifications/unread-count');
      state = (res.data['count'] as num?)?.toInt() ?? 0;
    } catch (_) {}
  }

  void _connect() {
    _disconnect();
    final id = _userId;
    if (id == null) return;
    _socket = io.io(
      kSocketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .build(),
    );
    _socket!.onConnect((_) => _socket!.emit('join_user', id));
    _socket!.on('notification', (_) => state = state + 1);
    _socket!.on('new_order', (_) => state = state + 1);
  }

  void _disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  // Bildirishnomalar o'qilganda chaqiriladi
  void clear() => state = 0;

  @override
  void dispose() {
    _disconnect();
    super.dispose();
  }
}

final unreadCountProvider =
    StateNotifierProvider<NotificationsController, int>((ref) {
  return NotificationsController(ref);
});
