import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';

/// ApiClient'ning global Riverpod provideri (butun ilova shu yagona nusxadan foydalanadi)
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:4000/api', // Android emulator -> localhost
);

const kSocketUrl = String.fromEnvironment(
  'SOCKET_URL',
  defaultValue: 'http://10.0.2.2:4000',
);

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LangInterceptor(),
      _RefreshInterceptor(_dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) =>
      _dio.get(path, queryParameters: query);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

/// Har bir so'rovga Bearer token qo'shadi
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.read('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Har bir so'rovga ?lang= parametrini qo'shadi
class _LangInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final lang = await SecureStorage.read('app_lang') ?? 'uz';
    options.queryParameters['lang'] = lang;
    handler.next(options);
  }
}

/// 401 bo'lsa, refresh token orqali access tokenni avtomatik yangilaydi va
/// so'rovni qayta yuboradi. Shu tufayli foydalanuvchi har safar login qilmaydi.
class _RefreshInterceptor extends Interceptor {
  final Dio _dio;
  _RefreshInterceptor(this._dio);

  static bool _refreshing = false;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthCall = err.requestOptions.path.contains('/auth/');
    if (err.response?.statusCode != 401 ||
        isAuthCall ||
        err.requestOptions.extra['retried'] == true) {
      return handler.next(err);
    }

    final refreshToken = await SecureStorage.read('refresh_token');
    if (refreshToken == null) return handler.next(err);

    try {
      if (_refreshing) return handler.next(err);
      _refreshing = true;

      final refreshDio = Dio(BaseOptions(baseUrl: _kBaseUrl));
      final res = await refreshDio.post('/auth/refresh',
          data: {'refreshToken': refreshToken});

      await SecureStorage.write('access_token', res.data['accessToken']);
      await SecureStorage.write('refresh_token', res.data['refreshToken']);
      _refreshing = false;

      // Asl so'rovni yangi token bilan qayta yuboramiz
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${res.data['accessToken']}';
      opts.extra['retried'] = true;
      final retried = await _dio.fetch(opts);
      return handler.resolve(retried);
    } catch (_) {
      _refreshing = false;
      // Refresh ham ishlamadi — sessiya tugagan, tokenlarni tozalaymiz
      await SecureStorage.delete('access_token');
      await SecureStorage.delete('refresh_token');
      return handler.next(err);
    }
  }
}
