package com.dutyout.common.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

/**
 * 통일된 API 응답 형식
 *
 * @param <T> 응답 데이터 타입
 */
@Getter
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private final boolean success;
    private final T data;
    private final ErrorInfo error;
    private final LocalDateTime timestamp;

    /**
     * 성공 응답 생성
     */
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, data, null, LocalDateTime.now());
    }

    /**
     * 성공 응답 생성 (데이터 없음)
     */
    public static ApiResponse<Void> success() {
        return new ApiResponse<>(true, null, null, LocalDateTime.now());
    }

    /**
     * 에러 응답 생성
     */
    public static <T> ApiResponse<T> error(String code, String message) {
        return new ApiResponse<>(false, null, new ErrorInfo(code, message, null), LocalDateTime.now());
    }

    /**
     * 에러 응답 생성 (상세 정보 포함)
     */
    public static <T> ApiResponse<T> error(String code, String message, Object details) {
        return new ApiResponse<>(false, null, new ErrorInfo(code, message, details), LocalDateTime.now());
    }

    @Getter
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class ErrorInfo {
        private final String code;
        private final String message;
        private final Object details;
    }
}
