package com.dutyout.application.service;

import com.dutyout.application.dto.request.FeedingRecordRequest;
import com.dutyout.application.dto.response.FeedingRecordResponse;
import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.feeding.entity.FeedingRecord;
import com.dutyout.domain.feeding.repository.FeedingRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 수유 기록 서비스
 *
 * Clean Architecture - Application Layer
 * DDD - Application Service
 *
 * 수유 기록의 CRUD 및 통계 관련 비즈니스 로직을 처리합니다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FeedingRecordService {

    private final FeedingRecordRepository feedingRecordRepository;

    /**
     * 수유 기록 생성
     */
    @Transactional
    public FeedingRecordResponse createFeedingRecord(Long babyId, FeedingRecordRequest request) {
        log.info("수유 기록 생성 - Baby ID: {}, Type: {}", babyId, request.getType());

        FeedingRecord record = FeedingRecord.builder()
                .babyId(babyId)
                .feedingTime(request.getFeedingTime())
                .type(request.getType())
                .amountMl(request.getAmountMl())
                .note(request.getNote())
                .build();

        record = feedingRecordRepository.save(record);
        log.info("수유 기록 생성 완료 - Record ID: {}", record.getId());

        return FeedingRecordResponse.from(record);
    }

    /**
     * 수유 기록 조회
     */
    public FeedingRecordResponse getFeedingRecord(Long babyId, Long recordId) {
        FeedingRecord record = feedingRecordRepository.findById(recordId)
                .orElseThrow(() -> new BusinessException(ErrorCode.FEEDING_RECORD_NOT_FOUND));

        // 권한 검증
        if (!record.getBabyId().equals(babyId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        return FeedingRecordResponse.from(record);
    }

    /**
     * 특정 아기의 모든 수유 기록 조회
     */
    public List<FeedingRecordResponse> getFeedingRecords(Long babyId) {
        List<FeedingRecord> records = feedingRecordRepository.findByBabyIdOrderByFeedingTimeDesc(babyId);
        return records.stream()
                .map(FeedingRecordResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 기간별 수유 기록 조회
     */
    public List<FeedingRecordResponse> getFeedingRecordsByDateRange(Long babyId,
                                                                     LocalDateTime startDate,
                                                                     LocalDateTime endDate) {
        List<FeedingRecord> records = feedingRecordRepository
                .findByBabyIdAndFeedingTimeBetweenOrderByFeedingTimeDesc(babyId, startDate, endDate);

        return records.stream()
                .map(FeedingRecordResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 오늘 총 수유량 조회
     */
    public Integer getTotalFeedingAmountToday(Long babyId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        return feedingRecordRepository.getTotalAmountToday(babyId, startOfDay, endOfDay);
    }

    /**
     * 수유 기록 수정
     */
    @Transactional
    public FeedingRecordResponse updateFeedingRecord(Long babyId, Long recordId,
                                                     FeedingRecordRequest request) {
        log.info("수유 기록 수정 - Record ID: {}", recordId);

        FeedingRecord record = feedingRecordRepository.findById(recordId)
                .orElseThrow(() -> new BusinessException(ErrorCode.FEEDING_RECORD_NOT_FOUND));

        // 권한 검증
        if (!record.getBabyId().equals(babyId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        record.update(request.getFeedingTime(), request.getType(),
                request.getAmountMl(), request.getNote());

        log.info("수유 기록 수정 완료 - Record ID: {}", recordId);

        return FeedingRecordResponse.from(record);
    }

    /**
     * 수유 기록 삭제
     */
    @Transactional
    public void deleteFeedingRecord(Long babyId, Long recordId) {
        log.info("수유 기록 삭제 - Record ID: {}", recordId);

        FeedingRecord record = feedingRecordRepository.findById(recordId)
                .orElseThrow(() -> new BusinessException(ErrorCode.FEEDING_RECORD_NOT_FOUND));

        // 권한 검증
        if (!record.getBabyId().equals(babyId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }

        feedingRecordRepository.delete(record);
        log.info("수유 기록 삭제 완료 - Record ID: {}", recordId);
    }
}
