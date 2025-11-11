/// API 설정
///
/// 백엔드 API의 기본 URL 및 설정을 관리합니다.
class ApiConfig {
  /// 개발 환경 API URL
  /// 로컬 개발: http://localhost:8080
  /// 안드로이드 에뮬레이터: http://10.0.2.2:8080
  /// iOS 시뮬레이터: http://localhost:8080
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// API 엔드포인트
  static const String auth = '/auth';
  static const String babies = '/babies';
  static const String community = '/community';

  /// 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// 헤더
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
