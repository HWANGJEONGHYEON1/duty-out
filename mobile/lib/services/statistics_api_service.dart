import 'api_client.dart';

/// 통계 API 서비스
///
/// 주간/월간 통계 데이터를 조회합니다.
class StatisticsApiService {
  final ApiClient _apiClient = ApiClient();

  /// 주간 통계 조회
  ///
  /// 최근 7일간의 수면 및 수유 통계를 조회합니다.
  ///
  /// [babyId] 아기 ID
  Future<Map<String, dynamic>> getWeeklyStatistics({
    required int babyId,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/babies/$babyId/sleep-records/statistics/weekly',
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('주간 통계 조회 실패: ${response.statusCode}');
  }

  /// 월간 통계 조회
  ///
  /// 이번 달의 수면 및 수유 통계를 조회합니다.
  ///
  /// [babyId] 아기 ID
  Future<Map<String, dynamic>> getMonthlyStatistics({
    required int babyId,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/babies/$babyId/sleep-records/statistics/monthly',
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('월간 통계 조회 실패: ${response.statusCode}');
  }
}
