package com.dutyout.infrastructure.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * Spring Security 설정
 *
 * Clean Architecture - Infrastructure Layer
 *
 * 애플리케이션의 보안 정책을 정의합니다.
 *
 * 주요 설정:
 * - JWT 기반 Stateless 인증
 * - CORS 설정 (Flutter 앱과의 통신)
 * - CSRF 비활성화 (JWT 사용으로 불필요)
 * - API 엔드포인트별 권한 설정
 *
 * URL 패턴별 권한:
 * - /auth/** : 인증 불필요 (회원가입, 로그인)
 * - /api-docs/**, /swagger-ui/** : 인증 불필요 (API 문서)
 * - /community/posts (GET) : 인증 불필요 (게시글 목록 조회)
 * - 그 외 모든 API : 인증 필요
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    /**
     * SecurityFilterChain 설정
     *
     * @param http HttpSecurity
     * @return SecurityFilterChain
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // CSRF 비활성화 (JWT 사용으로 불필요)
                .csrf(AbstractHttpConfigurer::disable)

                // CORS 설정 적용
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                // 세션 정책: Stateless (JWT 사용)
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // URL 패턴별 권한 설정
                .authorizeHttpRequests(auth -> auth
                        // 인증 불필요 (Public)
                        .requestMatchers("/api/v1/auth/**", "/auth/**").permitAll()
                        .requestMatchers("/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        .requestMatchers("/h2-console/**").permitAll() // H2 콘솔 (개발용)
                        .requestMatchers("/actuator/**").permitAll() // Actuator (모니터링)

                        // 커뮤니티 게시글 조회는 인증 불필요 (읽기 전용)
                        .requestMatchers(HttpMethod.GET, "/api/v1/community/posts").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/community/posts/*").permitAll()
                        .requestMatchers(HttpMethod.GET, "/community/posts").permitAll()
                        .requestMatchers(HttpMethod.GET, "/community/posts/*").permitAll()

                        // 아기 프로필 조회/생성은 인증 필요
                        .requestMatchers("/api/v1/babies/**").authenticated()

                        // 그 외 모든 요청은 인증 필요
                        .anyRequest().authenticated()
                )

                // JWT 인증 필터 추가
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)

                // H2 콘솔을 위한 설정 (개발 환경)
                .headers(headers -> headers.frameOptions(frameOptions -> frameOptions.sameOrigin()));

        return http.build();
    }

    /**
     * CORS 설정
     *
     * Flutter 앱에서 백엔드 API 호출을 허용하기 위한 CORS 설정입니다.
     *
     * @return CorsConfigurationSource
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // 허용할 Origin (Flutter 앱)
        configuration.setAllowedOrigins(Arrays.asList(
                "http://localhost:3000",     // Flutter 웹 개발 서버
                "http://localhost:8080",     // 로컬 테스트
                "https://your-app-domain.com" // 프로덕션 도메인
        ));

        // 허용할 HTTP 메서드
        configuration.setAllowedMethods(Arrays.asList(
                HttpMethod.GET.name(),
                HttpMethod.POST.name(),
                HttpMethod.PUT.name(),
                HttpMethod.PATCH.name(),
                HttpMethod.DELETE.name(),
                HttpMethod.OPTIONS.name()
        ));

        // 허용할 헤더
        configuration.setAllowedHeaders(List.of("*"));

        // 자격 증명 허용 (쿠키, Authorization 헤더 등)
        configuration.setAllowCredentials(true);

        // CORS 설정 노출 헤더
        configuration.setExposedHeaders(Arrays.asList(
                "Authorization",
                "Content-Type",
                "X-Total-Count"
        ));

        // Preflight 요청 캐시 시간 (1시간)
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);

        return source;
    }

    /**
     * 비밀번호 인코더 빈 등록
     *
     * BCrypt 알고리즘을 사용하여 비밀번호를 암호화합니다.
     * (현재는 OAuth만 사용하지만 향후 일반 로그인 추가 시 사용)
     *
     * @return PasswordEncoder
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
