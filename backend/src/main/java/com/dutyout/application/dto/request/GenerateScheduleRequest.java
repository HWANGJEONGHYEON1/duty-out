package com.dutyout.application.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
@NoArgsConstructor
public class GenerateScheduleRequest {

    @NotNull(message = "스케줄 날짜는 필수입니다.")
    private LocalDate scheduleDate;

    @NotNull(message = "기상 시간은 필수입니다.")
    private LocalTime wakeUpTime;
}
