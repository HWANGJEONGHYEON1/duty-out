import 'package:equatable/equatable.dart';

/// 일일 스케줄 엔티티
class DailySchedule extends Equatable {
  final int id;
  final int babyId;
  final DateTime scheduleDate;
  final DateTime wakeUpTime;
  final int ageInMonths;
  final List<ScheduleItem> scheduleItems;

  const DailySchedule({
    required this.id,
    required this.babyId,
    required this.scheduleDate,
    required this.wakeUpTime,
    required this.ageInMonths,
    required this.scheduleItems,
  });

  @override
  List<Object?> get props => [
        id,
        babyId,
        scheduleDate,
        wakeUpTime,
        ageInMonths,
        scheduleItems,
      ];
}

/// 스케줄 항목 엔티티
class ScheduleItem extends Equatable {
  final int id;
  final ActivityType activityType;
  final DateTime scheduledTime;
  final int? durationMinutes;
  final String? note;

  const ScheduleItem({
    required this.id,
    required this.activityType,
    required this.scheduledTime,
    this.durationMinutes,
    this.note,
  });

  @override
  List<Object?> get props => [
        id,
        activityType,
        scheduledTime,
        durationMinutes,
        note,
      ];
}

enum ActivityType {
  wakeUp,
  nap1,
  nap2,
  nap3,
  nap4,
  feeding,
  bedtime,
  play,
  bath,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.wakeUp:
        return '기상';
      case ActivityType.nap1:
        return '첫 번째 낮잠';
      case ActivityType.nap2:
        return '두 번째 낮잠';
      case ActivityType.nap3:
        return '세 번째 낮잠';
      case ActivityType.nap4:
        return '네 번째 낮잠';
      case ActivityType.feeding:
        return '수유/이유식';
      case ActivityType.bedtime:
        return '취침';
      case ActivityType.play:
        return '놀이 시간';
      case ActivityType.bath:
        return '목욕';
    }
  }
}
