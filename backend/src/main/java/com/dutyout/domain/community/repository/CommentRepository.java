package com.dutyout.domain.community.repository;

import com.dutyout.domain.community.entity.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 댓글 리포지토리
 *
 * Clean Architecture - Infrastructure Layer
 * DDD - Repository Pattern
 *
 * Spring Data JPA를 사용하여 댓글의 데이터베이스 접근을 처리합니다.
 */
@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    /**
     * 특정 게시글의 모든 댓글 조회
     * 최신순으로 정렬
     *
     * @param postId 게시글 ID
     * @return 댓글 리스트
     */
    List<Comment> findByPostIdOrderByCreatedAtDesc(Long postId);

    /**
     * 특정 게시글의 댓글 조회 (페이징)
     *
     * @param postId 게시글 ID
     * @param pageable 페이징 정보
     * @return 댓글 페이지
     */
    Page<Comment> findByPostIdOrderByCreatedAtDesc(Long postId, Pageable pageable);

    /**
     * 특정 사용자의 댓글 조회
     *
     * @param userId 사용자 ID
     * @return 댓글 리스트
     */
    List<Comment> findByUserIdOrderByCreatedAtDesc(Long userId);

    /**
     * 특정 게시글의 댓글 수 조회
     *
     * @param postId 게시글 ID
     * @return 댓글 수
     */
    long countByPostId(Long postId);

    /**
     * 특정 사용자의 댓글 수 조회
     *
     * @param userId 사용자 ID
     * @return 댓글 수
     */
    long countByUserId(Long userId);

    /**
     * 특정 게시글의 댓글 일괄 삭제
     * 게시글 삭제 시 사용
     *
     * @param postId 게시글 ID
     */
    void deleteByPostId(Long postId);
}
