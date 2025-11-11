package com.dutyout.infrastructure.data;

import com.dutyout.domain.schedule.entity.AgeBasedSleepGuideline;
import com.dutyout.domain.schedule.repository.AgeBasedSleepGuidelineRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * 수면 가이드라인 초기 데이터 로더
 *
 * Clean Architecture - Infrastructure Layer
 *
 * 애플리케이션 시작 시 개월수별 수면 가이드라인 데이터를 데이터베이스에 삽입합니다.
 *
 * 데이터 출처:
 * - 수면 교육 전문가 가이드라인
 * - 소아과 권장 사항
 *
 * 주의사항:
 * - dev, local 프로필에서만 실행
 * - 이미 데이터가 있으면 스킵
 */
@Slf4j
@Component
@Profile({"dev", "local", "test"})
@RequiredArgsConstructor
public class SleepGuidelineDataLoader implements CommandLineRunner {

    private final AgeBasedSleepGuidelineRepository guidelineRepository;

    @Override
    public void run(String... args) {
        log.info("수면 가이드라인 데이터 로딩 시작...");

        // 이미 데이터가 있으면 스킵
        if (guidelineRepository.count() > 0) {
            log.info("이미 가이드라인 데이터가 존재합니다. 스킵합니다.");
            return;
        }

        // 개월수별 가이드라인 데이터 삽입
        loadMonthlyGuidelines();

        log.info("수면 가이드라인 데이터 로딩 완료! 총 {}개", guidelineRepository.count());
    }

    /**
     * 개월수별 가이드라인 데이터 로딩
     */
    private void loadMonthlyGuidelines() {
        // 1개월 (42일~60일)
        guidelineRepository.save(createGuideline(
                1, // 개월 수
                60, 75, // 깨시: 60~75분
                4, // 낮잠 횟수
                360, // 최대 낮잠 총 시간: 6시간
                660, 720, // 밤잠: 11~12시간
                21, 30, // 취침 시간: 21:30
                60, 65, 75, // 첫/중간/마지막 깨시
                60, 120, // 1회 수유량: 60~120ml
                8, 12, // 모유 횟수: 8~12회
                6, 8, // 분유 횟수: 6~8회
                150, // 수유 간격: 2.5시간
                "첫 달은 수면 패턴이 불규칙할 수 있습니다."
        ));

        // 2개월 (60일~90일)
        guidelineRepository.save(createGuideline(
                2, // 개월 수
                75, 90, // 깨시: 75~90분
                4, // 낮잠 횟수
                300, // 최대 낮잠 총 시간: 5시간
                660, 720, // 밤잠: 11~12시간
                20, 30, // 취침 시간: 20:30
                75, 80, 90, // 첫/중간/마지막 깨시
                90, 150, // 1회 수유량: 90~150ml
                8, 12, // 모유 횟수
                5, 6, // 분유 횟수
                150, // 수유 간격
                "밤잠이 조금씩 길어지기 시작합니다."
        ));

        // 3개월 (90일 이후)
        guidelineRepository.save(createGuideline(
                3,
                90, 120, // 깨시: 90~120분
                4, // 낮잠 횟수
                240, // 최대 낮잠 총 시간: 4시간
                600, 720, // 밤잠: 10~12시간
                19, 30, // 취침 시간: 19:30
                90, 105, 120, // 첫/중간/마지막 깨시
                120, 180, // 1회 수유량: 120~180ml
                7, 9, // 모유 횟수
                5, 6, // 분유 횟수
                180, // 수유 간격: 3시간
                "수면 교육을 시작하기 좋은 시기입니다."
        ));

        // 4개월
        guidelineRepository.save(createGuideline(
                4,
                110, 135, // 깨시: 1시간 50분~2시간 15분
                3, // 낮잠 횟수 (3~4회 전환기)
                210, // 최대 낮잠: 3시간 30분
                600, 720,
                19, 0,
                110, 120, 135,
                120, 180,
                7, 9,
                5, 6,
                180,
                "4회->3회 낮잠 전환기입니다."
        ));

        // 5개월
        guidelineRepository.save(createGuideline(
                5,
                120, 150, // 깨시: 2~2.5시간
                3, // 낮잠 횟수
                210, // 최대 낮잠: 3시간 30분
                600, 720,
                19, 0,
                120, 135, 150,
                120, 180,
                6, 8,
                4, 6,
                210,
                "3회 낮잠이 안정됩니다."
        ));

        // 6개월
        guidelineRepository.save(createGuideline(
                6,
                120, 180, // 깨시: 2~3시간
                3, // 낮잠 횟수 (3회 또는 2회)
                180, // 최대 낮잠: 3시간
                600, 720,
                19, 0,
                120, 150, 180,
                150, 200,
                5, 7,
                4, 5,
                210,
                "이유식 시작 시기, 3회->2회 전환 준비"
        ));

        // 7개월
        guidelineRepository.save(createGuideline(
                7,
                165, 240, // 깨시: 2시간 45분~4시간
                2, // 낮잠 횟수 (2~3회 전환기)
                165, // 최대 낮잠: 2.5~3시간
                600, 720,
                19, 0,
                165, 180, 240,
                150, 200,
                5, 6,
                4, 5,
                240,
                "3회->2회 낮잠 전환기"
        ));

        // 8개월
        guidelineRepository.save(createGuideline(
                8,
                180, 240, // 깨시: 3~4시간
                2, // 낮잠 횟수
                150, // 최대 낮잠: 2.5~3시간
                600, 720,
                19, 0,
                180, 210, 240,
                180, 220,
                4, 6,
                3, 4,
                240,
                "2회 낮잠이 안정됩니다."
        ));

        // 12개월
        guidelineRepository.save(createGuideline(
                12,
                270, 360, // 깨시: 4.5~6시간
                1, // 낮잠 횟수
                150, // 최대 낮잠: 2.5~3시간
                600, 720,
                20, 0,
                270, 300, 360,
                200, 240,
                3, 5,
                3, 4,
                300,
                "2회->1회 낮잠 전환 시작"
        ));

        // 18개월
        guidelineRepository.save(createGuideline(
                18,
                300, 360, // 깨시: 5~6시간
                1, // 낮잠 횟수
                150, // 최대 낮잠: 2.5시간
                600, 660,
                20, 0,
                300, 330, 360,
                200, 240,
                3, 4,
                3, 4,
                300,
                "1회 낮잠이 안정됩니다."
        ));

        // 24개월 (2세)
        guidelineRepository.save(createGuideline(
                24,
                330, 390, // 깨시: 5.5~6.5시간
                1, // 낮잠 횟수
                120, // 최대 낮잠: 2시간
                600, 660,
                20, 0,
                330, 360, 390,
                200, 240,
                3, 4,
                3, 4,
                300,
                "밤잠이 더 중요해집니다."
        ));

        // 36개월 (3세)
        guidelineRepository.save(createGuideline(
                36,
                360, 480, // 깨시: 6~8시간
                1, // 낮잠 횟수 (0~1회)
                90, // 최대 낮잠: 1.5시간
                540, 660,
                20, 0,
                360, 420, 480,
                240, 300,
                3, 3,
                3, 3,
                360,
                "낮잠 없이도 가능한 아이들이 있습니다."
        ));

        // 48개월 (4세)
        guidelineRepository.save(createGuideline(
                48,
                480, 720, // 깨시: 8~12시간
                0, // 낮잠 횟수
                0, // 최대 낮잠: 0시간
                540, 660,
                20, 0,
                480, 600, 720,
                240, 300,
                3, 3,
                3, 3,
                360,
                "대부분 낮잠 없이 생활합니다."
        ));
    }

