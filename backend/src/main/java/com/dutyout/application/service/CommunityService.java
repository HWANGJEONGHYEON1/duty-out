package com.dutyout.application.service;

import com.dutyout.application.dto.request.CommentRequest;
import com.dutyout.application.dto.request.CommunityPostRequest;
import com.dutyout.application.dto.response.CommentResponse;
import com.dutyout.application.dto.response.CommunityPostResponse;
import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.community.entity.Comment;
import com.dutyout.domain.community.entity.CommunityPost;
import com.dutyout.domain.community.repository.CommentRepository;
import com.dutyout.domain.community.repository.CommunityPostRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

/**
 * 커뮤니티 서비스
 *
 * Clean Architecture - Application Layer
 * DDD - Application Service
 *
 * 커뮤니티 게시글 및 댓글 관련 비즈니스 로직을 처리합니다.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CommunityService {

    private final CommunityPostRepository communityPostRepository;
    private final CommentRepository commentRepository;
    private final Random random = new Random();

    // ========== 게시글 관련 ==========

    /**
     * 게시글 생성
     */
    @Transactional
    public CommunityPostResponse createPost(Long userId, CommunityPostRequest request) {
        log.info("게시글 생성 - User ID: {}", userId);

        // 익명 작성자명 생성 (예: "익명123")
        String anonymousAuthor = "익명" + (random.nextInt(900) + 100);

        CommunityPost post = CommunityPost.builder()
                .userId(userId)
                .title(request.getTitle())
                .content(request.getContent())
                .anonymousAuthor(anonymousAuthor)
                .build();

        post = communityPostRepository.save(post);
        log.info("게시글 생성 완료 - Post ID: {}", post.getId());

        return CommunityPostResponse.from(post);
    }

    /**
     * 게시글 단건 조회
     */
    public CommunityPostResponse getPost(Long postId) {
        CommunityPost post = communityPostRepository.findById(postId)
                .orElseThrow(() -> new BusinessException(ErrorCode.POST_NOT_FOUND));

        return CommunityPostResponse.from(post);
    }

    /**
     * 게시글 목록 조회 (페이징)
     */
    public Page<CommunityPostResponse> getPosts(Pageable pageable) {
        Page<CommunityPost> posts = communityPostRepository.findAllByOrderByCreatedAtDesc(pageable);
        return posts.map(CommunityPostResponse::from);
    }

    /**
     * 게시글 검색
     */
    public Page<CommunityPostResponse> searchPosts(String keyword, Pageable pageable) {
        Page<CommunityPost> posts = communityPostRepository
                .findByTitleContainingOrContentContainingOrderByCreatedAtDesc(
                        keyword, keyword, pageable);

        return posts.map(CommunityPostResponse::from);
    }

    /**
     * 게시글 수정
     */
    @Transactional
    public CommunityPostResponse updatePost(Long userId, Long postId, CommunityPostRequest request) {
        log.info("게시글 수정 - Post ID: {}", postId);

        CommunityPost post = communityPostRepository.findById(postId)
                .orElseThrow(() -> new BusinessException(ErrorCode.POST_NOT_FOUND));

        // 권한 검증
        if (!post.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED_POST_ACCESS);
        }

        post.update(request.getTitle(), request.getContent());
        log.info("게시글 수정 완료 - Post ID: {}", postId);

        return CommunityPostResponse.from(post);
    }

    /**
     * 게시글 삭제
     */
    @Transactional
    public void deletePost(Long userId, Long postId) {
        log.info("게시글 삭제 - Post ID: {}", postId);

        CommunityPost post = communityPostRepository.findById(postId)
                .orElseThrow(() -> new BusinessException(ErrorCode.POST_NOT_FOUND));

        // 권한 검증
        if (!post.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED_POST_ACCESS);
        }

        // 댓글도 함께 삭제
        commentRepository.deleteByPostId(postId);

        communityPostRepository.delete(post);
        log.info("게시글 삭제 완료 - Post ID: {}", postId);
    }

    /**
     * 게시글 좋아요
     */
    @Transactional
    public CommunityPostResponse likePost(Long postId) {
        log.info("게시글 좋아요 - Post ID: {}", postId);

        CommunityPost post = communityPostRepository.findById(postId)
                .orElseThrow(() -> new BusinessException(ErrorCode.POST_NOT_FOUND));

        post.increaseLikeCount();
        log.info("게시글 좋아요 완료 - Post ID: {}, Like Count: {}", postId, post.getLikeCount());

        return CommunityPostResponse.from(post);
    }

    // ========== 댓글 관련 ==========

    /**
     * 댓글 생성
     */
    @Transactional
    public CommentResponse createComment(Long userId, Long postId, CommentRequest request) {
        log.info("댓글 생성 - Post ID: {}, User ID: {}", postId, userId);

        // 게시글 존재 확인
        CommunityPost post = communityPostRepository.findById(postId)
                .orElseThrow(() -> new BusinessException(ErrorCode.POST_NOT_FOUND));

        // 익명 작성자명 생성
        String anonymousAuthor = "익명" + (random.nextInt(900) + 100);

        Comment comment = Comment.builder()
                .postId(postId)
                .userId(userId)
                .content(request.getContent())
                .anonymousAuthor(anonymousAuthor)
                .build();

        comment = commentRepository.save(comment);

        // 게시글의 댓글 수 증가
        post.increaseCommentCount();

        log.info("댓글 생성 완료 - Comment ID: {}", comment.getId());

        return CommentResponse.from(comment);
    }

    /**
     * 특정 게시글의 댓글 목록 조회
     */
    public List<CommentResponse> getComments(Long postId) {
        List<Comment> comments = commentRepository.findByPostIdOrderByCreatedAtDesc(postId);
        return comments.stream()
                .map(CommentResponse::from)
                .collect(Collectors.toList());
    }

    /**
     * 댓글 수정
     */
    @Transactional
    public CommentResponse updateComment(Long userId, Long commentId, CommentRequest request) {
        log.info("댓글 수정 - Comment ID: {}", commentId);

        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new BusinessException(ErrorCode.COMMENT_NOT_FOUND));

        // 권한 검증
        if (!comment.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED_COMMENT_ACCESS);
        }

        comment.update(request.getContent());
        log.info("댓글 수정 완료 - Comment ID: {}", commentId);

        return CommentResponse.from(comment);
    }

    /**
     * 댓글 삭제
     */
    @Transactional
    public void deleteComment(Long userId, Long commentId) {
        log.info("댓글 삭제 - Comment ID: {}", commentId);

        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new BusinessException(ErrorCode.COMMENT_NOT_FOUND));

        // 권한 검증
        if (!comment.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED_COMMENT_ACCESS);
        }

        // 게시글의 댓글 수 감소
        CommunityPost post = communityPostRepository.findById(comment.getPostId())
                .orElseThrow(() -> new BusinessException(ErrorCode.POST_NOT_FOUND));
        post.decreaseCommentCount();

        commentRepository.delete(comment);
        log.info("댓글 삭제 완료 - Comment ID: {}", commentId);
    }
}
