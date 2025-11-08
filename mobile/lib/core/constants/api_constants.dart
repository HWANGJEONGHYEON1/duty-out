/// API 상수
class ApiConstants {
  ApiConstants._();

  /// 기본 URL (개발)
  static const String baseUrl = 'http://localhost:8080';

  /// API 버전
  static const String apiVersion = 'v1';

  /// Endpoints
  static const String babies = '/api/$apiVersion/babies';
  static const String schedules = '/schedules';
  static const String sleepRecords = '/sleep-records';
  static const String auth = '/api/$apiVersion/auth';

  /// Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
