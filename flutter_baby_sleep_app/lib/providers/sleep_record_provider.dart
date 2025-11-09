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
