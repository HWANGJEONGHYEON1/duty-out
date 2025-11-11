package com.dutyout.domain.community.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 댓글 엔티티
 *
 * Clean Architecture - Domain Entity
 * DDD - Entity (Aggregate Root인 CommunityPost에 속함)
 *
 * 커뮤니티 게시글의 댓글을 관리하는 도메인 엔티티입니다.
 *
 * 비즈니스 규칙:
 * - 내용은 필수이며 1000자 이하
 * - 익명 작성자명 필수
 * - 게시글 ID는 유효해야 함
 *
 * 데이터베이스 인덱스:
 * - post_id: 특정 게시글의 댓글 조회 시 성능 향상
 * - user_id: 특정 사용자의 댓글 조회 시 성능 향상
 */
@Entity
@Table(name = "comments", indexes = {
        @Index(name = "idx_post_id", columnList = "postId"),
        @Index(name = "idx_user_id", columnList = "userId")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Comment extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 게시글 ID (Foreign Key)
     * CommunityPost 엔티티와의 관계를 나타냅니다.
     */
    @Column(nullable = false)
    private Long postId;

    /**
     * 작성자 ID (Foreign Key)
     * User 엔티티와의 관계를 나타냅니다.
     * 익명이지만 관리 목적으로 실제 사용자 ID를 저장합니다.
     */
    @Column(nullable = false)
    private Long userId;

    /**
     * 댓글 내용
     */
    @Column(nullable = false, length = 1000)
    private String content;

    /**
     * 익명 작성자 표시명
     * 예: "익명123", "익명456"
     * 댓글마다 랜덤하게 생성되어 익명성을 보장합니다.
     */
    @Column(nullable = false, length = 50)
    private String anonymousAuthor;

    /**
     * 빌더 패턴을 통한 생성
     * 생성 시 비즈니스 규칙 검증을 수행합니다.
     */
    @Builder
    private Comment(Long postId, Long userId, String content, String anonymousAuthor) {
        validatePostId(postId);
        validateUserId(userId);
        validateContent(content);
        validateAnonymousAuthor(anonymousAuthor);

        this.postId = postId;
        this.userId = userId;
        this.content = content;
        this.anonymousAuthor = anonymousAuthor;
    }

    /**
     * 댓글 수정
     * 내용만 수정 가능합니다.
     *
     * @param content 수정할 내용
     */
    public void update(String content) {
        if (content != null && !content.trim().isEmpty()) {
            validateContent(content);
            this.content = content;
        }
    }

    // ========== Validation Methods (비즈니스 규칙 검증) ==========

    private void validatePostId(Long postId) {
        if (postId == null || postId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 게시글 ID입니다.");
        }
    }

    private void validateUserId(Long userId) {
        if (userId == null || userId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 사용자 ID입니다.");
        }
    }

    private void validateContent(String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("내용은 필수입니다.");
        }
        if (content.length() > 1000) {
            throw new IllegalArgumentException("내용은 1000자를 초과할 수 없습니다.");
        }
    }

    private void validateAnonymousAuthor(String anonymousAuthor) {
        if (anonymousAuthor == null || anonymousAuthor.trim().isEmpty()) {
            throw new IllegalArgumentException("익명 작성자명은 필수입니다.");
        }
    }
}
