package com.dutyout.application.dto.request;

import com.dutyout.domain.user.entity.AuthProvider;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 로그인 요청 DTO
 *
 * Clean Architecture - Application Layer
 *
 * OAuth 로그인 시 제공자 정보를 받아오는 데이터 전송 객체입니다.
 *
 * 동작 방식:
 * 1. Flutter 앱에서 OAuth 인증 완료
 * 2. 제공자(KAKAO/GOOGLE)와 제공자 ID를 백엔드로 전송
 * 3. 백엔드에서 사용자 조회 및 JWT 토큰 발급
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {

    @NotNull(message = "인증 제공자는 필수입니다.")
    private AuthProvider provider;

    @NotBlank(message = "제공자 ID는 필수입니다.")
    private String providerId;
}
