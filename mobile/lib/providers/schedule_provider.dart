import 'package:flutter/foundation.dart';
import '../models/schedule_item.dart';
import '../services/schedule_api_service.dart';
import '../services/auth_api_service.dart';

/// 스케줄 Provider
///
/// 자동 생성된 스케줄을 관리하고, API와 연동합니다.
class ScheduleProvider with ChangeNotifier {
  final ScheduleApiService _scheduleApiService = ScheduleApiService();
  final AuthApiService _authApiService = AuthApiService();

  List<ScheduleItem> _scheduleItems = [];
  DateTime _wakeTime = DateTime.now();
  bool _isLoading = false;
  String? _error;
  int? _currentBabyId;

  List<ScheduleItem> get scheduleItems => _scheduleItems;
  DateTime get wakeTime => _wakeTime;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 자동 스케줄 생성
  ///
  /// 백엔드 API를 호출하여 개월수 기반 스케줄을 자동 생성합니다.
  ///
  /// [babyId] 아기 ID
  /// [wakeUpTime] 기상 시간
  /// [isBreastfeeding] 모유 수유 여부
  Future<void> generateAutoSchedule({
    required int babyId,
    required DateTime wakeUpTime,
    bool isBreastfeeding = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // API 호출
      final timeString =
          '${wakeUpTime.hour.toString().padLeft(2, '0')}:${wakeUpTime.minute.toString().padLeft(2, '0')}';

      final response = await _scheduleApiService.generateAutoSchedule(
        babyId: babyId,
        wakeUpTime: timeString,
        isBreastfeeding: isBreastfeeding,
      );

      // 응답 파싱
      _currentBabyId = response['babyId'];
      _wakeTime = wakeUpTime;
      _scheduleItems = _parseScheduleItems(response['items']);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '스케줄 생성 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 스케줄 아이템 파싱
  ///
  /// API 응답을 ScheduleItem 모델로 변환합니다.
  List<ScheduleItem> _parseScheduleItems(List<dynamic> items) {
    final today = DateTime.now();
    final baseDate = DateTime(today.year, today.month, today.day);

    return items.map<ScheduleItem>((item) {
      // startTime 파싱 (HH:mm 형식)
      final timeStr = item['startTime'] as String;
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final time = baseDate.add(Duration(hours: hour, minutes: minute));

      // activityType을 type으로 변환
      String type;
      switch (item['activityType']) {
        case 'WAKE_UP':
          type = 'wake';
          break;
        case 'NAP':
        case 'NAP1':
        case 'NAP2':
        case 'NAP3':
        case 'NAP4':
        case 'BEDTIME':
          type = 'sleep';
          break;
        case 'FEEDING':
          type = 'feed';
          break;
        case 'PLAY':
          type = 'play';
          break;
        default:
          type = 'wake';
      }

      return ScheduleItem(
        id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        time: time,
        activity: item['activityName'] ?? item['note'] ?? '',
        type: type,
        durationMinutes: item['durationMinutes'],
      );
    }).toList();
  }

  /// Mock 데이터 초기화 (개발/테스트용)
  void initializeMockData() {
    final today = DateTime.now();
    final baseDate = DateTime(today.year, today.month, today.day);

    _wakeTime = baseDate.add(const Duration(hours: 7));

    _scheduleItems = [
      ScheduleItem(
        id: '1',
        time: baseDate.add(const Duration(hours: 7)),
        activity: '기상 및 수유',
        type: 'wake',
      ),
      ScheduleItem(
        id: '2',
        time: baseDate.add(const Duration(hours: 8, minutes: 50)),
        activity: '낮잠 1',
        type: 'sleep',
        durationMinutes: 70,
      ),
      ScheduleItem(
        id: '3',
        time: baseDate.add(const Duration(hours: 10)),
        activity: '기상',
        type: 'wake',
      ),
      ScheduleItem(
        id: '4',
        time: baseDate.add(const Duration(hours: 10, minutes: 45)),
        activity: '수유',
        type: 'feed',
      ),
      ScheduleItem(
        id: '5',
        time: baseDate.add(const Duration(hours: 12, minutes: 15)),
        activity: '낮잠 2',
        type: 'sleep',
        durationMinutes: 105,
      ),
      ScheduleItem(
        id: '6',
        time: baseDate.add(const Duration(hours: 14)),
        activity: '기상 및 수유',
        type: 'wake',
      ),
      ScheduleItem(
        id: '7',
        time: baseDate.add(const Duration(hours: 16, minutes: 15)),
        activity: '낮잠 3',
        type: 'sleep',
        durationMinutes: 45,
      ),
      ScheduleItem(
        id: '8',
        time: baseDate.add(const Duration(hours: 18, minutes: 15)),
        activity: '마지막 수유',
        type: 'feed',
      ),
      ScheduleItem(
        id: '9',
        time: baseDate.add(const Duration(hours: 19)),
        activity: '취침',
        type: 'sleep',
      ),
    ];

    notifyListeners();
  }

  /// 기상 시간 변경 및 스케줄 재생성
  ///
  /// [time] 새로운 기상 시간
  Future<void> updateWakeTime(DateTime time) async {
    _wakeTime = time;

    // 현재 아기 ID가 있으면 스케줄 재생성
    if (_currentBabyId != null) {
      await generateAutoSchedule(
        babyId: _currentBabyId!,
        wakeUpTime: time,
      );
    }

    notifyListeners();
  }

  /// 다음 스케줄 아이템 조회
  ScheduleItem? getNextScheduleItem() {
    final now = DateTime.now();
    for (var item in _scheduleItems) {
      if (item.time.isAfter(now)) {
        return item;
      }
    }
    return null;
  }

  /// 다음 스케줄까지 남은 시간 (분)
  int? getMinutesUntilNext() {
    final next = getNextScheduleItem();
    if (next == null) return null;
    return next.time.difference(DateTime.now()).inMinutes;
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
