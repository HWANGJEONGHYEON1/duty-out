class SleepRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // 'nap' or 'night'

  SleepRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  String get durationString {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }
}
