package com.dutyout.domain.schedule.service;

import com.dutyout.application.dto.request.UpdateScheduleItemRequest;
import com.dutyout.domain.schedule.entity.ScheduleItem;
import com.dutyout.domain.schedule.repository.ScheduleItemRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * 스케줄 관리 서비스
 */
@Service
@RequiredArgsConstructor
@Transactional
public class ScheduleService {

    private final ScheduleItemRepository scheduleItemRepository;
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * 스케줄 아이템 수정 (시간, 수유량, 수면 시간 기록)
     */
    public ScheduleItem updateScheduleItem(Long itemId, UpdateScheduleItemRequest request) {
        ScheduleItem item = scheduleItemRepository.findById(itemId)
                .orElseThrow(() -> new IllegalArgumentException("스케줄 아이템을 찾을 수 없습니다."));

        // 시간 수정
        if (request.getScheduledTime() != null && !request.getScheduledTime().isEmpty()) {
            LocalTime newTime = LocalTime.parse(request.getScheduledTime(), TIME_FORMATTER);
            item.updateScheduledTime(newTime);
        }

        // 수유량 기록
        if (request.getFeedingAmount() != null) {
            item.recordFeeding(request.getFeedingAmount());
        }

        // 수면 시간 기록
        if (request.getActualSleepDuration() != null) {
            item.recordSleep(request.getActualSleepDuration());
        }

        return scheduleItemRepository.save(item);
    }
}

