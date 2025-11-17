import 'api_client.dart';

/// 스케줄 API 서비스
///
/// 자동 스케줄 생성 및 조정 API를 제공합니다.
class ScheduleApiService {
  final ApiClient _apiClient = ApiClient();

  /// 자동 스케줄 생성
  ///
  /// 아기의 개월 수와 기상 시간을 기반으로 하루 스케줄을 자동 생성합니다.
  ///
  /// [babyId] 아기 ID
  /// [wakeUpTime] 기상 시간 (HH:mm 형식)
  /// [isBreastfeeding] 모유 수유 여부
  Future<Map<String, dynamic>> generateAutoSchedule({
    required dynamic babyId,
    required String wakeUpTime,
    bool? isBreastfeeding,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/babies/$babyId/auto-schedule',
      data: {
        'wakeUpTime': wakeUpTime,
        if (isBreastfeeding != null) 'isBreastfeeding': isBreastfeeding,
      },
    );

    if (response.statusCode == 201) {
      return response.data['data'];
    }

    throw Exception('자동 스케줄 생성 실패: ${response.statusCode}');
  }

  /// 스케줄 동적 조정
  ///
  /// 실제 낮잠 시간이나 활동 시간이 변경되었을 때 이후 스케줄을 재조정합니다.
  ///
  /// [babyId] 아기 ID
  /// [scheduleItemId] 조정할 스케줄 아이템 ID
  /// [actualStartTime] 실제 시작 시간
  /// [actualEndTime] 실제 종료 시간
  /// [actualDurationMinutes] 실제 지속 시간 (분)
  Future<Map<String, dynamic>> adjustSchedule({
    required int babyId,
    required int scheduleItemId,
    String? actualStartTime,
    String? actualEndTime,
    int? actualDurationMinutes,
  }) async {
    final response = await _apiClient.put(
      '/api/v1/babies/$babyId/auto-schedule/adjust',
      data: {
        'scheduleItemId': scheduleItemId,
        if (actualStartTime != null) 'actualStartTime': actualStartTime,
        if (actualEndTime != null) 'actualEndTime': actualEndTime,
        if (actualDurationMinutes != null)
          'actualDurationMinutes': actualDurationMinutes,
      },
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('스케줄 조정 실패: ${response.statusCode}');
  }

  /// 스케줄 아이템 업데이트 (수유량, 수면 시간 기록)
  ///
  /// [itemId] 아이템 ID
  /// [feedingAmount] 수유량 (ml)
  /// [actualSleepDuration] 실제 수면 시간 (분)
  Future<Map<String, dynamic>> updateScheduleItem({
    required int itemId,
    int? feedingAmount,
    int? actualSleepDuration,
  }) async {
    final response = await _apiClient.put(
      '/api/v1/babies/1/schedules/items/$itemId',
      data: {
        if (feedingAmount != null) 'feedingAmount': feedingAmount,
        if (actualSleepDuration != null)
          'actualSleepDuration': actualSleepDuration,
      },
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('스케줄 업데이트 실패: ${response.statusCode}');
  }
}
