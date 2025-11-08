import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/daily_schedule.dart';
import '../repositories/schedule_repository.dart';

/// 스케줄 자동 생성 UseCase
class GenerateScheduleUseCase {
  final ScheduleRepository repository;

  GenerateScheduleUseCase(this.repository);

  Future<Either<Failure, DailySchedule>> call({
    required int babyId,
    required DateTime scheduleDate,
    required DateTime wakeUpTime,
  }) async {
    return await repository.generateSchedule(
      babyId: babyId,
      scheduleDate: scheduleDate,
      wakeUpTime: wakeUpTime,
    );
  }
}
