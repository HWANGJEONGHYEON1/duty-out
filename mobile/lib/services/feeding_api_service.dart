import 'api_client.dart';

/// 수유 기록 API 서비스
///
/// 수유 기록의 CRUD 및 통계 조회 API를 제공합니다.
class FeedingApiService {
  final ApiClient _apiClient = ApiClient();

  /// 수유 기록 생성
  ///
  /// [babyId] 아기 ID
  /// [feedingTime] 수유 시간 (ISO 8601 형식)
  /// [type] 수유 유형 (BREAST, BOTTLE, SOLID)
  /// [amountMl] 수유량 (ml)
  /// [note] 메모
  Future<Map<String, dynamic>> createFeedingRecord({
    required int babyId,
    required String feedingTime,
    required String type,
    int? amountMl,
    String? note,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/babies/$babyId/feeding-records',
      data: {
        'feedingTime': feedingTime,
        'type': type,
        if (amountMl != null) 'amountMl': amountMl,
        if (note != null) 'note': note,
      },
    );

    if (response.statusCode == 201) {
      return response.data['data'];
    }

    throw Exception('수유 기록 생성 실패: ${response.statusCode}');
  }

  /// 수유 기록 목록 조회
  ///
  /// [babyId] 아기 ID
  /// [startDate] 시작 날짜 (ISO 8601 형식, 선택)
  /// [endDate] 종료 날짜 (ISO 8601 형식, 선택)
  Future<List<Map<String, dynamic>>> getFeedingRecords({
    required int babyId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '/api/v1/babies/$babyId/feeding-records',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('수유 기록 조회 실패: ${response.statusCode}');
  }

  /// 오늘 총 수유량 조회
  ///
  /// [babyId] 아기 ID
  Future<int> getTodayTotalAmount({required int babyId}) async {
    final response = await _apiClient.get(
      '/api/v1/babies/$babyId/feeding-records/today-stats',
    );

    if (response.statusCode == 200) {
      return response.data['data']['totalAmountMl'];
    }

    throw Exception('오늘 총 수유량 조회 실패: ${response.statusCode}');
  }

  /// 수유 기록 수정
  ///
  /// [babyId] 아기 ID
  /// [recordId] 수유 기록 ID
  Future<Map<String, dynamic>> updateFeedingRecord({
    required int babyId,
    required int recordId,
    String? feedingTime,
    String? type,
    int? amountMl,
    String? note,
  }) async {
    final response = await _apiClient.put(
      '/api/v1/babies/$babyId/feeding-records/$recordId',
      data: {
        if (feedingTime != null) 'feedingTime': feedingTime,
        if (type != null) 'type': type,
        if (amountMl != null) 'amountMl': amountMl,
        if (note != null) 'note': note,
      },
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('수유 기록 수정 실패: ${response.statusCode}');
  }

  /// 수유 기록 삭제
  ///
  /// [babyId] 아기 ID
  /// [recordId] 수유 기록 ID
  Future<void> deleteFeedingRecord({
    required int babyId,
    required int recordId,
  }) async {
    final response = await _apiClient.delete(
      '/api/v1/babies/$babyId/feeding-records/$recordId',
    );

    if (response.statusCode != 200) {
      throw Exception('수유 기록 삭제 실패: ${response.statusCode}');
    }
  }
}
