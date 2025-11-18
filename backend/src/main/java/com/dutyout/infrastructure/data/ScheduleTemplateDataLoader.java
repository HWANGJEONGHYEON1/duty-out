package com.dutyout.infrastructure.data;

import com.dutyout.domain.schedule.entity.ScheduleTemplate;
import com.dutyout.domain.schedule.repository.ScheduleTemplateRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 스케줄 템플릿 초기 데이터 로더
 *
 * 애플리케이션 시작 시 개월수별 스케줄 템플릿 데이터를 데이터베이스에 삽입합니다.
 * 개월별로 권장되는 낮잠 횟수, Wake Window, 낮잠 시간을 정의합니다.
 *
 * 실행 순서:
 * 1. SleepGuidelineDataLoader (Order=1)
 * 2. ScheduleTemplateDataLoader (Order=1) - 이 클래스
 * 3. MockDataLoader (Order=2)
 */
@Slf4j
@Component
@Profile({"dev", "local", "test"})
@Order(1) // SleepGuidelineDataLoader 이후에 실행
@RequiredArgsConstructor
public class ScheduleTemplateDataLoader implements CommandLineRunner {

    private final ScheduleTemplateRepository templateRepository;

    @Override
    public void run(String... args) {
        log.info("스케줄 템플릿 데이터 로딩 시작...");

        // 이미 데이터가 있으면 스킵
        if (templateRepository.count() > 0) {
            log.info("이미 스케줄 템플릿 데이터가 존재합니다. 스킵합니다.");
            return;
        }

        loadScheduleTemplates();

        log.info("스케줄 템플릿 데이터 로딩 완료! 총 {}개", templateRepository.count());
    }

    /**
     * 개월수별 스케줄 템플릿 로딩
     */
    private void loadScheduleTemplates() {
        // 0-1개월: 신생아 (4낮잠)
        templateRepository.save(createTemplate(
                0, // ageMonths
                4, // napCount
                14.0f, // totalSleepHours
                Arrays.asList(60, 60, 60, 120), // wakeWindowsMinutes
                Arrays.asList(30, 45, 45, 60), // napDurationsMinutes
                "신생아 스케줄 (4회 낮잠, 매우 짧은 깨시)"
        ));

        // 1-2개월 (4낮잠)
        templateRepository.save(createTemplate(
                1,
                4,
                14.0f,
                Arrays.asList(60, 75, 75, 120),
                Arrays.asList(45, 60, 60, 90),
                "1개월 스케줄 (4회 낮잠, 깨시 증가 중)"
        ));

        // 2-3개월 (4낮잠)
        templateRepository.save(createTemplate(
                2,
                4,
                13.5f,
                Arrays.asList(75, 90, 90, 150),
                Arrays.asList(50, 60, 75, 90),
                "2개월 스케줄 (4회 낮잠, 깨시 90분대)"
        ));

        // 3-4개월 (3-4낮잠, 전환기)
        templateRepository.save(createTemplate(
                3,
                4,
                12.5f,
                Arrays.asList(90, 110, 120, 150),
                Arrays.asList(60, 75, 90, 90),
                "3개월 스케줄 (4회 낮잠, 깨시 90~120분)"
        ));

        // 4-5개월 (3낮잠)
        templateRepository.save(createTemplate(
                4,
                3,
                12.0f,
                Arrays.asList(110, 120, 150),
                Arrays.asList(75, 90, 120),
                "4개월 스케줄 (3회 낮잠, 4회→3회 전환)"
        ));

        // 5-6개월 (3낮잠)
        templateRepository.save(createTemplate(
                5,
                3,
                11.5f,
                Arrays.asList(120, 135, 150),
                Arrays.asList(90, 120, 150),
                "5개월 스케줄 (3회 낮잠, 깨시 2시간대)"
        ));

        // 6-7개월 (2-3낮잠, 전환기)
        templateRepository.save(createTemplate(
                6,
                3,
                11.0f,
                Arrays.asList(130, 150, 180),
                Arrays.asList(120, 150, 150),
                "6개월 스케줄 (3회 낮잠, 이유식 시작 시기)"
        ));

        // 7-8개월 (2낮잠)
        templateRepository.save(createTemplate(
                7,
                2,
                10.5f,
                Arrays.asList(150, 180, 210),
                Arrays.asList(150, 180),
                "7개월 스케줄 (2회 낮잠, 3회→2회 전환)"
        ));

        // 8-9개월 (2낮잠)
        templateRepository.save(createTemplate(
                8,
                2,
                10.0f,
                Arrays.asList(165, 210, 240),
                Arrays.asList(150, 180),
                "8개월 스케줄 (2회 낮잠, 깨시 3시간대)"
        ));

        // 9-12개월 (2낮잠)
        templateRepository.save(createTemplate(
                9,
                2,
                10.0f,
                Arrays.asList(180, 240, 300),
                Arrays.asList(150, 180),
                "9개월 스케줄 (2회 낮잠)"
        ));

        // 12개월+ (1낮잠)
        templateRepository.save(createTemplate(
                12,
                1,
                10.0f,
                Arrays.asList(270, 360),
                Arrays.asList(180),
                "12개월+ 스케줄 (1회 낮잠, 2회→1회 전환)"
        ));
    }

    /**
     * 스케줄 템플릿 생성 헬퍼 메서드
     */
    private ScheduleTemplate createTemplate(
            Integer ageMonths,
            Integer napCount,
            Float totalSleepHours,
            List<Integer> wakeWindowsMinutes,
            List<Integer> napDurationsMinutes,
            String description) {

        return ScheduleTemplate.builder()
                .ageMonths(ageMonths)
                .napCount(napCount)
                .totalSleepHours(totalSleepHours)
                .wakeWindowsMinutes(new ArrayList<>(wakeWindowsMinutes))
                .napDurationsMinutes(new ArrayList<>(napDurationsMinutes))
                .description(description)
                .build();
    }
}
