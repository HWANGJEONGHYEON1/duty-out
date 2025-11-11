package com.dutyout.domain.schedule.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 개월수별 수면 가이드라인 엔티티
 *
 * Clean Architecture - Domain Entity
 * DDD - Value Object (불변 참조 데이터)
 *
 * 아기의 개월 수에 따른 수면 및 수유 권장 사항을 관리하는 도메인 엔티티입니다.
 * 이 데이터는 수면 전문가의 가이드라인을 기반으로 하며, 자동 스케줄 생성에 사용됩니다.
 *
 * 비즈니스 규칙:
 * - 개월 수는 0개월부터 60개월까지 지원
 * - 깨어있는 시간(깨시)은 낮잠 순서에 따라 다름 (아침이 짧고 저녁이 김)
 * - 총 수면 시간 = 밤잠 + 낮잠
 *
 * 데이터 출처:
 * - 수면 교육 전문가 가이드라인
 * - 소아과 권장 사항
 */
@Entity
@Table(name = "age_based_sleep_guidelines", indexes = {
        @Index(name = "idx_age_months", columnList = "ageInMonths")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AgeBasedSleepGuideline extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 개월 수 (0~60개월)
     */
    @Column(nullable = false, unique = true)
    private Integer ageInMonths;

    // ========== 수면 관련 ==========

    /**
     * 깨어있는 시간 - 최소값 (분)
     * 예: 3개월 - 90분
     */
    @Column(nullable = false)
    private Integer wakeWindowMinMinutes;

    /**
     * 깨어있는 시간 - 최대값 (분)
     * 예: 3개월 - 120분
     */
    @Column(nullable = false)
    private Integer wakeWindowMaxMinutes;

    /**
     * 낮잠 횟수
     * 예: 3개월 - 4회, 8개월 - 2회
     */
    @Column(nullable = false)
    private Integer napCount;

    /**
     * 최대 낮잠 총 시간 (분)
     * 예: 3개월 - 240분 (4시간)
     */
    @Column(nullable = false)
    private Integer maxTotalNapMinutes;

    /**
     * 권장 밤잠 시간 (분)
     * 예: 3개월 - 600~720분 (10~12시간)
     */
    @Column(nullable = false)
    private Integer nightSleepMinMinutes;

    @Column(nullable = false)
    private Integer nightSleepMaxMinutes;

    /**
     * 권장 취침 시간 (시간, 24시간 형식)
     * 예: 3개월 - 19시 (저녁 7시)
     */
    @Column(nullable = false)
    private Integer recommendedBedtimeHour;

    /**
     * 권장 취침 시간 (분)
     * 예: 30분 -> 19:30
     */
    @Column(nullable = false)
    private Integer recommendedBedtimeMinute;

    // ========== 깨시 상세 정보 ==========

    /**
     * 첫 번째 낮잠까지 깨시 (분)
     * 아침 기상 후 첫 낮잠까지의 시간
     */
    @Column
    private Integer firstWakeWindowMinutes;

    /**
     * 중간 낮잠 깨시 (분)
     * 두 번째, 세 번째 낮잠 등에 적용
     */
    @Column
    private Integer middleWakeWindowMinutes;

    /**
     * 마지막 낮잠 후 깨시 (분)
     * 마지막 낮잠에서 밤잠까지의 시간 (보통 가장 김)
     */
    @Column
    private Integer lastWakeWindowMinutes;

    // ========== 수유 관련 ==========

    /**
     * 1회 수유량 - 최소값 (ml)
     */
    @Column(nullable = false)
    private Integer feedingAmountMinMl;

    /**
     * 1회 수유량 - 최대값 (ml)
     */
    @Column(nullable = false)
    private Integer feedingAmountMaxMl;

    /**
     * 모유 수유 횟수 - 최소값
     */
    @Column(nullable = false)
    private Integer breastfeedingCountMin;

    /**
     * 모유 수유 횟수 - 최대값
     */
    @Column(nullable = false)
    private Integer breastfeedingCountMax;

    /**
     * 분유 수유 횟수 - 최소값
     */
    @Column(nullable = false)
    private Integer formulaFeedingCountMin;

    /**
     * 분유 수유 횟수 - 최대값
     */
    @Column(nullable = false)
    private Integer formulaFeedingCountMax;

    /**
     * 권장 수유 간격 (분)
     * 예: 3개월 - 150~180분 (2.5~3시간)
     */
    @Column(nullable = false)
    private Integer feedingIntervalMinutes;

    // ========== 기타 ==========

    /**
     * 가이드라인 설명
     * 특이사항이나 주의사항
     */
    @Column(length = 1000)
    private String description;

    @Builder
    private AgeBasedSleepGuideline(
            Integer ageInMonths,
            Integer wakeWindowMinMinutes,
            Integer wakeWindowMaxMinutes,
            Integer napCount,
            Integer maxTotalNapMinutes,
            Integer nightSleepMinMinutes,
            Integer nightSleepMaxMinutes,
            Integer recommendedBedtimeHour,
            Integer recommendedBedtimeMinute,
            Integer firstWakeWindowMinutes,
            Integer middleWakeWindowMinutes,
            Integer lastWakeWindowMinutes,
            Integer feedingAmountMinMl,
            Integer feedingAmountMaxMl,
            Integer breastfeedingCountMin,
            Integer breastfeedingCountMax,
            Integer formulaFeedingCountMin,
            Integer formulaFeedingCountMax,
            Integer feedingIntervalMinutes,
            String description) {

        this.ageInMonths = ageInMonths;
        this.wakeWindowMinMinutes = wakeWindowMinMinutes;
        this.wakeWindowMaxMinutes = wakeWindowMaxMinutes;
        this.napCount = napCount;
        this.maxTotalNapMinutes = maxTotalNapMinutes;
        this.nightSleepMinMinutes = nightSleepMinMinutes;
        this.nightSleepMaxMinutes = nightSleepMaxMinutes;
        this.recommendedBedtimeHour = recommendedBedtimeHour;
        this.recommendedBedtimeMinute = recommendedBedtimeMinute;
        this.firstWakeWindowMinutes = firstWakeWindowMinutes;
        this.middleWakeWindowMinutes = middleWakeWindowMinutes;
        this.lastWakeWindowMinutes = lastWakeWindowMinutes;
        this.feedingAmountMinMl = feedingAmountMinMl;
        this.feedingAmountMaxMl = feedingAmountMaxMl;
        this.breastfeedingCountMin = breastfeedingCountMin;
        this.breastfeedingCountMax = breastfeedingCountMax;
        this.formulaFeedingCountMin = formulaFeedingCountMin;
        this.formulaFeedingCountMax = formulaFeedingCountMax;
        this.feedingIntervalMinutes = feedingIntervalMinutes;
        this.description = description;
    }

    /**
     * 평균 깨시 계산
     */
    public int getAverageWakeWindowMinutes() {
        return (wakeWindowMinMinutes + wakeWindowMaxMinutes) / 2;
    }

    /**
     * 평균 수유량 계산
     */
    public int getAverageFeedingAmountMl() {
        return (feedingAmountMinMl + feedingAmountMaxMl) / 2;
    }

    /**
     * 특정 낮잠 순서의 깨시 계산
     *
     * @param napIndex 낮잠 순서 (0부터 시작)
     * @return 해당 낮잠의 깨시 (분)
     */
    public int getWakeWindowForNap(int napIndex) {
        // 상세 깨시 정보가 있으면 사용
        if (firstWakeWindowMinutes != null && middleWakeWindowMinutes != null && lastWakeWindowMinutes != null) {
            if (napIndex == 0) {
                return firstWakeWindowMinutes;
            } else if (napIndex == napCount - 1) {
                return lastWakeWindowMinutes;
            } else {
                return middleWakeWindowMinutes;
            }
        }

        // 상세 정보가 없으면 평균값 사용
        return getAverageWakeWindowMinutes();
    }
}
