package com.dutyout.domain.schedule.entity;

/**
 * 활동 타입
 */
public enum ActivityType {
    WAKE_UP,    // 기상
    NAP1,       // 첫 번째 낮잠
    NAP2,       // 두 번째 낮잠
    NAP3,       // 세 번째 낮잠
    NAP4,       // 네 번째 낮잠 (신생아)
    FEEDING,    // 수유/이유식
    BEDTIME,    // 취침
    PLAY,       // 놀이 시간
    BATH        // 목욕
}
