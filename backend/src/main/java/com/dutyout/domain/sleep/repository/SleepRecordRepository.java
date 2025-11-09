package com.dutyout.domain.sleep.repository;

import com.dutyout.domain.sleep.entity.SleepRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface SleepRecordRepository extends JpaRepository<SleepRecord, Long> {

    List<SleepRecord> findByBabyIdAndStartTimeBetween(Long babyId, LocalDateTime startTime, LocalDateTime endTime);

    @Query("SELECT s FROM SleepRecord s WHERE s.babyId = :babyId AND s.endTime IS NULL ORDER BY s.startTime DESC")
    Optional<SleepRecord> findOngoingSleep(@Param("babyId") Long babyId);

    List<SleepRecord> findByBabyIdOrderByStartTimeDesc(Long babyId);
}
