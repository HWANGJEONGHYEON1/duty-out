package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.CommentRequest;
import com.dutyout.application.dto.request.CommunityPostRequest;
import com.dutyout.application.dto.response.CommentResponse;
import com.dutyout.application.dto.response.CommunityPostResponse;
import com.dutyout.application.service.CommunityService;
import com.dutyout.common.response.ApiResponse;
import com.dutyout.infrastructure.security.CustomUserDetails;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 커뮤니티 컨트롤러
 *
 * Clean Architecture - Presentation Layer
 *
 * 커뮤니티 게시글 및 댓글 관련 HTTP 엔드포인트를 제공합니다.
 */
@Tag(name = "Community", description = "커뮤니티 API")
@Slf4j
@RestController
@RequestMapping("/community")
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityService communityService;

    // ========== 게시글 관련 ==========

    /**
     * 게시글 생성
     */
    @Operation(summary = "게시글 생성", description = "새로운 게시글을 생성합니다.")
    @PostMapping("/posts")
    public ResponseEntity<ApiResponse<CommunityPostResponse>> createPost(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @Valid @RequestBody CommunityPostRequest request) {
        log.info("POST /community/posts - User ID: {}", userDetails.getId());

        CommunityPostResponse response = communityService.createPost(userDetails.getId(), request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * 게시글 단건 조회
     */
    @Operation(summary = "게시글 조회", description = "특정 게시글을 조회합니다.")
    @GetMapping("/posts/{postId}")
    public ResponseEntity<ApiResponse<CommunityPostResponse>> getPost(@PathVariable Long postId) {
        log.info("GET /community/posts/{}", postId);

        CommunityPostResponse response = communityService.getPost(postId);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 게시글 목록 조회 (페이징)
     */
    @Operation(summary = "게시글 목록 조회", description = "게시글 목록을 페이징하여 조회합니다.")
    @GetMapping("/posts")
    public ResponseEntity<ApiResponse<Page<CommunityPostResponse>>> getPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String search) {
        log.info("GET /community/posts - page: {}, size: {}, search: {}", page, size, search);

        Pageable pageable = PageRequest.of(page, size);
        Page<CommunityPostResponse> response;

        if (search != null && !search.trim().isEmpty()) {
            response = communityService.searchPosts(search, pageable);
        } else {
            response = communityService.getPosts(pageable);
        }

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 게시글 수정
     */
    @Operation(summary = "게시글 수정", description = "게시글을 수정합니다.")
    @PutMapping("/posts/{postId}")
    public ResponseEntity<ApiResponse<CommunityPostResponse>> updatePost(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long postId,
            @Valid @RequestBody CommunityPostRequest request) {
        log.info("PUT /community/posts/{} - User ID: {}", postId, userDetails.getId());

        CommunityPostResponse response = communityService.updatePost(userDetails.getId(), postId, request);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 게시글 삭제
     */
    @Operation(summary = "게시글 삭제", description = "게시글을 삭제합니다.")
    @DeleteMapping("/posts/{postId}")
    public ResponseEntity<ApiResponse<Void>> deletePost(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long postId) {
        log.info("DELETE /community/posts/{} - User ID: {}", postId, userDetails.getId());

        communityService.deletePost(userDetails.getId(), postId);

        return ResponseEntity.ok(ApiResponse.success(null));
    }

    /**
     * 게시글 좋아요
     */
    @Operation(summary = "게시글 좋아요", description = "게시글에 좋아요를 누릅니다.")
    @PostMapping("/posts/{postId}/like")
    public ResponseEntity<ApiResponse<CommunityPostResponse>> likePost(@PathVariable Long postId) {
        log.info("POST /community/posts/{}/like", postId);

        CommunityPostResponse response = communityService.likePost(postId);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    // ========== 댓글 관련 ==========

    /**
     * 댓글 생성
     */
    @Operation(summary = "댓글 생성", description = "게시글에 댓글을 작성합니다.")
    @PostMapping("/posts/{postId}/comments")
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long postId,
            @Valid @RequestBody CommentRequest request) {
        log.info("POST /community/posts/{}/comments - User ID: {}", postId, userDetails.getId());

        CommentResponse response = communityService.createComment(userDetails.getId(), postId, request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    /**
     * 댓글 목록 조회
     */
    @Operation(summary = "댓글 목록 조회", description = "특정 게시글의 댓글 목록을 조회합니다.")
    @GetMapping("/posts/{postId}/comments")
    public ResponseEntity<ApiResponse<List<CommentResponse>>> getComments(@PathVariable Long postId) {
        log.info("GET /community/posts/{}/comments", postId);

        List<CommentResponse> response = communityService.getComments(postId);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 댓글 수정
     */
    @Operation(summary = "댓글 수정", description = "댓글을 수정합니다.")
    @PutMapping("/comments/{commentId}")
    public ResponseEntity<ApiResponse<CommentResponse>> updateComment(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long commentId,
            @Valid @RequestBody CommentRequest request) {
        log.info("PUT /community/comments/{} - User ID: {}", commentId, userDetails.getId());

        CommentResponse response = communityService.updateComment(userDetails.getId(), commentId, request);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    /**
     * 댓글 삭제
     */
    @Operation(summary = "댓글 삭제", description = "댓글을 삭제합니다.")
    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @AuthenticationPrincipal CustomUserDetails userDetails,
            @PathVariable Long commentId) {
        log.info("DELETE /community/comments/{} - User ID: {}", commentId, userDetails.getId());

        communityService.deleteComment(userDetails.getId(), commentId);

        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
