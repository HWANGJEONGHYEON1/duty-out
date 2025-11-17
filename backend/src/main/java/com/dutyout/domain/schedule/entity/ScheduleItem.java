package com.dutyout.domain.schedule.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * 스케줄 항목 엔티티
 *
 * 개별 일정 (기상, 낮잠, 수유, 취침 등)
 */
@Entity
@Table(name = "schedule_items")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ScheduleItem extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "daily_schedule_id", nullable = false)
    private DailySchedule dailySchedule;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ActivityType activityType;

    @Column(nullable = false)
    private LocalTime scheduledTime;

    @Column
    private Integer durationMinutes; // 예상 소요 시간 (분)

    @Column(length = 200)
    private String note;

    // 수유 및 수면 기록 필드
    @Column
    private Integer feedingAmount; // 수유량 (ml)

    @Column
    private Integer actualSleepDuration; // 실제 수면 시간 (분)

    @Column
    private LocalDateTime actualFeedingTime; // 실제 수유 시간

    @Column
    private LocalDateTime actualSleepStartTime; // 실제 수면 시작 시간

    @Builder
    private ScheduleItem(ActivityType activityType, LocalTime scheduledTime,
                         Integer durationMinutes, String note) {
        validateActivityType(activityType);
        validateScheduledTime(scheduledTime);

        this.activityType = activityType;
        this.scheduledTime = scheduledTime;
        this.durationMinutes = durationMinutes;
        this.note = note;
    }

    /**
     * DailySchedule 연결
     */
    protected void setDailySchedule(DailySchedule dailySchedule) {
        this.dailySchedule = dailySchedule;
    }

    /**
     * 스케줄 시간 변경
     */
    public void updateScheduledTime(LocalTime scheduledTime) {
        validateScheduledTime(scheduledTime);
        this.scheduledTime = scheduledTime;
    }

    /**
     * 소요 시간 변경
     */
    public void updateDuration(Integer durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    /**
     * 수유량 기록
     */
    public void recordFeeding(Integer feedingAmount) {
        this.feedingAmount = feedingAmount;
        this.actualFeedingTime = LocalDateTime.now();
    }

    /**
     * 수면 시간 기록
     */
    public void recordSleep(Integer durationMinutes) {
        this.actualSleepDuration = durationMinutes;
        this.actualSleepStartTime = LocalDateTime.now();
    }

    // Validation 메서드들
    private void validateActivityType(ActivityType activityType) {
        if (activityType == null) {
            throw new IllegalArgumentException("활동 타입은 필수입니다.");
        }
    }

    private void validateScheduledTime(LocalTime scheduledTime) {
        if (scheduledTime == null) {
            throw new IllegalArgumentException("스케줄 시간은 필수입니다.");
        }
    }
}
