class ScheduleItem {
  final String id;
  final DateTime time;
  final String activity;
  final String type; // 'wake', 'sleep', 'feed', 'play'
  final int? durationMinutes;

  // 수유 관련 필드
  int? feedingAmount; // 수유량 (ml)
  DateTime? actualFeedingTime; // 실제 수유 시간

  // 수면 관련 필드
  DateTime? actualSleepStartTime; // 실제 수면 시작 시간
  DateTime? actualSleepEndTime; // 실제 수면 종료 시간
  int? actualSleepDuration; // 실제 수면 시간 (분)

  ScheduleItem({
    required this.id,
    required this.time,
    required this.activity,
    required this.type,
    this.durationMinutes,
    this.feedingAmount,
    this.actualFeedingTime,
    this.actualSleepStartTime,
    this.actualSleepEndTime,
    this.actualSleepDuration,
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

  String get subtitleString {
    // 수유 항목: 수유량 표시 (기본값 0ml)
    if (type == 'feed') {
      return '${feedingAmount ?? 0}ml';
    }

    // 수면 항목: 실제 수면 시간 우선 표시
    if (type == 'sleep') {
      if (actualSleepDuration != null) {
        // 사용자가 입력한 실제 수면 시간 표시
        final hours = actualSleepDuration! ~/ 60;
        final minutes = actualSleepDuration! % 60;
        if (hours > 0) {
          return '실제: $hours시간 $minutes분';
        }
        return '실제: $minutes분';
      } else if (durationMinutes != null) {
        // 예정된 수면 시간 표시
        return '예정: $durationString';
      }
    }

    // 기타 항목: 예정된 시간 표시
    if (durationMinutes != null) {
      return durationString;
    }
    return '';
  }
}
