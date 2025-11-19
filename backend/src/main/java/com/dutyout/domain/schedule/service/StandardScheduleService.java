package com.dutyout.domain.schedule.service;

import com.dutyout.domain.schedule.entity.ActivityType;
import lombok.Builder;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 월령별 표준 스케줄 서비스
 *
 * 가이드 문서(monthly_sleep_feeding_guide.md)의 정상 상황 스케줄을 제공합니다.
 * 기상 시간 07:00 기준으로 정의되어 있으며, 실제 기상 시간에 맞게 조정하여 사용합니다.
 *
 * 수유 간격:
 * - 3~4개월: 3시간 간격
 * - 5개월: 3.5시간 간격
 * - 6개월 이상: 4시간 간격
 */
@Slf4j
@Service
public class StandardScheduleService {

    /**
     * 표준 스케줄 아이템
     */
    @Getter
    @Builder
    public static class StandardScheduleItem {
        private LocalTime time;
        private ActivityType activityType;
        private Integer durationMinutes;
        private String note;
    }

    private static final LocalTime BASE_WAKE_TIME = LocalTime.of(7, 0); // 기준 기상 시간

    /**
     * 월령별 표준 스케줄 조회
     *
     * @param ageInMonths 아기 개월 수
     * @return 표준 스케줄 아이템 리스트
     */
    public List<StandardScheduleItem> getStandardSchedule(int ageInMonths) {
        Map<Integer, List<StandardScheduleItem>> schedules = loadStandardSchedules();

        // 정확히 일치하는 스케줄 찾기
        if (schedules.containsKey(ageInMonths)) {
            return schedules.get(ageInMonths);
        }

        // 가장 가까운 하위 개월 수 찾기
        int closestAge = -1;
        for (int age : schedules.keySet()) {
            if (age <= ageInMonths && age > closestAge) {
                closestAge = age;
            }
        }

        if (closestAge == -1) {
            // 기본값: 3개월 스케줄
            closestAge = 3;
        }

        log.info("{}개월 아기의 표준 스케줄: {}개월 스케줄 사용", ageInMonths, closestAge);
        return schedules.get(closestAge);
    }

    /**
     * 기상 시간에 맞게 스케줄 조정
     *
     * @param standardSchedule 표준 스케줄
     * @param actualWakeTime 실제 기상 시간
     * @return 조정된 스케줄
     */
    public List<StandardScheduleItem> adjustScheduleToWakeTime(
            List<StandardScheduleItem> standardSchedule,
            LocalTime actualWakeTime) {

        // 시간 차이 계산 (분 단위)
        long minuteDiff = java.time.temporal.ChronoUnit.MINUTES.between(BASE_WAKE_TIME, actualWakeTime);

        List<StandardScheduleItem> adjusted = new ArrayList<>();
        for (StandardScheduleItem item : standardSchedule) {
            adjusted.add(StandardScheduleItem.builder()
                    .time(item.getTime().plusMinutes(minuteDiff))
                    .activityType(item.getActivityType())
                    .durationMinutes(item.getDurationMinutes())
                    .note(item.getNote())
                    .build());
        }

        return adjusted;
    }

