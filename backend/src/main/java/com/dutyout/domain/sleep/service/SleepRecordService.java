package com.dutyout.domain.sleep.service;

import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.sleep.entity.SleepQuality;
import com.dutyout.domain.sleep.entity.SleepRecord;
import com.dutyout.domain.sleep.repository.SleepRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * 수면 기록 서비스
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class SleepRecordService {

    private final SleepRecordRepository sleepRecordRepository;

    /**
     * 수면 시작 기록
     */
    @Transactional
    public SleepRecord startSleep(SleepRecord sleepRecord) {
        // 진행 중인 수면이 있는지 확인
        sleepRecordRepository.findOngoingSleep(sleepRecord.getBabyId())
                .ifPresent(ongoing -> {
                    throw new BusinessException("SLEEP_002", "진행 중인 수면이 있습니다. 먼저 종료해주세요.");
                });

        log.info("수면 시작: babyId={}, type={}, time={}",
                sleepRecord.getBabyId(), sleepRecord.getType(), sleepRecord.getStartTime());

        return sleepRecordRepository.save(sleepRecord);
    }

    /**
     * 수면 종료 기록
     */
    @Transactional
    public SleepRecord endSleep(Long recordId, LocalDateTime endTime, SleepQuality quality, Integer wakeCount) {
        SleepRecord record = sleepRecordRepository.findById(recordId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SLEEP_RECORD_NOT_FOUND));

        if (!record.isOngoing()) {
            throw new BusinessException("SLEEP_003", "이미 종료된 수면 기록입니다.");
        }

        record.endSleep(endTime, quality, wakeCount);
        log.info("수면 종료: recordId={}, duration={}분", recordId, record.calculateDurationInMinutes());

        return record;
    }

    /**
     * 특정 날짜의 수면 기록 조회
     */
    public List<SleepRecord> getSleepRecordsByDate(Long babyId, LocalDate date) {
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);

        return sleepRecordRepository.findByBabyIdAndStartTimeBetween(babyId, startOfDay, endOfDay);
    }

    /**
     * 진행 중인 수면 조회
     */
    public SleepRecord getOngoingSleep(Long babyId) {
        return sleepRecordRepository.findOngoingSleep(babyId)
                .orElse(null);
    }
}
