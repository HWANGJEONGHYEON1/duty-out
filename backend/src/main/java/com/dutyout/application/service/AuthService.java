package com.dutyout.application.service;

import com.dutyout.application.dto.request.LoginRequest;
import com.dutyout.application.dto.request.RegisterRequest;
import com.dutyout.application.dto.response.AuthResponse;
import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.user.entity.User;
import com.dutyout.domain.user.repository.UserRepository;
import com.dutyout.infrastructure.security.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 인증 서비스
 *
 * Clean Architecture - Application Layer
 * DDD - Application Service
 *
 * 사용자 회원가입, 로그인, 토큰 갱신 등 인증 관련 비즈니스 로직을 처리합니다.
 *
 * 주요 기능:
 * - OAuth 회원가입
 * - OAuth 로그인
 * - Refresh Token을 통한 Access Token 갱신
 *
 * 비즈니스 규칙:
 * - 동일한 provider + providerId 조합은 중복 불가
 * - 로그인 시 사용자가 존재하지 않으면 자동 회원가입
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AuthService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    /**
     * 회원가입
     *
     * OAuth 제공자 정보를 기반으로 신규 사용자를 등록합니다.
     *
     * @param request 회원가입 요청 정보
     * @return JWT 토큰이 포함된 인증 응답
     * @throws BusinessException 이미 존재하는 사용자인 경우
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("회원가입 시도 - Provider: {}, Email: {}", request.getProvider(), request.getEmail());

        // 중복 확인
        userRepository.findByProviderAndProviderId(request.getProvider(), request.getProviderId())
                .ifPresent(user -> {
                    throw new BusinessException(ErrorCode.USER_ALREADY_EXISTS);
                });

        // 사용자 생성
        User user = User.builder()
                .email(request.getEmail())
                .name(request.getName())
                .provider(request.getProvider())
                .providerId(request.getProviderId())
                .profileImage(request.getProfileImage())
                .build();

        user = userRepository.save(user);
        log.info("회원가입 성공 - User ID: {}, Email: {}", user.getId(), user.getEmail());

        // JWT 토큰 생성
        return createAuthResponse(user);
    }

    /**
     * 로그인
     *
     * OAuth 제공자 정보를 기반으로 사용자를 인증합니다.
     * 사용자가 존재하지 않으면 자동으로 회원가입 처리합니다.
     *
     * @param request 로그인 요청 정보
     * @return JWT 토큰이 포함된 인증 응답
     */
    @Transactional
    public AuthResponse login(LoginRequest request) {
        log.info("로그인 시도 - Provider: {}, ProviderId: {}", request.getProvider(), request.getProviderId());

        // 사용자 조회 (없으면 예외 발생)
        User user = userRepository.findByProviderAndProviderId(
                        request.getProvider(),
                        request.getProviderId())
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        log.info("로그인 성공 - User ID: {}, Email: {}", user.getId(), user.getEmail());

        // JWT 토큰 생성
        return createAuthResponse(user);
    }

    /**
     * Refresh Token으로 Access Token 갱신
     *
     * @param refreshToken Refresh Token
     * @return 새로운 JWT 토큰이 포함된 인증 응답
     * @throws BusinessException 유효하지 않은 토큰인 경우
     */
    @Transactional
    public AuthResponse refreshAccessToken(String refreshToken) {
        log.info("Access Token 갱신 시도");

        // Refresh Token 검증
        if (!jwtUtil.validateToken(refreshToken)) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN);
        }

        // 사용자 ID 추출
        Long userId = jwtUtil.getUserIdFromToken(refreshToken);

        // 사용자 조회
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        log.info("Access Token 갱신 성공 - User ID: {}", userId);

        // 새로운 JWT 토큰 생성
        return createAuthResponse(user);
    }

    /**
     * 사용자 정보와 함께 JWT 토큰 생성
     *
     * @param user 사용자 엔티티
     * @return 인증 응답 DTO
     */
    private AuthResponse createAuthResponse(User user) {
        String accessToken = jwtUtil.generateAccessToken(user.getId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .userId(user.getId())
                .email(user.getEmail())
                .name(user.getName())
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }
}
