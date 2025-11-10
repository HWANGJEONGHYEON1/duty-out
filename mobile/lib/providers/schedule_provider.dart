import 'package:flutter/foundation.dart';
import '../models/schedule_item.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleItem> _scheduleItems = [];
  DateTime _wakeTime = DateTime.now();

  List<ScheduleItem> get scheduleItems => _scheduleItems;
  DateTime get wakeTime => _wakeTime;

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

  void updateWakeTime(DateTime time) {
    _wakeTime = time;
    // TODO: Regenerate schedule based on wake time
    notifyListeners();
  }

  ScheduleItem? getNextScheduleItem() {
    final now = DateTime.now();
    for (var item in _scheduleItems) {
      if (item.time.isAfter(now)) {
        return item;
      }
    }
    return null;
  }

  int? getMinutesUntilNext() {
    final next = getNextScheduleItem();
    if (next == null) return null;
    return next.time.difference(DateTime.now()).inMinutes;
  }
}
