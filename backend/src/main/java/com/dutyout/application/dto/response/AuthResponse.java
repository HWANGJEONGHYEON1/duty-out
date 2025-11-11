package com.dutyout.application.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 인증 응답 DTO
 *
 * Clean Architecture - Application Layer
 *
 * 로그인/회원가입 성공 시 JWT 토큰을 반환하는 데이터 전송 객체입니다.
 *
 * 토큰 종류:
 * - accessToken: API 요청 시 사용 (15분 유효)
 * - refreshToken: Access Token 갱신 시 사용 (30일 유효)
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    /**
     * 사용자 ID
     */
    private Long userId;

    /**
     * 사용자 이메일
     */
    private String email;

    /**
     * 사용자 이름
     */
    private String name;

    /**
     * Access Token (API 요청용)
     */
    private String accessToken;

    /**
     * Refresh Token (토큰 갱신용)
     */
    private String refreshToken;

    /**
     * 토큰 타입 (항상 "Bearer")
     */
    @Builder.Default
    private String tokenType = "Bearer";
}
