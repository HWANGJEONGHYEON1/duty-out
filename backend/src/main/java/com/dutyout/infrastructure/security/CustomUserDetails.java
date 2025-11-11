package com.dutyout.infrastructure.security;

import com.dutyout.domain.user.entity.User;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

/**
 * Spring Security UserDetails 구현체
 *
 * Clean Architecture - Infrastructure Layer
 *
 * Spring Security에서 사용하는 사용자 인증 정보를 제공합니다.
 * User 도메인 엔티티를 Spring Security가 이해할 수 있는 형태로 변환합니다.
 */
@Getter
@RequiredArgsConstructor
public class CustomUserDetails implements UserDetails {

    private final User user;

    /**
     * 사용자 ID 반환
     */
    public Long getId() {
        return user.getId();
    }

    /**
     * 권한 목록 반환
     * USER 또는 ADMIN 역할을 GrantedAuthority로 변환합니다.
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + user.getRole().name())
        );
    }

    /**
     * 비밀번호 반환
     * OAuth 사용자이므로 비밀번호는 null
     */
    @Override
    public String getPassword() {
        return null; // OAuth 사용자이므로 비밀번호 없음
    }

    /**
     * 사용자명 반환
     * 이메일을 사용자명으로 사용합니다.
     */
    @Override
    public String getUsername() {
        return user.getEmail();
    }

    /**
     * 계정 만료 여부
     * 항상 true 반환 (만료되지 않음)
     */
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    /**
     * 계정 잠금 여부
     * 항상 true 반환 (잠기지 않음)
     */
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    /**
     * 자격 증명 만료 여부
     * 항상 true 반환 (만료되지 않음)
     */
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    /**
     * 계정 활성화 여부
     * 항상 true 반환 (활성화됨)
     */
    @Override
    public boolean isEnabled() {
        return true;
    }
}
