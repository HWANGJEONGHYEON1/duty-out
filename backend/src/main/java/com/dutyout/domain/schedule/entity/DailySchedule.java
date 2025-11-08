package com.dutyout.domain.schedule.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 일일 스케줄 엔티티
 *
 * 하루 전체 일과를 관리합니다.
 * 기상시간 기반으로 자동 생성됩니다.
 */
@Entity
@Table(name = "daily_schedules", indexes = {
        @Index(name = "idx_baby_id_date", columnList = "babyId,scheduleDate", unique = true)
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class DailySchedule extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long babyId;

    @Column(nullable = false)
    private LocalDate scheduleDate;

    @Column(nullable = false)
    private LocalTime wakeUpTime;

    @Column(nullable = false)
    private Integer ageInMonths; // 스케줄 생성 시점의 월령 (템플릿 선택용)

    @OneToMany(mappedBy = "dailySchedule", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("scheduledTime ASC")
    private List<ScheduleItem> scheduleItems = new ArrayList<>();

    @Builder
    private DailySchedule(Long babyId, LocalDate scheduleDate, LocalTime wakeUpTime, Integer ageInMonths) {
        validateBabyId(babyId);
        validateScheduleDate(scheduleDate);
        validateWakeUpTime(wakeUpTime);
        validateAgeInMonths(ageInMonths);

        this.babyId = babyId;
        this.scheduleDate = scheduleDate;
        this.wakeUpTime = wakeUpTime;
        this.ageInMonths = ageInMonths;
    }

    /**
     * 스케줄 항목 추가
     */
    public void addScheduleItem(ScheduleItem item) {
        item.setDailySchedule(this);
        this.scheduleItems.add(item);
    }

    /**
     * 스케줄 항목들 일괄 추가
     */
    public void addScheduleItems(List<ScheduleItem> items) {
        items.forEach(this::addScheduleItem);
    }

    /**
     * 기상시간 변경 (스케줄 재생성 필요)
     */
    public void updateWakeUpTime(LocalTime wakeUpTime) {
        validateWakeUpTime(wakeUpTime);
        this.wakeUpTime = wakeUpTime;
    }

    /**
     * 모든 스케줄 항목 제거
     */
    public void clearScheduleItems() {
        this.scheduleItems.clear();
    }

    // Validation 메서드들
    private void validateBabyId(Long babyId) {
        if (babyId == null || babyId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 아기 ID입니다.");
        }
    }

    private void validateScheduleDate(LocalDate scheduleDate) {
        if (scheduleDate == null) {
            throw new IllegalArgumentException("스케줄 날짜는 필수입니다.");
        }
    }

    private void validateWakeUpTime(LocalTime wakeUpTime) {
        if (wakeUpTime == null) {
            throw new IllegalArgumentException("기상 시간은 필수입니다.");
        }
    }

    private void validateAgeInMonths(Integer ageInMonths) {
        if (ageInMonths == null || ageInMonths < 0 || ageInMonths > 36) {
            throw new IllegalArgumentException("유효하지 않은 월령입니다.");
        }
    }
}
