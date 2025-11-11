package com.dutyout.domain.feeding.entity;

/**
 * 수유 유형
 *
 * Domain Driven Design (DDD) - Value Object
 * 수유 방법을 나타내는 열거형
 *
 * - BREAST: 모유 수유
 * - BOTTLE: 분유/젖병 수유
 * - SOLID: 이유식/고형식
 */
public enum FeedingType {
    /**
     * 모유 수유
     */
    BREAST,

    /**
     * 분유/젖병 수유
     */
    BOTTLE,

    /**
     * 이유식/고형식
     */
    SOLID
}
