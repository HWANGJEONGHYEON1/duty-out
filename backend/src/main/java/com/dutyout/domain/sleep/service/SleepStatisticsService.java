package com.dutyout.domain.sleep.service;

import com.dutyout.application.dto.response.WeeklyStatisticsResponse;
import com.dutyout.application.service.FeedingRecordService;
import com.dutyout.domain.sleep.entity.SleepRecord;
import com.dutyout.domain.sleep.repository.SleepRecordRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 수면 통계 서비스
 *
 * 주간/월간 통계 데이터를 제공합니다.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class SleepStatisticsService {

    private final SleepRecordRepository sleepRecordRepository;
    private final FeedingRecordService feedingRecordService;

    /**
     * 최근 7일 주간 통계 조회
     */
    public WeeklyStatisticsResponse getWeeklyStatistics(Long babyId) {
        LocalDate today = LocalDate.now();
        LocalDate sevenDaysAgo = today.minusDays(6);

        return getStatistics(babyId, sevenDaysAgo, today);
    }

    /**
     * 이번 달 월간 통계 조회
     */
    public WeeklyStatisticsResponse getMonthlyStatistics(Long babyId) {
        LocalDate today = LocalDate.now();
        YearMonth currentMonth = YearMonth.from(today);
        LocalDate firstDay = currentMonth.atDay(1);

        return getStatistics(babyId, firstDay, today);
    }

    /**
     * 날짜 범위 통계 조회
     */
    private WeeklyStatisticsResponse getStatistics(Long babyId, LocalDate startDate, LocalDate endDate) {
        // 수면 기록 조회
        LocalDateTime startDateTime = startDate.atStartOfDay();
        LocalDateTime endDateTime = endDate.atTime(LocalTime.MAX);

        List<SleepRecord> sleepRecords = sleepRecordRepository.findByBabyIdAndStartTimeBetween(
                babyId, startDateTime, endDateTime
        );

        // 일별 통계 계산
        Map<LocalDate, Integer> sleepByDate = new HashMap<>();
        int totalSleepMinutes = 0;

        for (SleepRecord record : sleepRecords) {
            if (record.isCompleted()) {
                int durationMinutes = record.calculateDurationInMinutes();
                LocalDate recordDate = record.getStartTime().toLocalDate();
                sleepByDate.merge(recordDate, durationMinutes, Integer::sum);
                totalSleepMinutes += durationMinutes;
            }
        }

        // 수유 기록 조회
        Map<LocalDate, Integer> feedingByDate = new HashMap<>();
        int totalFeedingAmount = 0;

        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            try {
                int amount = feedingRecordService.getTotalFeedingAmountByDate(babyId, date);
                if (amount > 0) {
                    feedingByDate.put(date, amount);
                    totalFeedingAmount += amount;
                }
            } catch (Exception e) {
                log.debug("수유 기록 조회 실패: babyId={}, date={}", babyId, date);
            }
        }

        // 일별 통계 리스트 생성
        List<WeeklyStatisticsResponse.DailyStatistics> dailyStats = new ArrayList<>();
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            WeeklyStatisticsResponse.DailyStatistics dailyStat = WeeklyStatisticsResponse.DailyStatistics.builder()
                    .date(date)
                    .sleepMinutes(sleepByDate.getOrDefault(date, 0))
                    .feedingAmount(feedingByDate.getOrDefault(date, 0))
                    .dayOfWeek(date.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH))
                    .build();
            dailyStats.add(dailyStat);
        }

        // 평균 계산
        long days = dailyStats.size();
        int averageSleepMinutes = days > 0 ? (int) (totalSleepMinutes / days) : 0;
        int averageFeedingAmount = days > 0 ? (int) (totalFeedingAmount / days) : 0;

        // 7일 이상 데이터 여부
        long dataAvailableDays = dailyStats.stream()
                .filter(d -> d.getSleepMinutes() > 0 || d.getFeedingAmount() > 0)
                .count();
        boolean hasEnoughData = dataAvailableDays >= 7;

        return WeeklyStatisticsResponse.builder()
                .startDate(startDate)
                .endDate(endDate)
                .dailyStats(dailyStats)
                .totalSleepMinutes(totalSleepMinutes)
                .averageSleepMinutes(averageSleepMinutes)
                .totalFeedingAmount(totalFeedingAmount)
                .averageFeedingAmount(averageFeedingAmount)
                .hasEnoughData(hasEnoughData)
                .build();
    }
}
