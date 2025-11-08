package com.dutyout.domain.schedule.repository;

import com.dutyout.domain.schedule.entity.ScheduleTemplate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ScheduleTemplateRepository extends JpaRepository<ScheduleTemplate, Long> {

    Optional<ScheduleTemplate> findByAgeMonths(Integer ageMonths);

    /**
     * 가장 가까운 월령의 템플릿 찾기
     * 정확한 월령이 없으면 가장 가까운 템플릿 반환
     */
    @Query("SELECT t FROM ScheduleTemplate t WHERE t.ageMonths <= :ageMonths ORDER BY t.ageMonths DESC LIMIT 1")
    Optional<ScheduleTemplate> findClosestTemplateByAge(@Param("ageMonths") Integer ageMonths);
}
