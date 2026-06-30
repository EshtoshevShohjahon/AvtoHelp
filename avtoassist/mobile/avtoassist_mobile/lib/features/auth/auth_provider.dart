import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/models/models.dart';

// ─── Auth state ──────────────────────────────────────────
enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;
  AuthNotifier(this._api) : super(const AuthState()) {
    _init();
  }

  // Ilova ochilganda: agar saqlangan sessiya bo'lsa, qayta login so'ramaymiz.
  // Access token muddati o'tgan bo'lsa, refresh token orqali yangilaymiz.
  Future<void> _init() async {
    String? token;
    String? refresh;
    try {
      token = await SecureStorage.read('access_token');
      refresh = await SecureStorage.read('refresh_token');
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    if (token == null && refresh == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final res = await _api.get('/users/me');
      final user = UserModel.fromJson(res.data['user']);
      await SecureStorage.write('user_role', user.role);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      // Faqat refresh ham ishlamasagina chiqaramiz (ApiClient 401'da
      // avtomatik refresh qiladi). Aks holda sessiya saqlanib qoladi.
      final stillValid = await SecureStorage.read('access_token') != null;
      if (stillValid) {
        try {
          final res = await _api.get('/users/me');
          final user = UserModel.fromJson(res.data['user']);
          await SecureStorage.write('user_role', user.role);
          state = state.copyWith(status: AuthStatus.authenticated, user: user);
          return;
        } catch (_) {}
      }
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<String?> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post('/auth/send-otp', data: {'phone': phone});
      state = state.copyWith(isLoading: false);
      return res.data['debug_code']; // null bo'ladi productionda
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return null;
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String code,
    String role = 'client',
    String lang = 'uz',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.post('/auth/verify-otp', data: {
        'phone': phone,
        'code': code,
        'role': role,
        'preferred_language': lang,
      });
      await SecureStorage.write('access_token', res.data['accessToken']);
      await SecureStorage.write('refresh_token', res.data['refreshToken']);
      final user = UserModel.fromJson(res.data['user']);
      await SecureStorage.write('user_role', user.role);
      state = state.copyWith(
          status: AuthStatus.authenticated, user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? role,
    String? avatarUrl,
    String? sector,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (role != null) body['role'] = role;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;
      if (sector != null) body['sector'] = sector;
      final res = await _api.patch('/users/me', data: body);
      final user = UserModel.fromJson(res.data['user']);
      await SecureStorage.write('user_role', user.role);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  Future<void> logout() async {
    final token = await SecureStorage.read('refresh_token');
    try {
      await _api.post('/auth/logout', data: {'refreshToken': token});
    } catch (_) {}
    await SecureStorage.deleteAll();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _parseError(dynamic e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return e.toString();
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});