    /**
     * 월령별 표준 스케줄 데이터 로드
     * (가이드 문서: monthly_sleep_feeding_guide.md 기준)
     */
    private Map<Integer, List<StandardScheduleItem>> loadStandardSchedules() {
        Map<Integer, List<StandardScheduleItem>> schedules = new HashMap<>();

        // 3개월 표준 스케줄 (수유 간격: 3시간)
        schedules.put(3, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 20, "수유 1"),
                item(8, 30, ActivityType.NAP1, 60, "낮잠 1 (1시간)"),
                item(9, 30, ActivityType.WAKE_UP, 0, "기상"),
                item(10, 15, ActivityType.FEEDING, 20, "수유 2"),  // 3시간 후
                item(11, 10, ActivityType.NAP2, 90, "낮잠 2 (1시간 30분)"),
                item(12, 40, ActivityType.WAKE_UP, 0, "기상"),
                item(13, 15, ActivityType.FEEDING, 20, "수유 3"),  // 3시간 후
                item(14, 25, ActivityType.NAP3, 45, "낮잠 3 (45분)"),
                item(15, 10, ActivityType.WAKE_UP, 0, "기상"),
                item(16, 15, ActivityType.FEEDING, 20, "수유 4"),  // 3시간 후
                item(17, 0, ActivityType.NAP4, 30, "낮잠 4 (30분)"),
                item(17, 30, ActivityType.WAKE_UP, 0, "기상"),
                item(19, 15, ActivityType.FEEDING, 20, "수유 5 (마지막)"),  // 3시간 후
                item(19, 30, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11시간)")
        ));

        // 4개월 표준 스케줄 (수유 간격: 3시간)
        schedules.put(4, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 20, "수유 1"),
                item(8, 50, ActivityType.NAP1, 70, "낮잠 1 (1시간 10분)"),
                item(10, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(10, 15, ActivityType.FEEDING, 20, "수유 2"),  // 3시간 후
                item(12, 15, ActivityType.NAP2, 105, "낮잠 2 (1시간 45분)"),
                item(14, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(13, 15, ActivityType.FEEDING, 20, "수유 3"),  // 3시간 후
                item(16, 15, ActivityType.NAP3, 45, "낮잠 3 (45분)"),
                item(17, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(16, 15, ActivityType.FEEDING, 20, "수유 4 (마지막)"),  // 3시간 후
                item(19, 0, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11-12시간)")
        ));

        // 5개월 표준 스케줄 (수유 간격: 3.5시간)
        schedules.put(5, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 20, "수유 1"),
                item(9, 0, ActivityType.NAP1, 90, "낮잠 1 (1시간 30분)"),
                item(10, 30, ActivityType.WAKE_UP, 0, "기상"),
                item(10, 45, ActivityType.FEEDING, 20, "수유 2"),  // 3.5시간 후
                item(12, 45, ActivityType.NAP2, 90, "낮잠 2 (1시간 30분)"),
                item(14, 15, ActivityType.WAKE_UP, 0, "기상"),
                item(14, 15, ActivityType.FEEDING, 20, "수유 3"),  // 3.5시간 후
                item(16, 30, ActivityType.NAP3, 60, "낮잠 3 (1시간)"),
                item(17, 30, ActivityType.WAKE_UP, 0, "기상"),
                item(17, 45, ActivityType.FEEDING, 20, "수유 4 (마지막)"),  // 3.5시간 후
                item(19, 15, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11-12시간)")
        ));

        // 6개월 표준 스케줄 (이유식 시작, 수유 간격: 4시간)
        schedules.put(6, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 20, "수유 1"),
                item(9, 0, ActivityType.NAP1, 105, "낮잠 1 (1시간 45분)"),
                item(10, 45, ActivityType.WAKE_UP, 0, "기상"),
                item(11, 15, ActivityType.FEEDING, 30, "이유식 + 수유 2"),  // 4시간 후
                item(13, 0, ActivityType.NAP2, 75, "낮잠 2 (1시간 15분)"),
                item(14, 15, ActivityType.WAKE_UP, 0, "기상"),
                item(15, 15, ActivityType.FEEDING, 20, "수유 3 (보충)"),  // 4시간 후
                item(16, 30, ActivityType.NAP3, 45, "낮잠 3 (45분)"),
                item(17, 15, ActivityType.WAKE_UP, 0, "기상"),
                item(19, 15, ActivityType.FEEDING, 20, "수유 4 (마지막)"),  // 4시간 후
                item(19, 30, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11-12시간)")
        ));

        // 7~8개월 표준 스케줄 (낮잠 2회, 수유 간격: 4시간)
        schedules.put(7, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 20, "수유 1"),
                item(9, 45, ActivityType.NAP1, 90, "낮잠 1 (1시간 30분)"),
                item(11, 15, ActivityType.WAKE_UP, 0, "기상"),
                item(11, 15, ActivityType.FEEDING, 30, "이유식 + 수유 2"),  // 4시간 후
                item(14, 15, ActivityType.NAP2, 75, "낮잠 2 (1시간 15분)"),
                item(15, 30, ActivityType.WAKE_UP, 0, "기상"),
                item(15, 15, ActivityType.FEEDING, 30, "이유식 + 수유 3"),  // 4시간 후
                item(19, 15, ActivityType.FEEDING, 20, "수유 4 (마지막)"),  // 4시간 후
                item(19, 30, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11-12시간)")
        ));
        schedules.put(8, schedules.get(7)); // 8개월도 동일

        // 11~12개월 표준 스케줄 (낮잠 2회)
        schedules.put(11, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 30, "아침식사"),
                item(9, 45, ActivityType.FEEDING, 15, "간식"),
                item(10, 30, ActivityType.NAP1, 60, "낮잠 1 (1시간)"),
                item(11, 30, ActivityType.WAKE_UP, 0, "기상"),
                item(11, 45, ActivityType.FEEDING, 30, "점심식사"),
                item(14, 30, ActivityType.FEEDING, 15, "간식"),
                item(15, 0, ActivityType.NAP2, 60, "낮잠 2 (1시간)"),
                item(16, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(16, 15, ActivityType.FEEDING, 15, "간식"),
                item(18, 30, ActivityType.FEEDING, 30, "저녁식사"),
                item(20, 0, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11시간)")
        ));

        // 12~24개월 표준 스케줄 (낮잠 1회)
        schedules.put(12, List.of(
                item(7, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(7, 15, ActivityType.FEEDING, 30, "아침식사"),
                item(10, 0, ActivityType.FEEDING, 15, "간식"),
                item(11, 30, ActivityType.FEEDING, 30, "점심식사"),
                item(12, 30, ActivityType.NAP1, 90, "낮잠 (1시간 30분~2시간)"),
                item(14, 0, ActivityType.WAKE_UP, 0, "기상"),
                item(14, 15, ActivityType.FEEDING, 15, "간식"),
                item(18, 0, ActivityType.FEEDING, 30, "저녁식사"),
                item(20, 0, ActivityType.BEDTIME, 660, "취침 (야간 수면 약 11시간)")
        ));
        schedules.put(18, schedules.get(12)); // 18개월도 유사
        schedules.put(24, schedules.get(12)); // 24개월도 유사

        return schedules;
    }

    /**
     * 스케줄 아이템 생성 헬퍼
     */
    private StandardScheduleItem item(int hour, int minute, ActivityType type, int duration, String note) {
        return StandardScheduleItem.builder()
                .time(LocalTime.of(hour, minute))
                .activityType(type)
                .durationMinutes(duration)
                .note(note)
                .build();
    }
}
