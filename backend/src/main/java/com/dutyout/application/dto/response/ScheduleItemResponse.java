package com.dutyout.application.dto.response;

import com.dutyout.domain.schedule.entity.ActivityType;
import com.dutyout.domain.schedule.entity.ScheduleItem;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalTime;

@Getter
@Builder
public class ScheduleItemResponse {

    private Long id;
    private ActivityType activityType;
    private LocalTime scheduledTime;
    private Integer durationMinutes;
    private String note;

    public static ScheduleItemResponse from(ScheduleItem item) {
        return ScheduleItemResponse.builder()
                .id(item.getId())
                .activityType(item.getActivityType())
                .scheduledTime(item.getScheduledTime())
                .durationMinutes(item.getDurationMinutes())
                .note(item.getNote())
                .build();
    }
}
