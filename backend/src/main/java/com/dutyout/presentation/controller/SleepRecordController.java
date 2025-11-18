package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.SleepRecordRequest;
import com.dutyout.application.dto.response.SleepRecordResponse;
import com.dutyout.application.dto.response.WeeklyStatisticsResponse;
import com.dutyout.common.response.ApiResponse;
import com.dutyout.domain.sleep.service.SleepRecordService;
import com.dutyout.domain.sleep.service.SleepStatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 수면 기록 컨트롤러
 *
 * Clean Architecture - Presentation Layer
 *
 * 수면 기록 관련 HTTP 엔드포인트를 제공합니다.
 */
@Tag(name = "Sleep Records", description = "수면 기록 API")
@Slf4j
@RestController
@RequestMapping("/api/v1/babies/{babyId}/sleep-records")
@RequiredArgsConstructor
public class SleepRecordController {

    private final SleepRecordService sleepRecordService;
    private final SleepStatisticsService sleepStatisticsService;

    /**
     * 수면 기록 생성
     */
    @Operation(summary = "수면 기록 생성", description = "새로운 수면 기록을 생성합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<SleepRecordResponse>> createSleepRecord(
            @PathVariable Long babyId,
            @Valid @RequestBody SleepRecordRequest request) {
        log.info("POST /babies/{}/sleep-records", babyId);

        var sleepRecord = sleepRecordService.startSleep(request.toEntity(babyId));
        SleepRecordResponse response = SleepRecordResponse.from(sleepRecord);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * 특정 날짜의 수면 기록 조회
     */
    @Operation(summary = "날짜별 수면 기록 조회", description = "특정 날짜의 모든 수면 기록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<SleepRecordResponse>>> getSleepRecords(
            @PathVariable Long babyId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        log.info("GET /babies/{}/sleep-records?date={}", babyId, date);

        var records = sleepRecordService.getSleepRecordsByDate(babyId, date);
        List<SleepRecordResponse> responses = records.stream()
                .map(SleepRecordResponse::from)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(responses));
    }

    /**
     * 최근 7일 통계 조회
     */
    @Operation(summary = "주간 통계 조회", description = "최근 7일간의 수면 및 수유 통계를 조회합니다.")
    @GetMapping("/statistics/weekly")
    public ResponseEntity<ApiResponse<WeeklyStatisticsResponse>> getWeeklyStatistics(
            @PathVariable Long babyId) {
        log.info("GET /babies/{}/sleep-records/statistics/weekly", babyId);

        WeeklyStatisticsResponse stats = sleepStatisticsService.getWeeklyStatistics(babyId);

        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    /**
     * 월간 통계 조회
     */
    @Operation(summary = "월간 통계 조회", description = "이번 달의 수면 및 수유 통계를 조회합니다.")
    @GetMapping("/statistics/monthly")
    public ResponseEntity<ApiResponse<WeeklyStatisticsResponse>> getMonthlyStatistics(
            @PathVariable Long babyId) {
        log.info("GET /babies/{}/sleep-records/statistics/monthly", babyId);

        WeeklyStatisticsResponse stats = sleepStatisticsService.getMonthlyStatistics(babyId);

        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}
