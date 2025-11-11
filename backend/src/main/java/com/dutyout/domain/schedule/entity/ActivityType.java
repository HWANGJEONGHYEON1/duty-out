package com.dutyout.domain.schedule.entity;

/**
 * 활동 타입
 *
 * DDD - Value Object
 *
 * 하루 일과의 활동 종류를 정의합니다.
 */
public enum ActivityType {
    WAKE_UP("기상"),
    NAP("낮잠"),
    NAP1("낮잠 1"),
    NAP2("낮잠 2"),
    NAP3("낮잠 3"),
    NAP4("낮잠 4"),
    FEEDING("수유"),
    BEDTIME("취침"),
    PLAY("놀이"),
    BATH("목욕"),
    OTHER("기타");

    private final String koreanName;

    ActivityType(String koreanName) {
        this.koreanName = koreanName;
    }

    public String getKoreanName() {
        return koreanName;
    }
}
