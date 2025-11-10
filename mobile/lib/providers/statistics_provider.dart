import 'package:flutter/foundation.dart';
import '../models/sleep_record.dart';

class StatisticsProvider with ChangeNotifier {
  List<SleepRecord> _sleepRecords = [];
  String _selectedPeriod = 'daily'; // 'daily', 'weekly', 'monthly'

  List<SleepRecord> get sleepRecords => _sleepRecords;
  String get selectedPeriod => _selectedPeriod;

  void initializeMockData() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBefore = today.subtract(const Duration(days: 2));

    _sleepRecords = [
      // Today
      SleepRecord(
        id: '1',
        startTime: DateTime(today.year, today.month, today.day, 8, 50),
        endTime: DateTime(today.year, today.month, today.day, 10, 0),
        type: 'nap',
      ),
      SleepRecord(
        id: '2',
        startTime: DateTime(today.year, today.month, today.day, 12, 15),
        endTime: DateTime(today.year, today.month, today.day, 14, 0),
        type: 'nap',
      ),
      SleepRecord(
        id: '3',
        startTime: DateTime(today.year, today.month, today.day, 16, 15),
        endTime: DateTime(today.year, today.month, today.day, 17, 0),
        type: 'nap',
      ),
      SleepRecord(
        id: '4',
        startTime: DateTime(today.year, today.month, today.day, 19, 0),
        endTime: DateTime(today.year, today.month, today.day, 23, 30),
        type: 'night',
      ),
      // Yesterday
      SleepRecord(
        id: '5',
        startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 19, 0),
        endTime: DateTime(today.year, today.month, today.day, 6, 30),
        type: 'night',
      ),
      SleepRecord(
        id: '6',
        startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 9, 0),
        endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 15),
        type: 'nap',
      ),
      SleepRecord(
        id: '7',
        startTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 13, 0),
        endTime: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 45),
        type: 'nap',
      ),
    ];

    notifyListeners();
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
        .fold(0, (sum, record) => sum + record.durationMinutes);
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
        .fold(0, (sum, record) => sum + record.durationMinutes);
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
          .fold(0, (sum, record) => sum + record.durationMinutes);

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
