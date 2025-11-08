package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.GenerateScheduleRequest;
import com.dutyout.application.dto.response.DailyScheduleResponse;
import com.dutyout.common.response.ApiResponse;
import com.dutyout.domain.schedule.entity.DailySchedule;
import com.dutyout.domain.schedule.service.ScheduleGenerationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

/**
 * 스케줄 관리 API
 */
@RestController
@RequestMapping("/api/v1/babies/{babyId}/schedules")
@RequiredArgsConstructor
@Tag(name = "Schedule", description = "스케줄 관리 API")
public class ScheduleController {

    private final ScheduleGenerationService scheduleGenerationService;

    @PostMapping("/generate")
    @Operation(summary = "스케줄 자동 생성", description = "기상시간 기반 일일 스케줄을 자동 생성합니다.")
    public ResponseEntity<ApiResponse<DailyScheduleResponse>> generateSchedule(
            @PathVariable Long babyId,
            @Valid @RequestBody GenerateScheduleRequest request) {

        DailySchedule schedule = scheduleGenerationService.generateSchedule(
                babyId,
                request.getScheduleDate(),
                request.getWakeUpTime()
        );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(DailyScheduleResponse.from(schedule)));
    }

    @GetMapping
    @Operation(summary = "스케줄 조회", description = "특정 날짜의 스케줄을 조회합니다.")
    public ResponseEntity<ApiResponse<DailyScheduleResponse>> getSchedule(
            @PathVariable Long babyId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        DailySchedule schedule = scheduleGenerationService.getSchedule(babyId, date);
        return ResponseEntity.ok(ApiResponse.success(DailyScheduleResponse.from(schedule)));
    }
}
