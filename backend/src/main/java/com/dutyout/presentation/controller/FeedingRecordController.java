package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.FeedingRecordRequest;
import com.dutyout.application.dto.response.FeedingRecordResponse;
import com.dutyout.application.service.FeedingRecordService;
import com.dutyout.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 수유 기록 컨트롤러
 *
 * Clean Architecture - Presentation Layer
 *
 * 수유 기록 관련 HTTP 엔드포인트를 제공합니다.
 */
@Tag(name = "Feeding Records", description = "수유 기록 API")
@Slf4j
@RestController
@RequestMapping("/api/v1/babies/{babyId}/feeding-records")
@RequiredArgsConstructor
public class FeedingRecordController {

    private final FeedingRecordService feedingRecordService;

    /**
     * 수유 기록 생성
     */
    @Operation(summary = "수유 기록 생성", description = "새로운 수유 기록을 생성합니다.")
    @PostMapping
    public ResponseEntity<ApiResponse<FeedingRecordResponse>> createFeedingRecord(
            @PathVariable Long babyId,
            @Valid @RequestBody FeedingRecordRequest request) {
        log.info("POST /babies/{}/feeding-records", babyId);

        FeedingRecordResponse response = feedingRecordService.createFeedingRecord(babyId, request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * 수유 기록 단건 조회
     */
    @Operation(summary = "수유 기록 조회", description = "특정 수유 기록을 조회합니다.")
    @GetMapping("/{recordId}")
    public ResponseEntity<ApiResponse<FeedingRecordResponse>> getFeedingRecord(
            @PathVariable Long babyId,
            @PathVariable Long recordId) {
        log.info("GET /babies/{}/feeding-records/{}", babyId, recordId);

        FeedingRecordResponse response = feedingRecordService.getFeedingRecord(babyId, recordId);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 수유 기록 목록 조회
     */
    @Operation(summary = "수유 기록 목록 조회", description = "특정 아기의 모든 수유 기록을 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<FeedingRecordResponse>>> getFeedingRecords(
            @PathVariable Long babyId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        log.info("GET /babies/{}/feeding-records - startDate: {}, endDate: {}", babyId, startDate, endDate);

        List<FeedingRecordResponse> response;
        if (startDate != null && endDate != null) {
            response = feedingRecordService.getFeedingRecordsByDateRange(babyId, startDate, endDate);
        } else {
            response = feedingRecordService.getFeedingRecords(babyId);
        }

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 오늘 총 수유량 조회
     */
    @Operation(summary = "오늘 총 수유량 조회", description = "오늘 총 수유량(ml)을 조회합니다.")
    @GetMapping("/today-stats")
    public ResponseEntity<ApiResponse<Map<String, Integer>>> getTodayStats(@PathVariable Long babyId) {
        log.info("GET /babies/{}/feeding-records/today-stats", babyId);

        Integer totalAmount = feedingRecordService.getTotalFeedingAmountToday(babyId);

        return ResponseEntity.ok(ApiResponse.success(Map.of("totalAmountMl", totalAmount)));
    }

    /**
     * 수유 기록 수정
     */
    @Operation(summary = "수유 기록 수정", description = "수유 기록을 수정합니다.")
    @PutMapping("/{recordId}")
    public ResponseEntity<ApiResponse<FeedingRecordResponse>> updateFeedingRecord(
            @PathVariable Long babyId,
            @PathVariable Long recordId,
            @Valid @RequestBody FeedingRecordRequest request) {
        log.info("PUT /babies/{}/feeding-records/{}", babyId, recordId);

        FeedingRecordResponse response = feedingRecordService.updateFeedingRecord(babyId, recordId, request);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 수유 기록 삭제
     */
    @Operation(summary = "수유 기록 삭제", description = "수유 기록을 삭제합니다.")
    @DeleteMapping("/{recordId}")
    public ResponseEntity<ApiResponse<Void>> deleteFeedingRecord(
            @PathVariable Long babyId,
            @PathVariable Long recordId) {
        log.info("DELETE /babies/{}/feeding-records/{}", babyId, recordId);

        feedingRecordService.deleteFeedingRecord(babyId, recordId);

        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
