import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

/// API HTTP 클라이언트
///
/// Dio를 사용하여 백엔드 API와 통신합니다.
/// JWT 토큰 자동 추가, 토큰 갱신, 에러 처리 등을 제공합니다.
class ApiClient {
  late final Dio _dio;
  final StorageService _storageService = StorageService();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // 인터셉터 추가
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  /// 요청 전 처리 (JWT 토큰 자동 추가)
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 인증이 필요한 요청에 Access Token 추가
    if (!options.path.contains('/auth/login') &&
        !options.path.contains('/auth/register') &&
        !options.path.contains('/api/v1/auth/login') &&
        !options.path.contains('/api/v1/auth/register')) {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  /// 에러 처리 (401 시 토큰 갱신)
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 401 Unauthorized - 토큰 갱신 시도
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken != null) {
        try {
          // 토큰 갱신 요청
          final response = await _dio.post(
            '/api/v1/auth/refresh',
            options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          );

          if (response.statusCode == 200) {
            final data = response.data['data'];
            final newAccessToken = data['accessToken'];
            final newRefreshToken = data['refreshToken'];

            // 새 토큰 저장
            await _storageService.saveAccessToken(newAccessToken);
            await _storageService.saveRefreshToken(newRefreshToken);

            // 원래 요청 재시도
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // 토큰 갱신 실패 - 로그아웃 처리
          await _storageService.clearAll();
        }
      }
    }

    handler.next(err);
  }

  /// GET 요청
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST 요청
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT 요청
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE 요청
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
