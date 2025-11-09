import 'package:flutter/material.dart';

class ScheduleItem {
  final String id;
  final String type; // 'sleep', 'wake', 'feed', 'play'
  final DateTime scheduledTime;
  final int durationMinutes;
  final String? notes;
  bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.type,
    required this.scheduledTime,
    required this.durationMinutes,
    this.notes,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      type: json['type'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      durationMinutes: json['durationMinutes'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class ScheduleProvider extends ChangeNotifier {
  List<ScheduleItem> _scheduleItems = [];
  DateTime _selectedDate = DateTime.now();

  List<ScheduleItem> get scheduleItems => _scheduleItems;
  DateTime get selectedDate => _selectedDate;

  List<ScheduleItem> getScheduleForDate(DateTime date) {
    return _scheduleItems.where((item) {
      return item.scheduledTime.year == date.year &&
          item.scheduledTime.month == date.month &&
          item.scheduledTime.day == date.day;
    }).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void addScheduleItem(ScheduleItem item) {
    _scheduleItems.add(item);
    notifyListeners();
  }

  void updateScheduleItem(String id, ScheduleItem updatedItem) {
    final index = _scheduleItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _scheduleItems[index] = updatedItem;
      notifyListeners();
    }
  }

  void deleteScheduleItem(String id) {
    _scheduleItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleItemCompletion(String id) {
    final index = _scheduleItems.indexWhere((item) => item.id == id);
    if (index != -1) {
      _scheduleItems[index].isCompleted = !_scheduleItems[index].isCompleted;
      notifyListeners();
    }
  }

  void generateDailySchedule(DateTime wakeTime, int babyAgeInMonths) {
    _scheduleItems.clear();

    // 월령에 따른 수면 시간 및 횟수 설정
    final sleepConfig = _getSleepConfigForAge(babyAgeInMonths);

    DateTime currentTime = wakeTime;
    int itemCount = 0;

    // 하루 일정 생성
    for (int i = 0; i < sleepConfig['napCount']; i++) {
      // 활동 시간
      _scheduleItems.add(ScheduleItem(
        id: 'item_${itemCount++}',
        type: 'wake',
        scheduledTime: currentTime,
        durationMinutes: sleepConfig['wakeWindow'],
        notes: '활동 시간',
      ));
      currentTime = currentTime.add(Duration(minutes: sleepConfig['wakeWindow']));

      // 낮잠 시간
      _scheduleItems.add(ScheduleItem(
        id: 'item_${itemCount++}',
        type: 'sleep',
        scheduledTime: currentTime,
        durationMinutes: sleepConfig['napDuration'],
        notes: '낮잠 ${i + 1}',
      ));
      currentTime = currentTime.add(Duration(minutes: sleepConfig['napDuration']));
    }

    notifyListeners();
  }

  Map<String, dynamic> _getSleepConfigForAge(int months) {
    if (months < 3) {
      return {
        'napCount': 4,
        'napDuration': 60,
        'wakeWindow': 60,
      };
    } else if (months < 6) {
      return {
        'napCount': 3,
        'napDuration': 90,
        'wakeWindow': 90,
      };
    } else if (months < 12) {
      return {
        'napCount': 2,
        'napDuration': 90,
        'wakeWindow': 150,
      };
    } else {
      return {
        'napCount': 1,
        'napDuration': 120,
        'wakeWindow': 300,
      };
    }
  }

  void clearSchedule() {
    _scheduleItems.clear();
    notifyListeners();
  }
}
