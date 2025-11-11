package com.dutyout.domain.community.repository;

import com.dutyout.domain.community.entity.CommunityPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 커뮤니티 게시글 리포지토리
 *
 * Clean Architecture - Infrastructure Layer
 * DDD - Repository Pattern
 *
 * Spring Data JPA를 사용하여 커뮤니티 게시글의 데이터베이스 접근을 처리합니다.
 */
@Repository
public interface CommunityPostRepository extends JpaRepository<CommunityPost, Long> {

    /**
     * 모든 게시글 조회 (페이징)
     * 최신순으로 정렬
     *
     * @param pageable 페이징 정보
     * @return 게시글 페이지
     */
    Page<CommunityPost> findAllByOrderByCreatedAtDesc(Pageable pageable);

    /**
     * 특정 사용자의 게시글 조회 (페이징)
     *
     * @param userId 사용자 ID
     * @param pageable 페이징 정보
     * @return 게시글 페이지
     */
    Page<CommunityPost> findByUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    /**
     * 제목으로 게시글 검색 (페이징)
     *
     * @param keyword 검색 키워드
     * @param pageable 페이징 정보
     * @return 게시글 페이지
     */
    Page<CommunityPost> findByTitleContainingOrderByCreatedAtDesc(String keyword, Pageable pageable);

    /**
     * 제목 또는 내용으로 게시글 검색 (페이징)
     *
     * @param titleKeyword 제목 검색 키워드
     * @param contentKeyword 내용 검색 키워드
     * @param pageable 페이징 정보
     * @return 게시글 페이지
     */
    Page<CommunityPost> findByTitleContainingOrContentContainingOrderByCreatedAtDesc(
            String titleKeyword, String contentKeyword, Pageable pageable);

    /**
     * 인기 게시글 조회 (좋아요 수 기준)
     *
     * @param minLikeCount 최소 좋아요 수
     * @param pageable 페이징 정보
     * @return 게시글 페이지
     */
    Page<CommunityPost> findByLikeCountGreaterThanEqualOrderByLikeCountDescCreatedAtDesc(
            Integer minLikeCount, Pageable pageable);

    /**
     * 최신 인기 게시글 조회 (좋아요 수 top N)
     *
     * @param pageable 페이징 정보
     * @return 게시글 리스트
     */
    @Query("SELECT p FROM CommunityPost p ORDER BY p.likeCount DESC, p.createdAt DESC")
    List<CommunityPost> findTopPosts(Pageable pageable);

    /**
     * 특정 사용자의 게시글 수 조회
     *
     * @param userId 사용자 ID
     * @return 게시글 수
     */
    long countByUserId(Long userId);

    /**
     * 전체 게시글 통계
     * 총 게시글 수, 총 좋아요 수, 총 댓글 수
     *
     * @return [총 게시글 수, 총 좋아요 수, 총 댓글 수]
     */
    @Query("SELECT COUNT(p), SUM(p.likeCount), SUM(p.commentCount) FROM CommunityPost p")
    Object[] getCommunityStats();
}
