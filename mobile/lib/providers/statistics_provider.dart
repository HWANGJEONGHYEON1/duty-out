import 'package:flutter/foundation.dart';
import '../models/sleep_record.dart';
import '../models/feeding_record.dart';

class StatisticsProvider with ChangeNotifier {
  List<SleepRecord> _sleepRecords = [];
  List<FeedingRecord> _feedingRecords = [];
  String _selectedPeriod = 'daily'; // 'daily', 'weekly', 'monthly'

  List<SleepRecord> get sleepRecords => _sleepRecords;
  List<FeedingRecord> get feedingRecords => _feedingRecords;
  String get selectedPeriod => _selectedPeriod;

  // TODO: API 연결 필요
  // Future<void> loadSleepRecords() async {}
  // Future<void> loadFeedingRecords() async {}

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
}
