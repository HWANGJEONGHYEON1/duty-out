package com.dutyout.domain.schedule.repository;

import com.dutyout.domain.schedule.entity.AgeBasedSleepGuideline;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 개월수별 수면 가이드라인 리포지토리
 *
 * Clean Architecture - Infrastructure Layer
 * DDD - Repository Pattern
 */
@Repository
public interface AgeBasedSleepGuidelineRepository extends JpaRepository<AgeBasedSleepGuideline, Long> {

    /**
     * 특정 개월 수의 가이드라인 조회
     *
     * @param ageInMonths 개월 수
     * @return 가이드라인
     */
    Optional<AgeBasedSleepGuideline> findByAgeInMonths(Integer ageInMonths);

    /**
     * 특정 개월 수에 가장 가까운 가이드라인 조회
     * 정확히 일치하는 데이터가 없을 경우 가장 가까운 하위 개월 수 반환
     *
     * @param ageInMonths 개월 수
     * @return 가이드라인
     */
    @Query("SELECT g FROM AgeBasedSleepGuideline g " +
           "WHERE g.ageInMonths <= :ageInMonths " +
           "ORDER BY g.ageInMonths DESC " +
           "LIMIT 1")
    Optional<AgeBasedSleepGuideline> findClosestGuidelineByAge(@Param("ageInMonths") Integer ageInMonths);

    /**
     * 가이드라인 존재 여부 확인
     *
     * @param ageInMonths 개월 수
     * @return 존재 여부
     */
    boolean existsByAgeInMonths(Integer ageInMonths);
}
