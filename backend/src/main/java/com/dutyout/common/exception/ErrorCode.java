package com.dutyout.common.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 에러 코드 정의
 */
@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    // Baby 관련
    BABY_NOT_FOUND("BABY_001", "아기 정보를 찾을 수 없습니다."),
    BABY_LIMIT_EXCEEDED("BABY_002", "최대 3명까지만 등록할 수 있습니다."),
    INVALID_BABY_DATA("BABY_003", "유효하지 않은 아기 정보입니다."),

    // Schedule 관련
    SCHEDULE_NOT_FOUND("SCHEDULE_001", "스케줄을 찾을 수 없습니다."),
    INVALID_WAKE_TIME("SCHEDULE_002", "유효하지 않은 기상 시간입니다."),
    TEMPLATE_NOT_FOUND("SCHEDULE_003", "해당 월령의 스케줄 템플릿을 찾을 수 없습니다."),

    // Sleep Record 관련
    SLEEP_RECORD_NOT_FOUND("SLEEP_001", "수면 기록을 찾을 수 없습니다."),
    INVALID_SLEEP_TIME("SLEEP_002", "유효하지 않은 수면 시간입니다."),

    // User/Auth 관련
    USER_NOT_FOUND("USER_001", "사용자를 찾을 수 없습니다."),
    UNAUTHORIZED("AUTH_001", "인증이 필요합니다."),
    FORBIDDEN("AUTH_002", "접근 권한이 없습니다."),
    INVALID_TOKEN("AUTH_003", "유효하지 않은 토큰입니다."),

    // Common
    INVALID_INPUT("COMMON_001", "잘못된 입력값입니다."),
    INTERNAL_SERVER_ERROR("COMMON_002", "서버 오류가 발생했습니다.");

    private final String code;
    private final String message;
}
