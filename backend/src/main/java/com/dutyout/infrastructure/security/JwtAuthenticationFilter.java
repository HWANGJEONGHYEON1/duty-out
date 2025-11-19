package com.dutyout.infrastructure.security;

import com.dutyout.domain.user.entity.User;
import com.dutyout.domain.user.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT 인증 필터
 *
 * Clean Architecture - Infrastructure Layer
 *
 * HTTP 요청의 Authorization 헤더에서 JWT 토큰을 추출하고 검증합니다.
 * 유효한 토큰인 경우 Spring Security Context에 인증 정보를 설정합니다.
 *
 * 로컬 테스트:
 * - 더미 토큰(dummy_access_token_for_local_testing)을 감지하면 테스트용 사용자로 인증
 *
 * 동작 순서:
 * 1. Authorization 헤더에서 Bearer 토큰 추출
 * 2. JWT 토큰 유효성 검증 (또는 더미 토큰 감지)
 * 3. 토큰에서 사용자 ID 추출
 * 4. 데이터베이스에서 사용자 조회
 * 5. SecurityContext에 인증 정보 설정
 *
 * OncePerRequestFilter 상속:
 * - 요청당 한 번만 실행되도록 보장
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    /**
     * JWT 토큰을 검증하고 인증 정보를 설정하는 필터
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            // 1. Authorization 헤더에서 JWT 토큰 추출
            String jwt = getJwtFromRequest(request);

            if (StringUtils.hasText(jwt)) {
                // 로컬 테스트용 더미 토큰 감지
                if (jwt.equals("dummy_access_token_for_local_testing")) {
                    log.debug("로컬 테스트 모드: 더미 토큰 감지");
                    setTestAuthentication(request);
                }
                // 2. 토큰이 있고 유효한 경우 (실제 JWT)
                else if (jwtUtil.validateToken(jwt)) {
                    // 3. 토큰에서 사용자 ID 추출
                    Long userId = jwtUtil.getUserIdFromToken(jwt);

                    // 4. 데이터베이스에서 사용자 조회
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

                    setUserAuthentication(user, request);

                    log.debug("JWT 인증 성공 - User ID: {}, Email: {}", userId, user.getEmail());
                }
            }
        } catch (Exception ex) {
            log.error("SecurityContext에 사용자 인증을 설정할 수 없습니다.", ex);
        }

        // 다음 필터로 요청 전달
        filterChain.doFilter(request, response);
    }

    /**
     * 실제 사용자 인증 정보 설정
     */
    private void setUserAuthentication(User user, HttpServletRequest request) {
        // 5. UserDetails 생성
        CustomUserDetails userDetails = new CustomUserDetails(user);

        // 6. Spring Security 인증 객체 생성
        UsernamePasswordAuthenticationToken authentication =
                new UsernamePasswordAuthenticationToken(
                        userDetails,
                        null,
                        userDetails.getAuthorities()
                );

        // 7. 요청 세부 정보 설정
        authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

        // 8. SecurityContext에 인증 정보 설정
        SecurityContextHolder.getContext().setAuthentication(authentication);
    }

    /**
     * 로컬 테스트용 인증 정보 설정
     * (더미 토큰 감지 시 테스트용 사용자 인증)
     */
    private void setTestAuthentication(HttpServletRequest request) {
        // 테스트용 사용자 찾기 또는 생성 (ID: 1)
        User testUser = userRepository.findById(1L)
                .orElseGet(() -> {
                    // 테스트용 사용자가 없으면 임시로 생성
                    log.warn("테스트용 사용자(ID: 1)를 찾을 수 없습니다. 더미 사용자로 진행합니다.");
                    return User.builder()
                            .id(1L)
                            .email("test@test.com")
                            .name("Test User")
                            .build();
                });

        setUserAuthentication(testUser, request);
        log.info("로컬 테스트 모드: 테스트용 사용자로 인증됨 - User ID: 1");
    }

    /**
     * HTTP 요청에서 JWT 토큰 추출
     *
     * Authorization 헤더 형식: "Bearer {token}"
     *
     * @param request HTTP 요청
     * @return JWT 토큰 (Bearer 제거된 순수 토큰)
     */
    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");

        // Bearer 토큰 형식 확인 및 추출
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7); // "Bearer " 제거
        }

        return null;
    }
}
