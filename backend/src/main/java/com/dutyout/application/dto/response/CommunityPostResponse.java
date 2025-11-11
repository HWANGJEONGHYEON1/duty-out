package com.dutyout.application.dto.response;

import com.dutyout.domain.community.entity.CommunityPost;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 커뮤니티 게시글 응답 DTO
 *
 * Clean Architecture - Application Layer
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommunityPostResponse {

    private Long id;
    private String title;
    private String content;
    private String anonymousAuthor;
    private Integer likeCount;
    private Integer commentCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Entity to DTO 변환
     */
    public static CommunityPostResponse from(CommunityPost post) {
        return CommunityPostResponse.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .anonymousAuthor(post.getAnonymousAuthor())
                .likeCount(post.getLikeCount())
                .commentCount(post.getCommentCount())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .build();
    }
}
