package com.dutyout.domain.feeding.repository;

import com.dutyout.domain.feeding.entity.FeedingRecord;
import com.dutyout.domain.feeding.entity.FeedingType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

import static org.assertj.core.api.Assertions.*;

/**
 * FeedingRecordRepository H2 통합 테스트
 *
 * Testing Strategy:
 * - @DataJpaTest: JPA 관련 컴포넌트만 로드
 * - @ActiveProfiles("test"): application-test.yml 사용 (H2 DB)
 * - 실제 데이터베이스 작업 테스트
 *
 * H2 DB 특징:
 * - In-memory 데이터베이스
 * - 테스트 간 격리 보장
 * - 빠른 실행 속도
 */
@DataJpaTest
@ActiveProfiles("test")
@DisplayName("FeedingRecordRepository H2 통합 테스트")
class FeedingRecordRepositoryTest {

    @Autowired
    private FeedingRecordRepository feedingRecordRepository;

    private FeedingRecord feedingRecord1;
    private FeedingRecord feedingRecord2;

    @BeforeEach
    void setUp() {
        // 테스트 데이터 준비
        feedingRecord1 = FeedingRecord.builder()
                .babyId(1L)
                .feedingTime(LocalDateTime.now().minusHours(2))
                .type(FeedingType.BOTTLE)
                .amountMl(120)
                .note("첫 번째 수유")
                .build();

        feedingRecord2 = FeedingRecord.builder()
                .babyId(1L)
                .feedingTime(LocalDateTime.now().minusHours(1))
                .type(FeedingType.BREAST)
                .amountMl(100)
                .note("두 번째 수유")
                .build();

        feedingRecordRepository.save(feedingRecord1);
        feedingRecordRepository.save(feedingRecord2);
    }

    @Test
    @DisplayName("아기 ID로 수유 기록 조회 - 최신순 정렬")
    void findByBabyIdOrderByFeedingTimeDesc_Success() {
        // when
        List<FeedingRecord> records = feedingRecordRepository
                .findByBabyIdOrderByFeedingTimeDesc(1L);

        // then
        assertThat(records).hasSize(2);
        assertThat(records.get(0).getNote()).isEqualTo("두 번째 수유"); // 최신순
        assertThat(records.get(1).getNote()).isEqualTo("첫 번째 수유");
    }

    @Test
    @DisplayName("기간별 수유 기록 조회")
    void findByBabyIdAndFeedingTimeBetween_Success() {
        // given
        LocalDateTime startDate = LocalDateTime.now().minusHours(3);
        LocalDateTime endDate = LocalDateTime.now();

        // when
        List<FeedingRecord> records = feedingRecordRepository
                .findByBabyIdAndFeedingTimeBetweenOrderByFeedingTimeDesc(1L, startDate, endDate);

        // then
        assertThat(records).hasSize(2);
    }

    @Test
    @DisplayName("수유 유형별 조회")
    void findByBabyIdAndType_Success() {
        // when
        List<FeedingRecord> bottleRecords = feedingRecordRepository
                .findByBabyIdAndTypeOrderByFeedingTimeDesc(1L, FeedingType.BOTTLE);

        List<FeedingRecord> breastRecords = feedingRecordRepository
                .findByBabyIdAndTypeOrderByFeedingTimeDesc(1L, FeedingType.BREAST);

        // then
        assertThat(bottleRecords).hasSize(1);
        assertThat(bottleRecords.get(0).getType()).isEqualTo(FeedingType.BOTTLE);

        assertThat(breastRecords).hasSize(1);
        assertThat(breastRecords.get(0).getType()).isEqualTo(FeedingType.BREAST);
    }

    @Test
    @DisplayName("오늘 총 수유량 조회")
    void getTotalAmountToday_Success() {
        // given
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = LocalDate.now().atTime(LocalTime.MAX);

        // when
        Integer totalAmount = feedingRecordRepository.getTotalAmountToday(1L, startOfDay, endOfDay);

        // then
        assertThat(totalAmount).isEqualTo(220); // 120 + 100
    }

    @Test
    @DisplayName("아기별 수유 기록 개수 조회")
    void countByBabyId_Success() {
        // when
        long count = feedingRecordRepository.countByBabyId(1L);

        // then
        assertThat(count).isEqualTo(2);
    }

    @Test
    @DisplayName("수유 기록 존재 여부 확인")
    void existsByBabyIdAndFeedingTimeBetween_Success() {
        // given
        LocalDateTime startDate = LocalDateTime.now().minusHours(3);
        LocalDateTime endDate = LocalDateTime.now();

        // when
        boolean exists = feedingRecordRepository
                .existsByBabyIdAndFeedingTimeBetween(1L, startDate, endDate);

        // then
        assertThat(exists).isTrue();
    }
}
