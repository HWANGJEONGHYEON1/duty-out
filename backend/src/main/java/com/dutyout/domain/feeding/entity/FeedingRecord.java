package com.dutyout.domain.feeding.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 수유 기록 엔티티
 *
 * Clean Architecture - Domain Entity
 * DDD - Aggregate Root
 *
 * 아기의 수유 기록을 관리하는 도메인 엔티티입니다.
 *
 * 비즈니스 규칙:
 * - 수유 시간은 미래일 수 없음
 * - 수유량은 0보다 커야 함 (ml 단위)
 * - 메모는 선택사항
 *
 * 데이터베이스 인덱스:
 * - baby_id: 특정 아기의 수유 기록 조회 시 성능 향상
 * - feeding_time: 시간대별 수유 기록 조회 시 성능 향상
 */
@Entity
@Table(name = "feeding_records", indexes = {
        @Index(name = "idx_baby_id", columnList = "babyId"),
        @Index(name = "idx_feeding_time", columnList = "feedingTime")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class FeedingRecord extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 아기 ID (Foreign Key)
     * Baby 엔티티와의 관계를 나타냅니다.
     */
    @Column(nullable = false)
    private Long babyId;

    /**
     * 수유 시간
     * 실제 수유가 이루어진 시간을 기록합니다.
     */
    @Column(nullable = false)
    private LocalDateTime feedingTime;

    /**
     * 수유 유형 (모유/분유/이유식)
     */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private FeedingType type;

    /**
     * 수유량 (ml)
     * null인 경우 모유 수유 등 양을 측정하지 않은 경우
     */
    @Column
    private Integer amountMl;

    /**
     * 메모
     * 추가 기록사항 (예: "잘 먹음", "토함" 등)
     */
    @Column(length = 500)
    private String note;

    /**
     * 빌더 패턴을 통한 생성
     * 생성 시 비즈니스 규칙 검증을 수행합니다.
     */
    @Builder
    private FeedingRecord(Long babyId, LocalDateTime feedingTime, FeedingType type,
                          Integer amountMl, String note) {
        validateBabyId(babyId);
        validateFeedingTime(feedingTime);
        validateType(type);
        validateAmountMl(amountMl);

        this.babyId = babyId;
        this.feedingTime = feedingTime;
        this.type = type;
        this.amountMl = amountMl;
        this.note = note;
    }

    /**
     * 수유 기록 수정
     *
     * @param feedingTime 수정할 수유 시간 (null이면 변경하지 않음)
     * @param type 수정할 수유 유형 (null이면 변경하지 않음)
     * @param amountMl 수정할 수유량 (null이면 변경하지 않음)
     * @param note 수정할 메모 (null이면 변경하지 않음)
     */
    public void update(LocalDateTime feedingTime, FeedingType type,
                      Integer amountMl, String note) {
        if (feedingTime != null) {
            validateFeedingTime(feedingTime);
            this.feedingTime = feedingTime;
        }
        if (type != null) {
            this.type = type;
        }
        if (amountMl != null) {
            validateAmountMl(amountMl);
            this.amountMl = amountMl;
        }
        if (note != null) {
            this.note = note;
        }
    }

    // ========== Validation Methods (비즈니스 규칙 검증) ==========

    private void validateBabyId(Long babyId) {
        if (babyId == null || babyId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 아기 ID입니다.");
        }
    }

    private void validateFeedingTime(LocalDateTime feedingTime) {
        if (feedingTime == null) {
            throw new IllegalArgumentException("수유 시간은 필수입니다.");
        }
        if (feedingTime.isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException("수유 시간은 미래일 수 없습니다.");
        }
    }

    private void validateType(FeedingType type) {
        if (type == null) {
            throw new IllegalArgumentException("수유 유형은 필수입니다.");
        }
    }

    private void validateAmountMl(Integer amountMl) {
        if (amountMl != null && amountMl <= 0) {
            throw new IllegalArgumentException("수유량은 0보다 커야 합니다.");
        }
    }
}
