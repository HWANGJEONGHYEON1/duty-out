package com.dutyout.domain.user.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 사용자 엔티티
 */
@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(nullable = false, length = 50)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private AuthProvider provider;

    @Column(nullable = false, unique = true, length = 100)
    private String providerId;

    @Column(length = 500)
    private String profileImage;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private UserRole role = UserRole.USER;

    @Builder
    private User(String email, String name, AuthProvider provider, String providerId, String profileImage) {
        this.email = email;
        this.name = name;
        this.provider = provider;
        this.providerId = providerId;
        this.profileImage = profileImage;
        this.role = UserRole.USER;
    }

    public void updateProfile(String name, String profileImage) {
        if (name != null && !name.trim().isEmpty()) {
            this.name = name;
        }
        if (profileImage != null) {
            this.profileImage = profileImage;
        }
    }
}
