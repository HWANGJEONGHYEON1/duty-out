package com.dutyout.domain.sleep.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Duration;
import java.time.LocalDateTime;

/**
 * 수면 기록 엔티티
 */
@Entity
@Table(name = "sleep_records", indexes = {
        @Index(name = "idx_baby_id_start_time", columnList = "babyId,startTime")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class SleepRecord extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long babyId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SleepType type;

    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column
    private LocalDateTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private SleepQuality quality;

    @Column
    private Integer wakeCount; // 깨어난 횟수

    @Column(length = 500)
    private String memo;

    @Builder
    private SleepRecord(Long babyId, SleepType type, LocalDateTime startTime,
                        LocalDateTime endTime, SleepQuality quality,
                        Integer wakeCount, String memo) {
        validateBabyId(babyId);
        validateType(type);
        validateStartTime(startTime);
        if (endTime != null) {
            validateEndTime(startTime, endTime);
        }

        this.babyId = babyId;
        this.type = type;
        this.startTime = startTime;
        this.endTime = endTime;
        this.quality = quality;
        this.wakeCount = wakeCount;
        this.memo = memo;
    }

    /**
     * 수면 종료
     */
    public void endSleep(LocalDateTime endTime, SleepQuality quality, Integer wakeCount) {
        validateEndTime(this.startTime, endTime);
        this.endTime = endTime;
        this.quality = quality;
        this.wakeCount = wakeCount;
    }

    /**
     * 수면 시간 계산 (분 단위)
     */
    public long calculateDurationInMinutes() {
        if (endTime == null) {
            return 0;
        }
        return Duration.between(startTime, endTime).toMinutes();
    }

    /**
     * 진행 중인 수면인지 확인
     */
    public boolean isOngoing() {
        return endTime == null;
    }

    // Validation 메서드들
    private void validateBabyId(Long babyId) {
        if (babyId == null || babyId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 아기 ID입니다.");
        }
    }

    private void validateType(SleepType type) {
        if (type == null) {
            throw new IllegalArgumentException("수면 타입은 필수입니다.");
        }
    }

    private void validateStartTime(LocalDateTime startTime) {
        if (startTime == null) {
            throw new IllegalArgumentException("수면 시작 시간은 필수입니다.");
        }
    }

    private void validateEndTime(LocalDateTime startTime, LocalDateTime endTime) {
        if (endTime.isBefore(startTime)) {
            throw new IllegalArgumentException("종료 시간은 시작 시간보다 이후여야 합니다.");
        }
    }
}
