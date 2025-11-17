package com.dutyout.application.dto.request;

import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 스케줄 항목 수정 요청 DTO
 */
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UpdateScheduleItemRequest {

    private String scheduledTime; // HH:mm 형식

    private String activity; // 활동명

    private Integer feedingAmount; // 수유량 (ml) - 수유 활동일 때만

    private Integer actualSleepDuration; // 실제 수면 시간 (분) - 수면 활동일 때만

    public UpdateScheduleItemRequest(String scheduledTime, String activity,
                                     Integer feedingAmount, Integer actualSleepDuration) {
        this.scheduledTime = scheduledTime;
        this.activity = activity;
        this.feedingAmount = feedingAmount;
        this.actualSleepDuration = actualSleepDuration;
    }
}
