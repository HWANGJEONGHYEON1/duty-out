package com.dutyout.application.dto.response;

import com.dutyout.domain.feeding.entity.FeedingRecord;
import com.dutyout.domain.feeding.entity.FeedingType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 수유 기록 응답 DTO
 *
 * Clean Architecture - Application Layer
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FeedingRecordResponse {

    private Long id;
    private Long babyId;
    private LocalDateTime feedingTime;
    private FeedingType type;
    private Integer amountMl;
    private String note;
    private LocalDateTime createdAt;

    /**
     * Entity to DTO 변환
     */
    public static FeedingRecordResponse from(FeedingRecord record) {
        return FeedingRecordResponse.builder()
                .id(record.getId())
                .babyId(record.getBabyId())
                .feedingTime(record.getFeedingTime())
                .type(record.getType())
                .amountMl(record.getAmountMl())
                .note(record.getNote())
                .createdAt(record.getCreatedAt())
                .build();
    }
}
