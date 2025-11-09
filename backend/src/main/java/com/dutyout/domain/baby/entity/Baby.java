package com.dutyout.domain.baby.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * 아기 프로필 엔티티
 *
 * 핵심 기능:
 * - 실제 월령 계산
 * - 교정 월령 계산 (조산아의 경우)
 */
@Entity
@Table(name = "babies", indexes = {
        @Index(name = "idx_user_id", columnList = "userId")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Baby extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false)
    private LocalDate birthDate;

    /**
     * 출생 주수 (교정월령 계산용)
     * null이거나 37주 이상이면 교정월령 계산 안 함
     */
    @Column
    private Integer gestationalWeeks;

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Gender gender;

    @Column(length = 500)
    private String profileImage;

    @Builder
    private Baby(Long userId, String name, LocalDate birthDate,
                 Integer gestationalWeeks, Gender gender, String profileImage) {
        validateUserId(userId);
        validateName(name);
        validateBirthDate(birthDate);
        validateGestationalWeeks(gestationalWeeks);

        this.userId = userId;
        this.name = name;
        this.birthDate = birthDate;
        this.gestationalWeeks = gestationalWeeks;
        this.gender = gender;
        this.profileImage = profileImage;
    }

    /**
     * 실제 개월수 계산
     */
    public int calculateAgeInMonths() {
        return (int) ChronoUnit.MONTHS.between(birthDate, LocalDate.now());
    }

    /**
     * 교정월령 계산 (조산아용)
     *
     * 출생 주수가 37주 미만인 경우 교정월령을 계산합니다.
     * 예: 32주에 태어난 아기는 8주(2개월) 일찍 태어났으므로 교정이 필요
     */
    public int calculateCorrectedAgeInMonths() {
        // 만삭(37주 이상) 또는 출생주수 미입력 시 실제 월령 반환
        if (gestationalWeeks == null || gestationalWeeks >= 37) {
            return calculateAgeInMonths();
        }

        // 조산 주수 계산 (40주 기준)
        int weeksPremature = 40 - gestationalWeeks;

        // 교정 생일 = 실제 생일 + 조산 주수
        LocalDate correctedBirthDate = birthDate.plusWeeks(weeksPremature);

        // 교정 월령 계산
        long correctedMonths = ChronoUnit.MONTHS.between(correctedBirthDate, LocalDate.now());

        // 음수가 나올 수 있으므로 0 이상으로 제한
        return (int) Math.max(0, correctedMonths);
    }

    /**
     * 프로필 업데이트
     */
    public void updateProfile(String name, String profileImage) {
        if (name != null && !name.trim().isEmpty()) {
            validateName(name);
            this.name = name;
        }
        if (profileImage != null) {
            this.profileImage = profileImage;
        }
    }

    // Validation 메서드들
    private void validateUserId(Long userId) {
        if (userId == null || userId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 사용자 ID입니다.");
        }
    }

    private void validateName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("이름은 필수입니다.");
        }
        if (name.length() > 50) {
            throw new IllegalArgumentException("이름은 50자를 초과할 수 없습니다.");
        }
    }

    private void validateBirthDate(LocalDate birthDate) {
        if (birthDate == null) {
            throw new IllegalArgumentException("생년월일은 필수입니다.");
        }
        if (birthDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("생년월일은 미래일 수 없습니다.");
        }
    }

    private void validateGestationalWeeks(Integer weeks) {
        if (weeks != null && (weeks < 22 || weeks > 42)) {
            throw new IllegalArgumentException("출생 주수는 22주에서 42주 사이여야 합니다.");
        }
    }
}
