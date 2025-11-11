package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.LoginRequest;
import com.dutyout.application.dto.request.RegisterRequest;
import com.dutyout.domain.user.entity.AuthProvider;
import com.dutyout.domain.user.entity.User;
import com.dutyout.domain.user.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * AuthController H2 통합 테스트
 *
 * Testing Strategy:
 * - @SpringBootTest: 전체 애플리케이션 컨텍스트 로드
 * - @AutoConfigureMockMvc: MockMvc 자동 설정
 * - @ActiveProfiles("test"): H2 DB 사용
 * - @Transactional: 테스트 후 자동 롤백
 *
 * 테스트 범위:
 * - Controller -> Service -> Repository -> H2 DB
 * - 실제 HTTP 요청/응답 검증
 * - JSON 직렬화/역직렬화 검증
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
@DisplayName("AuthController H2 통합 테스트")
class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        // 테스트 전 데이터 초기화
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("회원가입 API 성공")
    void register_Success() throws Exception {
        // given
        RegisterRequest request = RegisterRequest.builder()
                .email("test@example.com")
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();

        // when & then
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.email").value("test@example.com"))
                .andExpect(jsonPath("$.data.accessToken").exists())
                .andExpect(jsonPath("$.data.refreshToken").exists());
    }

    @Test
    @DisplayName("회원가입 API 실패 - 중복 사용자")
    void register_Fail_DuplicateUser() throws Exception {
        // given: 기존 사용자 등록
        User existingUser = User.builder()
                .email("test@example.com")
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();
        userRepository.save(existingUser);

        RegisterRequest request = RegisterRequest.builder()
                .email("test@example.com")
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();

        // when & then
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.code").value("USER_002"));
    }

    @Test
    @DisplayName("로그인 API 성공")
    void login_Success() throws Exception {
        // given: 기존 사용자 등록
        User user = User.builder()
                .email("test@example.com")
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();
        userRepository.save(user);

        LoginRequest request = LoginRequest.builder()
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();

        // when & then
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.email").value("test@example.com"))
                .andExpect(jsonPath("$.data.accessToken").exists());
    }

    @Test
    @DisplayName("로그인 API 실패 - 사용자 없음")
    void login_Fail_UserNotFound() throws Exception {
        // given
        LoginRequest request = LoginRequest.builder()
                .provider(AuthProvider.KAKAO)
                .providerId("nonexistent")
                .build();

        // when & then
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.code").value("USER_001"));
    }

    @Test
    @DisplayName("회원가입 API 실패 - Validation 오류")
    void register_Fail_ValidationError() throws Exception {
        // given: 이메일 없는 요청
        RegisterRequest request = RegisterRequest.builder()
                .name("테스트")
                .provider(AuthProvider.KAKAO)
                .providerId("kakao123")
                .build();

        // when & then
        mockMvc.perform(post("/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }
}
