class ScheduleItem {
  final String id;
  final DateTime time;
  final String activity;
  final String type; // 'wake', 'sleep', 'feed', 'play'
  final int? durationMinutes;

  ScheduleItem({
    required this.id,
    required this.time,
    required this.activity,
    required this.type,
    this.durationMinutes,
  });

  String get timeString {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get durationString {
    if (durationMinutes == null) return '';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }
}
