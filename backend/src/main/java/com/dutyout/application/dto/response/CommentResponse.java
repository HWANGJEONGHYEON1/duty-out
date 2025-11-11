package com.dutyout.application.dto.response;

import com.dutyout.domain.community.entity.Comment;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * 댓글 응답 DTO
 *
 * Clean Architecture - Application Layer
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommentResponse {

    private Long id;
    private Long postId;
    private String content;
    private String anonymousAuthor;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    /**
     * Entity to DTO 변환
     */
    public static CommentResponse from(Comment comment) {
        return CommentResponse.builder()
                .id(comment.getId())
                .postId(comment.getPostId())
                .content(comment.getContent())
                .anonymousAuthor(comment.getAnonymousAuthor())
                .createdAt(comment.getCreatedAt())
                .updatedAt(comment.getUpdatedAt())
                .build();
    }
}