    /**
     * 가이드라인 생성 헬퍼 메서드
     */
    private AgeBasedSleepGuideline createGuideline(
            int ageInMonths,
            int wakeWindowMin,
            int wakeWindowMax,
            int napCount,
            int maxTotalNapMinutes,
            int nightSleepMin,
            int nightSleepMax,
            int bedtimeHour,
            int bedtimeMinute,
            int firstWakeWindow,
            int middleWakeWindow,
            int lastWakeWindow,
            int feedingAmountMin,
            int feedingAmountMax,
            int breastfeedingCountMin,
            int breastfeedingCountMax,
            int formulaCountMin,
            int formulaCountMax,
            int feedingInterval,
            String description) {

        return AgeBasedSleepGuideline.builder()
                .ageInMonths(ageInMonths)
                .wakeWindowMinMinutes(wakeWindowMin)
                .wakeWindowMaxMinutes(wakeWindowMax)
                .napCount(napCount)
                .maxTotalNapMinutes(maxTotalNapMinutes)
                .nightSleepMinMinutes(nightSleepMin)
                .nightSleepMaxMinutes(nightSleepMax)
                .recommendedBedtimeHour(bedtimeHour)
                .recommendedBedtimeMinute(bedtimeMinute)
                .firstWakeWindowMinutes(firstWakeWindow)
                .middleWakeWindowMinutes(middleWakeWindow)
                .lastWakeWindowMinutes(lastWakeWindow)
                .feedingAmountMinMl(feedingAmountMin)
                .feedingAmountMaxMl(feedingAmountMax)
                .breastfeedingCountMin(breastfeedingCountMin)
                .breastfeedingCountMax(breastfeedingCountMax)
                .formulaFeedingCountMin(formulaCountMin)
                .formulaFeedingCountMax(formulaCountMax)
                .feedingIntervalMinutes(feedingInterval)
                .description(description)
                .build();
    }
}
