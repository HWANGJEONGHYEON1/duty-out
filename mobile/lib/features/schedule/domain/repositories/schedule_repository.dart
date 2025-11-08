import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/daily_schedule.dart';

/// 스케줄 Repository 인터페이스
abstract class ScheduleRepository {
  /// 스케줄 자동 생성
  Future<Either<Failure, DailySchedule>> generateSchedule({
    required int babyId,
    required DateTime scheduleDate,
    required DateTime wakeUpTime,
  });

  /// 스케줄 조회
  Future<Either<Failure, DailySchedule>> getSchedule({
    required int babyId,
    required DateTime date,
  });

  /// 스케줄 수정
  Future<Either<Failure, DailySchedule>> updateScheduleItem({
    required int scheduleId,
    required int itemId,
    required DateTime newTime,
  });
}
