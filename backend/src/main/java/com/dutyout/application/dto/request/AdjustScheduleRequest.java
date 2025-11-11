package com.dutyout.application.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

/**
 * 스케줄 조정 요청 DTO
 *
 * Clean Architecture - Application Layer
 *
 * 실제 낮잠 시간이나 활동 시간이 변경되었을 때 이후 스케줄을 자동 재조정합니다.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdjustScheduleRequest {

    /**
     * 조정할 스케줄 아이템 ID
     */
    @NotNull(message = "스케줄 아이템 ID는 필수입니다.")
    private Long scheduleItemId;

    /**
     * 실제 시작 시간
     * null이면 원래 시간 유지
     */
    private LocalTime actualStartTime;

    /**
     * 실제 종료 시간
     * null이면 원래 시간 유지
     */
    private LocalTime actualEndTime;

    /**
     * 실제 지속 시간 (분)
     * 낮잠 시간 등에 사용
     */
    @Positive(message = "지속 시간은 0보다 커야 합니다.")
    private Integer actualDurationMinutes;
}
