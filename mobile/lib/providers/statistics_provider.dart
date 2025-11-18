import 'package:flutter/foundation.dart';
import '../models/sleep_record.dart';
import '../models/feeding_record.dart';
import '../services/statistics_api_service.dart';

class StatisticsProvider with ChangeNotifier {
  final StatisticsApiService _statisticsApiService = StatisticsApiService();

  List<SleepRecord> _sleepRecords = [];
  List<FeedingRecord> _feedingRecords = [];
  String _selectedPeriod = 'daily'; // 'daily', 'weekly', 'monthly'
  bool _isLoading = false;
  String? _error;

  // 통계 데이터
  DateTime? _startDate;
  DateTime? _endDate;
  int? _totalSleepMinutes;
  int? _averageSleepMinutes;
  int? _totalFeedingAmount;
  int? _averageFeedingAmount;
  bool _hasEnoughData = false;
  List<Map<String, dynamic>> _dailyStats = [];

  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<FeedingRecord> get feedingRecords => _feedingRecords;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  int? get totalSleepMinutes => _totalSleepMinutes;
  int? get averageSleepMinutes => _averageSleepMinutes;
  int? get totalFeedingAmount => _totalFeedingAmount;
  int? get averageFeedingAmount => _averageFeedingAmount;
  bool get hasEnoughData => _hasEnoughData;
  List<Map<String, dynamic>> get dailyStats => _dailyStats;

  /// 주간 통계 조회
  Future<void> loadWeeklyStatistics({required int babyId}) async {
    _isLoading = true;
    _error = null;
    _selectedPeriod = 'weekly';
    notifyListeners();

    try {
      final response = await _statisticsApiService.getWeeklyStatistics(
        babyId: babyId,
      );

      _parseStatisticsResponse(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '주간 통계 조회 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 월간 통계 조회
  Future<void> loadMonthlyStatistics({required int babyId}) async {
    _isLoading = true;
    _error = null;
    _selectedPeriod = 'monthly';
    notifyListeners();

    try {
      final response = await _statisticsApiService.getMonthlyStatistics(
        babyId: babyId,
      );

      _parseStatisticsResponse(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '월간 통계 조회 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 통계 응답 파싱
  void _parseStatisticsResponse(Map<String, dynamic> response) {
    try {
      // 기본 통계 정보
      _startDate = response['startDate'] != null
          ? DateTime.parse(response['startDate'])
          : null;
      _endDate = response['endDate'] != null
          ? DateTime.parse(response['endDate'])
          : null;
      _totalSleepMinutes = response['totalSleepMinutes'] ?? 0;
      _averageSleepMinutes = response['averageSleepMinutes'] ?? 0;
      _totalFeedingAmount = response['totalFeedingAmount'] ?? 0;
      _averageFeedingAmount = response['averageFeedingAmount'] ?? 0;
      _hasEnoughData = response['hasEnoughData'] ?? false;

      // 일별 통계 파싱
      _dailyStats = [];
      if (response['dailyStats'] != null) {
        _dailyStats = List<Map<String, dynamic>>.from(
          (response['dailyStats'] as List).map((item) => Map<String, dynamic>.from(item as Map)),
        );
      }
    } catch (e) {
      _error = '통계 데이터 파싱 실패: $e';
    }
  }

  void setPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  int getTotalSleepMinutesToday() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _sleepRecords
        .where((record) =>
            record.startTime.isAfter(todayStart) &&
            record.startTime.isBefore(todayEnd))
        .fold<int>(0, (sum, record) => sum + record.durationMinutes);
  }

  int getNapCount() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _sleepRecords
        .where((record) =>
            record.type == 'nap' &&
            record.startTime.isAfter(todayStart) &&
            record.startTime.isBefore(todayEnd))
        .length;
  }

  int getNightSleepMinutes() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _sleepRecords
        .where((record) =>
            record.type == 'night' &&
            record.startTime.isAfter(todayStart) &&
            record.startTime.isBefore(todayEnd))
        .fold<int>(0, (sum, record) => sum + record.durationMinutes);
  }

  List<int> getWeeklySleepData() {
    // Returns sleep minutes for last 7 days
    final today = DateTime.now();
    List<int> weeklyData = [];

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final totalMinutes = _sleepRecords
          .where((record) =>
              record.startTime.isAfter(dayStart) &&
              record.startTime.isBefore(dayEnd))
          .fold<int>(0, (sum, record) => sum + record.durationMinutes);

      weeklyData.add(totalMinutes);
    }

    return weeklyData;
  }

  double getSleepGoalPercentage() {
    final totalMinutes = getTotalSleepMinutesToday();
    const recommendedMinutes = 14 * 60 + 30; // 14.5 hours
    return (totalMinutes / recommendedMinutes * 100).clamp(0, 100);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
