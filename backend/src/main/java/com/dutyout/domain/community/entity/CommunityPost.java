package com.dutyout.domain.community.entity;

import com.dutyout.common.entity.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 커뮤니티 게시글 엔티티
 *
 * Clean Architecture - Domain Entity
 * DDD - Aggregate Root
 *
 * 익명 커뮤니티 게시판의 게시글을 관리하는 도메인 엔티티입니다.
 * Blind 앱과 유사한 익명 게시판 기능을 제공합니다.
 *
 * 비즈니스 규칙:
 * - 제목은 필수이며 100자 이하
 * - 내용은 필수이며 5000자 이하
 * - 작성자는 익명으로 표시 (예: "익명123")
 * - 좋아요 수와 댓글 수는 0 이상
 *
 * 데이터베이스 인덱스:
 * - user_id: 특정 사용자의 게시글 조회 시 성능 향상
 * - created_at: 최신순 정렬 시 성능 향상
 */
@Entity
@Table(name = "community_posts", indexes = {
        @Index(name = "idx_user_id", columnList = "userId"),
        @Index(name = "idx_created_at", columnList = "createdAt")
})
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class CommunityPost extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * 작성자 ID (Foreign Key)
     * User 엔티티와의 관계를 나타냅니다.
     * 익명 게시판이지만 관리 목적으로 실제 사용자 ID를 저장합니다.
     */
    @Column(nullable = false)
    private Long userId;

    /**
     * 게시글 제목
     */
    @Column(nullable = false, length = 100)
    private String title;

    /**
     * 게시글 내용
     */
    @Column(nullable = false, length = 5000)
    private String content;

    /**
     * 익명 작성자 표시명
     * 예: "익명123", "익명456"
     * 게시글마다 랜덤하게 생성되어 익명성을 보장합니다.
     */
    @Column(nullable = false, length = 50)
    private String anonymousAuthor;

    /**
     * 좋아요 수
     * 기본값: 0
     */
    @Column(nullable = false)
    private Integer likeCount = 0;

    /**
     * 댓글 수
     * 기본값: 0
     * 댓글 추가/삭제 시 업데이트됩니다.
     */
    @Column(nullable = false)
    private Integer commentCount = 0;

    /**
     * 빌더 패턴을 통한 생성
     * 생성 시 비즈니스 규칙 검증을 수행합니다.
     */
    @Builder
    private CommunityPost(Long userId, String title, String content, String anonymousAuthor) {
        validateUserId(userId);
        validateTitle(title);
        validateContent(content);
        validateAnonymousAuthor(anonymousAuthor);

        this.userId = userId;
        this.title = title;
        this.content = content;
        this.anonymousAuthor = anonymousAuthor;
        this.likeCount = 0;
        this.commentCount = 0;
    }

    /**
     * 게시글 수정
     * 제목과 내용만 수정 가능합니다.
     *
     * @param title 수정할 제목
     * @param content 수정할 내용
     */
    public void update(String title, String content) {
        if (title != null && !title.trim().isEmpty()) {
            validateTitle(title);
            this.title = title;
        }
        if (content != null && !content.trim().isEmpty()) {
            validateContent(content);
            this.content = content;
        }
    }

    /**
     * 좋아요 증가
     */
    public void increaseLikeCount() {
        this.likeCount++;
    }

    /**
     * 좋아요 감소
     * 0 미만으로 내려가지 않도록 방어 로직 추가
     */
    public void decreaseLikeCount() {
        if (this.likeCount > 0) {
            this.likeCount--;
        }
    }

    /**
     * 댓글 수 증가
     * 새 댓글이 추가될 때 호출됩니다.
     */
    public void increaseCommentCount() {
        this.commentCount++;
    }

    /**
     * 댓글 수 감소
     * 댓글이 삭제될 때 호출됩니다.
     * 0 미만으로 내려가지 않도록 방어 로직 추가
     */
    public void decreaseCommentCount() {
        if (this.commentCount > 0) {
            this.commentCount--;
        }
    }

    // ========== Validation Methods (비즈니스 규칙 검증) ==========

    private void validateUserId(Long userId) {
        if (userId == null || userId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 사용자 ID입니다.");
        }
    }

    private void validateTitle(String title) {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("제목은 필수입니다.");
        }
        if (title.length() > 100) {
            throw new IllegalArgumentException("제목은 100자를 초과할 수 없습니다.");
        }
    }

    private void validateContent(String content) {
        if (content == null || content.trim().isEmpty()) {
            throw new IllegalArgumentException("내용은 필수입니다.");
        }
        if (content.length() > 5000) {
            throw new IllegalArgumentException("내용은 5000자를 초과할 수 없습니다.");
        }
    }

    private void validateAnonymousAuthor(String anonymousAuthor) {
        if (anonymousAuthor == null || anonymousAuthor.trim().isEmpty()) {
            throw new IllegalArgumentException("익명 작성자명은 필수입니다.");
        }
    }
}
