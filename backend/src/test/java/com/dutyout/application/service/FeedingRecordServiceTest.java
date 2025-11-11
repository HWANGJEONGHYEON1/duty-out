package com.dutyout.application.service;

import com.dutyout.application.dto.request.FeedingRecordRequest;
import com.dutyout.application.dto.response.FeedingRecordResponse;
import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.feeding.entity.FeedingRecord;
import com.dutyout.domain.feeding.entity.FeedingType;
import com.dutyout.domain.feeding.repository.FeedingRecordRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;

/**
 * FeedingRecordService 단위 테스트
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("FeedingRecordService 단위 테스트")
class FeedingRecordServiceTest {

    @Mock
    private FeedingRecordRepository feedingRecordRepository;

    @InjectMocks
    private FeedingRecordService feedingRecordService;

    private FeedingRecord feedingRecord;
    private FeedingRecordRequest request;

    @BeforeEach
    void setUp() {
        feedingRecord = FeedingRecord.builder()
                .babyId(1L)
                .feedingTime(LocalDateTime.now())
                .type(FeedingType.BOTTLE)
                .amountMl(120)
                .note("잘 먹음")
                .build();

        request = FeedingRecordRequest.builder()
                .feedingTime(LocalDateTime.now())
                .type(FeedingType.BOTTLE)
                .amountMl(120)
                .note("잘 먹음")
                .build();
    }

    @Test
    @DisplayName("수유 기록 생성 성공")
    void createFeedingRecord_Success() {
        // given
        given(feedingRecordRepository.save(any(FeedingRecord.class))).willReturn(feedingRecord);

        // when
        FeedingRecordResponse response = feedingRecordService.createFeedingRecord(1L, request);

        // then
        assertThat(response).isNotNull();
        assertThat(response.getType()).isEqualTo(FeedingType.BOTTLE);
        assertThat(response.getAmountMl()).isEqualTo(120);

        verify(feedingRecordRepository, times(1)).save(any(FeedingRecord.class));
    }

    @Test
    @DisplayName("수유 기록 조회 성공")
    void getFeedingRecord_Success() {
        // given
        given(feedingRecordRepository.findById(1L)).willReturn(Optional.of(feedingRecord));

        // when
        FeedingRecordResponse response = feedingRecordService.getFeedingRecord(1L, 1L);

        // then
        assertThat(response).isNotNull();
        assertThat(response.getBabyId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("수유 기록 조회 실패 - 기록 없음")
    void getFeedingRecord_Fail_NotFound() {
        // given
        given(feedingRecordRepository.findById(1L)).willReturn(Optional.empty());

        // when & then
        assertThatThrownBy(() -> feedingRecordService.getFeedingRecord(1L, 1L))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.FEEDING_RECORD_NOT_FOUND);
    }

    @Test
    @DisplayName("수유 기록 조회 실패 - 권한 없음")
    void getFeedingRecord_Fail_Forbidden() {
        // given
        given(feedingRecordRepository.findById(1L)).willReturn(Optional.of(feedingRecord));

        // when & then
        assertThatThrownBy(() -> feedingRecordService.getFeedingRecord(2L, 1L))
                .isInstanceOf(BusinessException.class)
                .hasFieldOrPropertyWithValue("errorCode", ErrorCode.FORBIDDEN);
    }

    @Test
    @DisplayName("수유 기록 목록 조회 성공")
    void getFeedingRecords_Success() {
        // given
        given(feedingRecordRepository.findByBabyIdOrderByFeedingTimeDesc(1L))
                .willReturn(List.of(feedingRecord));

        // when
        List<FeedingRecordResponse> responses = feedingRecordService.getFeedingRecords(1L);

        // then
        assertThat(responses).hasSize(1);
        assertThat(responses.get(0).getType()).isEqualTo(FeedingType.BOTTLE);
    }

    @Test
    @DisplayName("수유 기록 수정 성공")
    void updateFeedingRecord_Success() {
        // given
        given(feedingRecordRepository.findById(1L)).willReturn(Optional.of(feedingRecord));

        FeedingRecordRequest updateRequest = FeedingRecordRequest.builder()
                .feedingTime(LocalDateTime.now())
                .type(FeedingType.BREAST)
                .amountMl(150)
                .note("수정됨")
                .build();

        // when
        FeedingRecordResponse response = feedingRecordService.updateFeedingRecord(1L, 1L, updateRequest);

        // then
        assertThat(response).isNotNull();
        verify(feedingRecordRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("수유 기록 삭제 성공")
    void deleteFeedingRecord_Success() {
        // given
        given(feedingRecordRepository.findById(1L)).willReturn(Optional.of(feedingRecord));

        // when
        feedingRecordService.deleteFeedingRecord(1L, 1L);

        // then
        verify(feedingRecordRepository, times(1)).delete(feedingRecord);
    }
}
