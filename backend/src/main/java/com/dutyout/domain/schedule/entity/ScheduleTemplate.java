package com.dutyout.domain.schedule.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * 스케줄 템플릿 엔티티
 *
 * 개월별 표준 스케줄 템플릿
 * - 깨어있는 시간(Wake Window) 정보
 * - 낮잠 횟수 및 시간
 * - 총 권장 수면 시간
 */
@Entity
@Table(name = "schedule_templates", indexes = {
        @Index(name = "idx_age_months", columnList = "ageMonths", unique = true)
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ScheduleTemplate extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 적용 월령
     */
    @Column(nullable = false, unique = true)
    private Integer ageMonths;

    /**
     * 낮잠 횟수
     */
    @Column(nullable = false)
    private Integer napCount;

    /**
     * 권장 총 수면 시간 (시간 단위)
     */
    @Column(nullable = false)
    private Float totalSleepHours;

    /**
     * 깨어있는 시간 (Wake Windows) - 분 단위
     * 첫 번째 깨시, 두 번째 깨시, ... 순서대로 저장
     */
    @ElementCollection
    @CollectionTable(name = "template_wake_windows", joinColumns = @JoinColumn(name = "template_id"))
    @OrderColumn(name = "sequence")
    @Column(name = "minutes")
    private List<Integer> wakeWindowsMinutes = new ArrayList<>();

    /**
     * 낮잠 시간 (분 단위)
     * 첫 번째 낮잠, 두 번째 낮잠, ... 순서대로 저장
     */
    @ElementCollection
    @CollectionTable(name = "template_nap_durations", joinColumns = @JoinColumn(name = "template_id"))
    @OrderColumn(name = "sequence")
    @Column(name = "minutes")
    private List<Integer> napDurationsMinutes = new ArrayList<>();

    @Column(length = 500)
    private String description;

    @Builder
    private ScheduleTemplate(Integer ageMonths, Integer napCount, Float totalSleepHours,
                             List<Integer> wakeWindowsMinutes, List<Integer> napDurationsMinutes,
                             String description) {
        this.ageMonths = ageMonths;
        this.napCount = napCount;
        this.totalSleepHours = totalSleepHours;
        this.wakeWindowsMinutes = wakeWindowsMinutes != null ? wakeWindowsMinutes : new ArrayList<>();
        this.napDurationsMinutes = napDurationsMinutes != null ? napDurationsMinutes : new ArrayList<>();
        this.description = description;
    }

    /**
     * Wake Window 추가
     */
    public void addWakeWindow(Integer minutes) {
        this.wakeWindowsMinutes.add(minutes);
    }

    /**
     * 낮잠 시간 추가
     */
    public void addNapDuration(Integer minutes) {
        this.napDurationsMinutes.add(minutes);
    }
}
