package com.dutyout.domain.feeding.repository;

import com.dutyout.domain.feeding.entity.FeedingRecord;
import com.dutyout.domain.feeding.entity.FeedingType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 수유 기록 리포지토리
 *
 * Clean Architecture - Infrastructure Layer (Interface는 Domain Layer)
 * DDD - Repository Pattern
 *
 * Spring Data JPA를 사용하여 수유 기록의 데이터베이스 접근을 처리합니다.
 */
@Repository
public interface FeedingRecordRepository extends JpaRepository<FeedingRecord, Long> {

    /**
     * 특정 아기의 모든 수유 기록 조회
     *
     * @param babyId 아기 ID
     * @return 수유 기록 리스트 (최신순)
     */
    List<FeedingRecord> findByBabyIdOrderByFeedingTimeDesc(Long babyId);

    /**
     * 특정 아기의 기간별 수유 기록 조회
     *
     * @param babyId 아기 ID
     * @param startDate 시작 날짜
     * @param endDate 종료 날짜
     * @return 수유 기록 리스트 (최신순)
     */
    List<FeedingRecord> findByBabyIdAndFeedingTimeBetweenOrderByFeedingTimeDesc(
            Long babyId, LocalDateTime startDate, LocalDateTime endDate);

    /**
     * 특정 아기의 특정 유형 수유 기록 조회
     *
     * @param babyId 아기 ID
     * @param type 수유 유형
     * @return 수유 기록 리스트 (최신순)
     */
    List<FeedingRecord> findByBabyIdAndTypeOrderByFeedingTimeDesc(Long babyId, FeedingType type);

    /**
     * 특정 아기의 오늘 수유 통계
     * 총 수유량(ml) 계산
     *
     * @param babyId 아기 ID
     * @param startOfDay 오늘 시작 시간
     * @param endOfDay 오늘 종료 시간
     * @return 총 수유량 (ml), null인 경우 0으로 처리 필요
     */
    @Query("SELECT COALESCE(SUM(f.amountMl), 0) FROM FeedingRecord f " +
           "WHERE f.babyId = :babyId " +
           "AND f.feedingTime BETWEEN :startOfDay AND :endOfDay")
    Integer getTotalAmountToday(@Param("babyId") Long babyId,
                                 @Param("startOfDay") LocalDateTime startOfDay,
                                 @Param("endOfDay") LocalDateTime endOfDay);

    /**
     * 특정 아기의 기간별 수유 통계
     * 날짜별 총 수유량 계산
     *
     * @param babyId 아기 ID
     * @param startDate 시작 날짜
     * @param endDate 종료 날짜
     * @return 날짜별 총 수유량 리스트
     */
    @Query("SELECT DATE(f.feedingTime) as date, COALESCE(SUM(f.amountMl), 0) as totalAmount " +
           "FROM FeedingRecord f " +
           "WHERE f.babyId = :babyId " +
           "AND f.feedingTime BETWEEN :startDate AND :endDate " +
           "GROUP BY DATE(f.feedingTime) " +
           "ORDER BY DATE(f.feedingTime)")
    List<Object[]> getDailyFeedingStats(@Param("babyId") Long babyId,
                                        @Param("startDate") LocalDateTime startDate,
                                        @Param("endDate") LocalDateTime endDate);

    /**
     * 특정 아기의 수유 기록 개수 조회
     *
     * @param babyId 아기 ID
     * @return 수유 기록 개수
     */
    long countByBabyId(Long babyId);

    /**
     * 특정 아기의 특정 기간 수유 기록 존재 여부
     *
     * @param babyId 아기 ID
     * @param startDate 시작 날짜
     * @param endDate 종료 날짜
     * @return 존재 여부
     */
    boolean existsByBabyIdAndFeedingTimeBetween(Long babyId, LocalDateTime startDate, LocalDateTime endDate);
}
