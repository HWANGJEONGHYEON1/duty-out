import 'package:flutter/foundation.dart';

class SleepTrackingProvider with ChangeNotifier {
  bool _isTracking = false;
  DateTime? _startTime;
  String _sleepType = 'nap'; // 'nap' or 'night'

  bool get isTracking => _isTracking;
  DateTime? get startTime => _startTime;
  String get sleepType => _sleepType;

  Duration? get elapsedTime {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }

  void startTracking(String type) {
    _isTracking = true;
    _startTime = DateTime.now();
    _sleepType = type;
    notifyListeners();
  }

  void stopTracking() {
    _isTracking = false;
    _startTime = null;
    notifyListeners();
  }

  String getElapsedTimeString() {
    final elapsed = elapsedTime;
    if (elapsed == null) return '00:00:00';

    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    final seconds = elapsed.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
