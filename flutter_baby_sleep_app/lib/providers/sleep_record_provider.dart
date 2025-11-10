import 'package:flutter/material.dart';

class SleepRecord {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String quality; // 'good', 'fair', 'poor'
  final String? notes;

  SleepRecord({
    required this.id,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    this.quality = 'fair',
    this.notes,
  });

  bool get isActive => endTime == null;

  int get actualDuration {
    if (durationMinutes != null) return durationMinutes!;
    if (endTime != null) {
      return endTime!.difference(startTime).inMinutes;
    }
    return DateTime.now().difference(startTime).inMinutes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'quality': quality,
      'notes': notes,
    };
  }

  factory SleepRecord.fromJson(Map<String, dynamic> json) {
    return SleepRecord(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationMinutes: json['durationMinutes'],
      quality: json['quality'] ?? 'fair',
      notes: json['notes'],
    );
  }
}

class SleepRecordProvider extends ChangeNotifier {
  List<SleepRecord> _sleepRecords = [];
  SleepRecord? _activeRecord;

  List<SleepRecord> get sleepRecords => _sleepRecords;
  SleepRecord? get activeRecord => _activeRecord;
  bool get hasActiveRecord => _activeRecord != null;

  // Mock 데이터 초기화
  void initializeMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _sleepRecords = [
      // 오늘 수면 기록
      SleepRecord(
        id: 'mock-sleep-1',
        startTime: today.add(Duration(hours: 9)),
        endTime: today.add(Duration(hours: 10, minutes: 30)),
        durationMinutes: 90,
        quality: 'good',
        notes: '첫 번째 낮잠 - 잘 잤어요',
      ),
      SleepRecord(
        id: 'mock-sleep-2',
        startTime: today.add(Duration(hours: 13)),
        endTime: today.add(Duration(hours: 14, minutes: 30)),
        durationMinutes: 90,
        quality: 'good',
        notes: '두 번째 낮잠',
      ),
      // 어제 수면 기록
      SleepRecord(
        id: 'mock-sleep-3',
        startTime: today.subtract(Duration(days: 1, hours: -9)),
        endTime: today.subtract(Duration(days: 1, hours: -10, minutes: -20)),
        durationMinutes: 80,
        quality: 'fair',
        notes: '어제 첫 번째 낮잠',
      ),
      SleepRecord(
        id: 'mock-sleep-4',
        startTime: today.subtract(Duration(days: 1, hours: -13)),
        endTime: today.subtract(Duration(days: 1, hours: -14, minutes: -45)),
        durationMinutes: 105,
        quality: 'good',
        notes: '어제 두 번째 낮잠',
      ),
      SleepRecord(
        id: 'mock-sleep-5',
        startTime: today.subtract(Duration(days: 1, hours: -19)),
        endTime: today.add(Duration(hours: 6)),
        durationMinutes: 660,
        quality: 'good',
        notes: '어제 밤잠',
      ),
      // 그제 수면 기록
      SleepRecord(
        id: 'mock-sleep-6',
        startTime: today.subtract(Duration(days: 2, hours: -9, minutes: -30)),
        endTime: today.subtract(Duration(days: 2, hours: -11)),
        durationMinutes: 90,
        quality: 'good',
        notes: '그제 첫 번째 낮잠',
      ),
      SleepRecord(
        id: 'mock-sleep-7',
        startTime: today.subtract(Duration(days: 2, hours: -14)),
        endTime: today.subtract(Duration(days: 2, hours: -15, minutes: -30)),
        durationMinutes: 90,
        quality: 'fair',
        notes: '그제 두 번째 낮잠 - 중간에 깸',
      ),
    ];
    notifyListeners();
  }

  List<SleepRecord> getRecordsForDate(DateTime date) {
    return _sleepRecords.where((record) {
      return record.startTime.year == date.year &&
          record.startTime.month == date.month &&
          record.startTime.day == date.day;
    }).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<SleepRecord> getRecordsForDateRange(DateTime start, DateTime end) {
    return _sleepRecords.where((record) {
      return record.startTime.isAfter(start) && record.startTime.isBefore(end);
    }).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  void startSleep() {
    if (_activeRecord != null) {
      // 이미 활성 기록이 있으면 종료
      endSleep();
    }

    _activeRecord = SleepRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    notifyListeners();
  }

  void endSleep({String quality = 'fair', String? notes}) {
    if (_activeRecord != null) {
      final endedRecord = SleepRecord(
        id: _activeRecord!.id,
        startTime: _activeRecord!.startTime,
        endTime: DateTime.now(),
        durationMinutes: DateTime.now().difference(_activeRecord!.startTime).inMinutes,
        quality: quality,
        notes: notes,
      );

      _sleepRecords.add(endedRecord);
      _activeRecord = null;
      notifyListeners();
    }
  }

  void addSleepRecord(SleepRecord record) {
    _sleepRecords.add(record);
    notifyListeners();
  }

  void updateSleepRecord(String id, SleepRecord updatedRecord) {
    final index = _sleepRecords.indexWhere((record) => record.id == id);
    if (index != -1) {
      _sleepRecords[index] = updatedRecord;
      notifyListeners();
    }
  }

  void deleteSleepRecord(String id) {
    _sleepRecords.removeWhere((record) => record.id == id);
    notifyListeners();
  }

  // 통계 계산
  double getAverageSleepDuration(DateTime start, DateTime end) {
    final records = getRecordsForDateRange(start, end);
    if (records.isEmpty) return 0;

    final totalMinutes = records.fold<int>(
      0,
      (sum, record) => sum + record.actualDuration,
    );

    return totalMinutes / records.length;
  }

  int getTotalSleepForDate(DateTime date) {
    final records = getRecordsForDate(date);
    return records.fold<int>(
      0,
      (sum, record) => sum + record.actualDuration,
    );
  }

  Map<String, int> getSleepQualityStats(DateTime start, DateTime end) {
    final records = getRecordsForDateRange(start, end);
    final stats = {'good': 0, 'fair': 0, 'poor': 0};

    for (var record in records) {
      stats[record.quality] = (stats[record.quality] ?? 0) + 1;
    }

    return stats;
  }

  void clearRecords() {
    _sleepRecords.clear();
    _activeRecord = null;
    notifyListeners();
  }
}
