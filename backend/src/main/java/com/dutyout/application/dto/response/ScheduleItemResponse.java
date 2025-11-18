package com.dutyout.application.dto.response;

import com.dutyout.domain.schedule.entity.ActivityType;
import com.dutyout.domain.schedule.entity.ScheduleItem;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.time.LocalTime;

@Getter
@Builder
public class ScheduleItemResponse {

    private Long id;
    private ActivityType activityType;
    private String activityName;
    private LocalTime scheduledTime;
    private Integer durationMinutes;
    private String note;
    private Integer feedingAmount;
    private Integer actualSleepDuration;
    private LocalDateTime actualFeedingTime;
    private LocalDateTime actualSleepStartTime;

    public static ScheduleItemResponse from(ScheduleItem item) {
        return ScheduleItemResponse.builder()
                .id(item.getId())
                .activityType(item.getActivityType())
                .activityName(item.getActivityType().getKoreanName())
                .scheduledTime(item.getScheduledTime())
                .durationMinutes(item.getDurationMinutes())
                .note(item.getNote())
                .feedingAmount(item.getFeedingAmount())
                .actualSleepDuration(item.getActualSleepDuration())
                .actualFeedingTime(item.getActualFeedingTime())
                .actualSleepStartTime(item.getActualSleepStartTime())
                .build();
    }
}
