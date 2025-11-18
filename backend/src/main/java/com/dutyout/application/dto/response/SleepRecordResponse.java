package com.dutyout.application.dto.response;

import com.dutyout.domain.sleep.entity.SleepQuality;
import com.dutyout.domain.sleep.entity.SleepRecord;
import com.dutyout.domain.sleep.entity.SleepType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Getter
@Builder
public class SleepRecordResponse {

    private Long id;
    private SleepType type;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private Integer durationMinutes;
    private SleepQuality quality;
    private Integer wakeCount;
    private String memo;

    public static SleepRecordResponse from(SleepRecord record) {
        return SleepRecordResponse.builder()
                .id(record.getId())
                .type(record.getType())
                .startTime(record.getStartTime())
                .endTime(record.getEndTime())
                .durationMinutes(record.calculateDurationInMinutes())
                .quality(record.getQuality())
                .wakeCount(record.getWakeCount())
                .memo(record.getMemo())
                .build();
    }
}
