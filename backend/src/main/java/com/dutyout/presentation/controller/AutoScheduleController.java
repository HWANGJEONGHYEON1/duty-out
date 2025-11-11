package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.AdjustScheduleRequest;
import com.dutyout.application.dto.request.GenerateAutoScheduleRequest;
import com.dutyout.application.dto.response.AutoScheduleResponse;
import com.dutyout.application.service.AutoScheduleService;
import com.dutyout.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 자동 스케줄 컨트롤러
 *
 * Clean Architecture - Presentation Layer
 *
 * 개월수 기반 자동 스케줄 생성 및 동적 조정 API를 제공합니다.
 *
 * 엔드포인트:
 * - POST /babies/{babyId}/auto-schedule : 자동 스케줄 생성
 * - PUT /babies/{babyId}/auto-schedule/adjust : 스케줄 동적 조정
 */
@Tag(name = "Auto Schedule", description = "자동 스케줄 생성 API")
@Slf4j
@RestController
@RequestMapping("/babies/{babyId}/auto-schedule")
@RequiredArgsConstructor
public class AutoScheduleController {

    private final AutoScheduleService autoScheduleService;

    /**
     * 자동 스케줄 생성
     *
     * 아기의 개월 수와 기상 시간을 기반으로 하루 스케줄을 자동 생성합니다.
     *
     * 생성되는 스케줄:
     * - 개월수별 권장 깨시(깨어있는 시간) 적용
     * - 낮잠 횟수 및 시간 자동 계산
     * - 수유 간격 고려한 수유 시간 배치
     * - 권장 취침 시간 제안
     *
     * @param babyId 아기 ID
     * @param request 생성 요청 (기상 시간)
     * @return 생성된 스케줄
     */
    @Operation(summary = "자동 스케줄 생성", description = "개월 수와 기상 시간 기반으로 하루 스케줄을 자동 생성합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<AutoScheduleResponse>> generateAutoSchedule(
            @PathVariable Long babyId,
            @Valid @RequestBody GenerateAutoScheduleRequest request) {
        log.info("POST /babies/{}/auto-schedule - 기상 시간: {}", babyId, request.getWakeUpTime());

        AutoScheduleResponse response = autoScheduleService.generateAutoSchedule(babyId, request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * 스케줄 동적 조정
     *
     * 실제 낮잠 시간이나 활동 시간이 예정과 다를 경우,
     * 이후 스케줄을 자동으로 재조정하여 과피로를 방지합니다.
     *
     * 조정 로직:
     * - 실제 시간과 예정 시간의 차이 계산
     * - 이후 모든 활동의 시간을 자동 조정
     * - 깨시 초과 여부 체크 및 경고
     * - 쪽잠 필요 여부 판단
     *
     * @param babyId 아기 ID
     * @param request 조정 요청
     * @return 조정된 스케줄
     */
    @Operation(summary = "스케줄 동적 조정", description = "실제 수면 시간 변경 시 이후 스케줄을 자동 재조정합니다.")
    @PutMapping("/adjust")
    public ResponseEntity<ApiResponse<AutoScheduleResponse>> adjustSchedule(
            @PathVariable Long babyId,
            @Valid @RequestBody AdjustScheduleRequest request) {
        log.info("PUT /babies/{}/auto-schedule/adjust - Item ID: {}", babyId, request.getScheduleItemId());

        AutoScheduleResponse response = autoScheduleService.adjustSchedule(babyId, request);

        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
