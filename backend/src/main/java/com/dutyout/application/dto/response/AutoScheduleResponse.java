package com.dutyout.application.dto.response;

import com.dutyout.domain.schedule.entity.ActivityType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;
import java.util.List;

/**
 * 자동 생성된 스케줄 응답 DTO
 *
 * Clean Architecture - Application Layer
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AutoScheduleResponse {

    /**
     * 스케줄 ID
     */
    private Long scheduleId;

    /**
     * 아기 ID
     */
    private Long babyId;

    /**
     * 아기 개월 수
     */
    private Integer ageInMonths;

    /**
     * 기상 시간
     */
    private LocalTime wakeUpTime;

    /**
     * 취침 시간
     */
    private LocalTime bedtime;

    /**
     * 총 낮잠 횟수
     */
    private Integer totalNapCount;

    /**
     * 총 수유 횟수
     */
    private Integer totalFeedingCount;

    /**
     * 스케줄 아이템 목록
     */
    private List<ScheduleItemDetail> items;

    /**
     * 스케줄 아이템 상세
     */
    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ScheduleItemDetail {
        private Long id;
        private LocalTime startTime;
        private LocalTime endTime;
        private ActivityType activityType;
        private String activityName;
        private Integer durationMinutes;
        private String note;
        private Integer sequence;
    }
}
