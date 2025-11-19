package com.dutyout.domain.schedule.service;

import com.dutyout.application.dto.request.AdjustScheduleRequest;
import com.dutyout.application.dto.request.UpdateScheduleItemRequest;
import com.dutyout.application.service.AutoScheduleService;
import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.schedule.entity.DailySchedule;
import com.dutyout.domain.schedule.entity.ScheduleItem;
import com.dutyout.domain.schedule.repository.ScheduleItemRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * 스케줄 관리 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class ScheduleService {

    private final ScheduleItemRepository scheduleItemRepository;
    @Lazy // 순환 참조 방지
    private final AutoScheduleService autoScheduleService;

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * 스케줄 아이템 수정 (시간, 수유량, 수면 시간 기록)
     *
     * 실제 수면 시간이 입력되면 다음 스케줄을 자동으로 재계산합니다.
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

        // 수면 시간 기록 및 다음 스케줄 재계산
        if (request.getActualSleepDuration() != null) {
            item.recordSleep(request.getActualSleepDuration());

            // 먼저 현재 아이템 저장 (actualSleepDuration 업데이트)
            item = scheduleItemRepository.save(item);

            // 실제 수면 시간을 기준으로 다음 스케줄 재계산
            DailySchedule dailySchedule = item.getDailySchedule();
            if (dailySchedule != null) {
                try {
                    log.info("실제 수면 시간 입력 - 다음 스케줄 재계산 시작: {}분", request.getActualSleepDuration());

                    // AdjustScheduleRequest 생성
                    AdjustScheduleRequest adjustRequest = AdjustScheduleRequest.builder()
                            .scheduleItemId(itemId)
                            .actualDurationMinutes(request.getActualSleepDuration())
                            .build();

                    // 다음 스케줄 재계산
                    autoScheduleService.adjustSchedule(dailySchedule.getBabyId(), adjustRequest);

                    log.info("다음 스케줄 재계산 완료");

                    // 재계산 후 아이템 다시 조회하여 반환 (다음 활동 시간이 변경되었을 수 있음)
                    return scheduleItemRepository.findById(itemId)
                            .orElseThrow(() -> new IllegalArgumentException("스케줄 아이템을 찾을 수 없습니다."));

                } catch (Exception e) {
                    log.warn("스케줄 재계산 실패 (계속 진행): {}", e.getMessage());
                    // 재계산 실패해도 수면 시간 기록은 유지
                    return item;
                }
            }
        }

        return scheduleItemRepository.save(item);
    }
}

