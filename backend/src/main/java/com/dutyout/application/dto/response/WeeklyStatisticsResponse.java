package com.dutyout.application.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.List;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WeeklyStatisticsResponse {

    private LocalDate startDate;
    private LocalDate endDate;
    private List<DailyStatistics> dailyStats;
    private Integer totalSleepMinutes;
    private Integer averageSleepMinutes;
    private Integer totalFeedingAmount;
    private Integer averageFeedingAmount;
    private Boolean hasEnoughData; // 7일 이상의 데이터가 있는지

    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyStatistics {
        private LocalDate date;
        private Integer sleepMinutes; // 0이면 데이터 없음
        private Integer feedingAmount; // 0이면 데이터 없음
        private String dayOfWeek; // "Mon", "Tue", etc.
    }
}
