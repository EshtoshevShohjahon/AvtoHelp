import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

const _kBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:4000/api');

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.addAll([_AuthInterceptor(), _LangInterceptor(), LogInterceptor(requestBody: true, responseBody: true)]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) => _dio.get(path, queryParameters: query);
  Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);
  Future<Response> patch(String path, {dynamic data}) => _dio.patch(path, data: data);
  Future<Response> delete(String path) => _dio.delete(path);
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.read('access_token');
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}

class _LangInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final lang = await SecureStorage.read('app_lang') ?? 'uz';
    options.queryParameters['lang'] = lang;
    handler.next(options);
  }
}
