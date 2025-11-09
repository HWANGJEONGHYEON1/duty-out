package com.dutyout.domain.schedule.repository;

import com.dutyout.domain.schedule.entity.DailySchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DailyScheduleRepository extends JpaRepository<DailySchedule, Long> {

    Optional<DailySchedule> findByBabyIdAndScheduleDate(Long babyId, LocalDate scheduleDate);

    List<DailySchedule> findByBabyIdAndScheduleDateBetween(Long babyId, LocalDate startDate, LocalDate endDate);

    @Query("SELECT d FROM DailySchedule d LEFT JOIN FETCH d.scheduleItems WHERE d.babyId = :babyId AND d.scheduleDate = :scheduleDate")
    Optional<DailySchedule> findByBabyIdAndScheduleDateWithItems(@Param("babyId") Long babyId,
                                                                   @Param("scheduleDate") LocalDate scheduleDate);

    boolean existsByBabyIdAndScheduleDate(Long babyId, LocalDate scheduleDate);
}
