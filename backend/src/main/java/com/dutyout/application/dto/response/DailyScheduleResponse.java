package com.dutyout.application.dto.response;

import com.dutyout.domain.schedule.entity.DailySchedule;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class DailyScheduleResponse {

    private Long id;
    private Long babyId;
    private LocalDate scheduleDate;
    private LocalTime wakeUpTime;
    private Integer ageInMonths;
    private List<ScheduleItemResponse> scheduleItems;

    public static DailyScheduleResponse from(DailySchedule schedule) {
        return DailyScheduleResponse.builder()
                .id(schedule.getId())
                .babyId(schedule.getBabyId())
                .scheduleDate(schedule.getScheduleDate())
                .wakeUpTime(schedule.getWakeUpTime())
                .ageInMonths(schedule.getAgeInMonths())
                .scheduleItems(schedule.getScheduleItems().stream()
                        .map(ScheduleItemResponse::from)
                        .collect(Collectors.toList()))
                .build();
    }
}
