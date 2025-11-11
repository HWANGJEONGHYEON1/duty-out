package com.dutyout.application.dto.request;

import com.dutyout.domain.feeding.entity.FeedingType;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 수유 기록 요청 DTO
 *
 * Clean Architecture - Application Layer
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeedingRecordRequest {

    @NotNull(message = "수유 시간은 필수입니다.")
    private LocalDateTime feedingTime;

    @NotNull(message = "수유 유형은 필수입니다.")
    private FeedingType type;

    @Positive(message = "수유량은 0보다 커야 합니다.")
    private Integer amountMl;

    private String note;
}
