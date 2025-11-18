package com.dutyout.application.dto.request;

import com.dutyout.domain.sleep.entity.SleepQuality;
import com.dutyout.domain.sleep.entity.SleepRecord;
import com.dutyout.domain.sleep.entity.SleepType;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SleepRecordRequest {

    @NotNull(message = "수면 타입은 필수입니다")
    private SleepType type; // NAP, NIGHT, etc.

    @NotNull(message = "수면 시작 시간은 필수입니다")
    private LocalDateTime startTime;

    private LocalDateTime endTime;

    private SleepQuality quality;

    private Integer wakeCount;

    private String memo;

    public SleepRecord toEntity(Long babyId) {
        return SleepRecord.builder()
                .babyId(babyId)
                .type(type)
                .startTime(startTime)
                .endTime(endTime)
                .quality(quality)
                .wakeCount(wakeCount)
                .memo(memo)
                .build();
    }
}
