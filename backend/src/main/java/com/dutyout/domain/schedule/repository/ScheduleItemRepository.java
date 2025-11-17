package com.dutyout.domain.schedule.repository;

import com.dutyout.domain.schedule.entity.ScheduleItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * 스케줄 항목 저장소
 */
@Repository
public interface ScheduleItemRepository extends JpaRepository<ScheduleItem, Long> {
}
