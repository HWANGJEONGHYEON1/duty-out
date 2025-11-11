package com.dutyout.application.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

/**
 * 자동 스케줄 생성 요청 DTO
 *
 * Clean Architecture - Application Layer
 *
 * 아기의 개월 수와 기상 시간을 기반으로 하루 스케줄을 자동 생성합니다.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GenerateAutoScheduleRequest {

    /**
     * 기상 시간
     * 예: 07:00
     */
    @NotNull(message = "기상 시간은 필수입니다.")
    private LocalTime wakeUpTime;

    /**
     * 수유 유형 선택 (선택사항)
     * true: 모유, false: 분유
     * null인 경우 기본값(모유) 사용
     */
    private Boolean isBreastfeeding;
}
