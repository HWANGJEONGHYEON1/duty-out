package com.dutyout.application.dto.request;

import com.dutyout.domain.user.entity.AuthProvider;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 회원가입 요청 DTO
 *
 * Clean Architecture - Application Layer
 *
 * 클라이언트(Flutter)로부터 회원가입 정보를 받아오는 데이터 전송 객체입니다.
 *
 * Validation:
 * - 이메일: 필수, 이메일 형식
 * - 이름: 필수, 1-50자
 * - 제공자: 필수 (KAKAO, GOOGLE, APPLE)
 * - 제공자 ID: 필수
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterRequest {

    @NotBlank(message = "이메일은 필수입니다.")
    @Email(message = "올바른 이메일 형식이 아닙니다.")
    private String email;

    @NotBlank(message = "이름은 필수입니다.")
    @Size(min = 1, max = 50, message = "이름은 1-50자 사이여야 합니다.")
    private String name;

    @NotNull(message = "인증 제공자는 필수입니다.")
    private AuthProvider provider;

    @NotBlank(message = "제공자 ID는 필수입니다.")
    private String providerId;

    private String profileImage;
}
