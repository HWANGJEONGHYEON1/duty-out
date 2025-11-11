package com.dutyout.application.service;

import com.dutyout.application.dto.request.LoginRequest;
import com.dutyout.application.dto.request.RegisterRequest;
import com.dutyout.application.dto.response.AuthResponse;
import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.user.entity.AuthProvider;
import com.dutyout.domain.user.entity.User;
import com.dutyout.domain.user.repository.UserRepository;
import com.dutyout.infrastructure.security.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;

/**
 * AuthService 단위 테스트
 *
 * Testing Strategy:
 * - Mockito를 사용한 의존성 격리
 * - BDD 스타일 테스트 (given-when-then)
 * - 정상 케이스 및 예외 케이스 검증
 *
 * 테스트 대상:
 * - 회원가입 (성공/실패)
 * - 로그인 (성공/실패)
 * - 토큰 갱신 (성공/실패)
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("AuthService 단위 테스트")
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtUtil jwtUtil;

    @InjectMocks
    private AuthService authService;

    private RegisterRequest registerRequest;
    private LoginRequest loginRequest;
    private User user;

    @BeforeEach
    void setUp() {
        // 테스트 데이터 준비
        registerRequest = RegisterRequest.builder()
                .email("test@example.com")
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();

        loginRequest = LoginRequest.builder()
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();

        user = User.builder()
                .email("test@example.com")
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();
    }

    @Test
    @DisplayName("회원가입 성공")
    void register_Success() {
        // given
        given(userRepository.findByProviderAndProviderId(any(), any()))
                .willReturn(Optional.empty());
        given(userRepository.save(any(User.class))).willReturn(user);
        given(jwtUtil.generateAccessToken(any())).willReturn("access-token");
        given(jwtUtil.generateRefreshToken(any())).willReturn("refresh-token");

        // when
        AuthResponse response = authService.register(registerRequest);

        // then
        assertThat(response).isNotNull();
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getAccessToken()).isEqualTo("access-token");
        assertThat(response.getRefreshToken()).isEqualTo("refresh-token");

        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    @DisplayName("회원가입 실패 - 이미 존재하는 사용자")
    void register_Fail_UserAlreadyExists() {
        // given
        given(userRepository.findByProviderAndProviderId(any(), any()))
                .willReturn(Optional.of(user));

        // when & then
        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.USER_ALREADY_EXISTS);

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("로그인 성공")
    void login_Success() {
        // given
        given(userRepository.findByProviderAndProviderId(any(), any()))
                .willReturn(Optional.of(user));
        given(jwtUtil.generateAccessToken(any())).willReturn("access-token");
        given(jwtUtil.generateRefreshToken(any())).willReturn("refresh-token");

        // when
        AuthResponse response = authService.login(loginRequest);

        // then
        assertThat(response).isNotNull();
        assertThat(response.getEmail()).isEqualTo("test@example.com");
        assertThat(response.getAccessToken()).isEqualTo("access-token");
    }

    @Test
    @DisplayName("로그인 실패 - 사용자 없음")
    void login_Fail_UserNotFound() {
        // given
        given(userRepository.findByProviderAndProviderId(any(), any()))
                .willReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> authService.login(loginRequest))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.USER_NOT_FOUND);
    }

    @Test
    @DisplayName("토큰 갱신 성공")
    void refreshAccessToken_Success() {
        // given
        String refreshToken = "valid-refresh-token";
        given(jwtUtil.validateToken(refreshToken)).willReturn(true);
        given(jwtUtil.getUserIdFromToken(refreshToken)).willReturn(1L);
        given(userRepository.findById(1L)).willReturn(Optional.of(user));
        given(jwtUtil.generateAccessToken(any())).willReturn("new-access-token");
        given(jwtUtil.generateRefreshToken(any())).willReturn("new-refresh-token");

        // when
        AuthResponse response = authService.refreshAccessToken(refreshToken);

        // then
        assertThat(response).isNotNull();
        assertThat(response.getAccessToken()).isEqualTo("new-access-token");
    }

    @Test
    @DisplayName("토큰 갱신 실패 - 유효하지 않은 토큰")
    void refreshAccessToken_Fail_InvalidToken() {
        // given
        String refreshToken = "invalid-refresh-token";
        given(jwtUtil.validateToken(refreshToken)).willReturn(false);

        // when & then
        assertThatThrownBy(() -> authService.refreshAccessToken(refreshToken))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.INVALID_TOKEN);
    }
}
