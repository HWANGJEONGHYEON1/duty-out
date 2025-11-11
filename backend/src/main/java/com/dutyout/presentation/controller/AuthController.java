package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.LoginRequest;
import com.dutyout.application.dto.request.RegisterRequest;
import com.dutyout.application.dto.response.AuthResponse;
import com.dutyout.application.service.AuthService;
import com.dutyout.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 인증 컨트롤러
 *
 * Clean Architecture - Presentation Layer (Interface Adapter)
 *
 * 사용자 인증 관련 HTTP 엔드포인트를 제공합니다.
 *
 * 엔드포인트:
 * - POST /auth/register : 회원가입
 * - POST /auth/login : 로그인
 * - POST /auth/refresh : Access Token 갱신
 */
@Tag(name = "Authentication", description = "인증 API")
@Slf4j
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * 회원가입
     *
     * OAuth 제공자 정보를 기반으로 신규 사용자를 등록합니다.
     *
     * @param request 회원가입 요청
     * @return JWT 토큰이 포함된 인증 응답
     */
    @Operation(summary = "회원가입", description = "OAuth 제공자 정보로 회원가입을 진행합니다.")
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        log.info("POST /auth/register - Provider: {}, Email: {}", request.getProvider(), request.getEmail());

        AuthResponse response = authService.register(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * 로그인
     *
     * OAuth 제공자 정보를 기반으로 사용자를 인증합니다.
     *
     * @param request 로그인 요청
     * @return JWT 토큰이 포함된 인증 응답
     */
    @Operation(summary = "로그인", description = "OAuth 제공자 정보로 로그인을 진행합니다.")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        log.info("POST /auth/login - Provider: {}", request.getProvider());

        AuthResponse response = authService.login(request);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * Access Token 갱신
     *
     * Refresh Token을 사용하여 새로운 Access Token을 발급받습니다.
     *
     * @param refreshToken Refresh Token (Authorization 헤더)
     * @return 새로운 JWT 토큰이 포함된 인증 응답
     */
    @Operation(summary = "토큰 갱신", description = "Refresh Token으로 새로운 Access Token을 발급받습니다.")
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(
            @RequestHeader("Authorization") String refreshToken) {
        log.info("POST /auth/refresh");

        // Bearer 토큰 형식에서 토큰만 추출
        String token = refreshToken.startsWith("Bearer ") ? refreshToken.substring(7) : refreshToken;

        AuthResponse response = authService.refreshAccessToken(token);

        return ResponseEntity.ok(ApiResponse.success(response));
    }
}
