package com.dutyout.application.service;

import com.dutyout.application.dto.request.AdjustScheduleRequest;
import com.dutyout.application.dto.request.GenerateAutoScheduleRequest;
import com.dutyout.application.dto.response.AutoScheduleResponse;
import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.repository.BabyRepository;
import com.dutyout.domain.schedule.entity.ActivityType;
import com.dutyout.domain.schedule.entity.AgeBasedSleepGuideline;
import com.dutyout.domain.schedule.entity.DailySchedule;
import com.dutyout.domain.schedule.entity.ScheduleItem;
import com.dutyout.domain.schedule.repository.AgeBasedSleepGuidelineRepository;
import com.dutyout.domain.schedule.repository.DailyScheduleRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 자동 스케줄 생성 서비스
 *
 * Clean Architecture - Application Layer
 * DDD - Application Service
 *
 * 아기의 개월 수와 기상 시간을 기반으로 하루 스케줄을 자동 생성하고,
 * 실제 수면 시간이 변경되면 이후 스케줄을 동적으로 조정합니다.
 *
 * 주요 기능:
 * - 개월수별 가이드라인 기반 자동 스케줄 생성
 * - 깨시(깨어있는 시간) 기반 낮잠 시간 계산
 * - 수유 간격 기반 수유 시간 계산
 * - 실시간 스케줄 조정 (과피로 방지)
 *
 * 비즈니스 규칙:
 * - 첫 번째 낮잠까지의 깨시가 가장 짧음
 * - 마지막 낮잠에서 취침까지의 깨시가 가장 김
 * - 총 낮잠 시간은 가이드라인의 최대치를 넘지 않음
 * - 수유는 깨시를 기준으로 배치 (보통 2.5~3시간 간격)
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AutoScheduleService {

    private final BabyRepository babyRepository;
    private final AgeBasedSleepGuidelineRepository guidelineRepository;
    private final DailyScheduleRepository dailyScheduleRepository;

    /**
     * 자동 스케줄 생성
     *
     * @param babyId 아기 ID
     * @param request 생성 요청 (기상 시간 포함)
     * @return 생성된 스케줄
     */
    @Transactional
    public AutoScheduleResponse generateAutoSchedule(Long babyId, GenerateAutoScheduleRequest request) {
        log.info("자동 스케줄 생성 시작 - Baby ID: {}, 기상 시간: {}", babyId, request.getWakeUpTime());

        // 1. 아기 정보 조회
        Baby baby = babyRepository.findById(babyId)
                .orElseThrow(() -> new BusinessException(ErrorCode.BABY_NOT_FOUND));

        int ageInMonths = baby.calculateAgeInMonths();
        log.info("아기 개월 수: {}개월", ageInMonths);

        // 2. 개월수별 가이드라인 조회
        AgeBasedSleepGuideline guideline = guidelineRepository.findClosestGuidelineByAge(ageInMonths)
                .orElseThrow(() -> new BusinessException(ErrorCode.TEMPLATE_NOT_FOUND));

        log.info("가이드라인 조회 완료 - 낮잠 횟수: {}회, 권장 취침: {}:{}",
                guideline.getNapCount(),
                guideline.getRecommendedBedtimeHour(),
                guideline.getRecommendedBedtimeMinute());

        // 3. 기존 스케줄 확인 및 삭제 (오늘 날짜)
        LocalDate today = LocalDate.now();
        dailyScheduleRepository.findByBabyIdAndScheduleDate(babyId, today)
                .ifPresent(dailyScheduleRepository::delete);

        // 4. 스케줄 아이템 생성
        List<ScheduleItem> scheduleItems = buildScheduleItems(guideline, request, baby);

        // 5. DailySchedule 생성 및 저장
        DailySchedule dailySchedule = DailySchedule.builder()
                .babyId(babyId)
                .scheduleDate(today)
                .wakeUpTime(request.getWakeUpTime())
                .ageInMonths(ageInMonths)
                .build();

        dailySchedule.addScheduleItems(scheduleItems);
        dailySchedule = dailyScheduleRepository.save(dailySchedule);

        log.info("자동 스케줄 생성 완료 - Schedule ID: {}, 총 {}개 아이템",
                dailySchedule.getId(), scheduleItems.size());

        // 6. Response 생성
        return buildAutoScheduleResponse(dailySchedule, guideline);
    }

    /**
     * 스케줄 아이템 생성
     *
     * 비즈니스 로직:
     * - 기상 -> 첫 낮잠 -> 수유 -> 두번째 낮잠 -> 수유 -> ... -> 취침
     * - 낮잠 지속 시간 = 총 낮잠 시간 / 낮잠 횟수
     * - 수유는 깨시 고려하여 배치
     */
    private List<ScheduleItem> buildScheduleItems(
            AgeBasedSleepGuideline guideline,
            GenerateAutoScheduleRequest request,
            Baby baby) {

        List<ScheduleItem> items = new ArrayList<>();
        LocalTime currentTime = request.getWakeUpTime();
        int sequence = 0;

        // 1. 기상
        items.add(ScheduleItem.builder()
                .activityType(ActivityType.WAKE_UP)
                .scheduledTime(currentTime)
                .durationMinutes(0)
                .note("기상 및 수유")
                .build());

        // 2. 낮잠 평균 지속 시간 계산
        int napDurationMinutes = guideline.getMaxTotalNapMinutes() / guideline.getNapCount();

        // 3. 낮잠 및 수유 스케줄 생성
        for (int napIndex = 0; napIndex < guideline.getNapCount(); napIndex++) {
            // 깨시 계산 (낮잠 순서에 따라 다름)
            int wakeWindow = guideline.getWakeWindowForNap(napIndex);

            // 수유 시간 (낮잠 전)
            LocalTime feedingTime = currentTime.plusMinutes(wakeWindow - 30); // 낮잠 30분 전 수유
            if (napIndex > 0) { // 첫 번째는 기상 시 수유했으므로 제외
                items.add(ScheduleItem.builder()
                        .activityType(ActivityType.FEEDING)
                        .scheduledTime(feedingTime)
                        .durationMinutes(30)
                        .note(buildFeedingNote(guideline, baby))
                        .build());
            }

            // 낮잠 시작 시간
            LocalTime napStartTime = currentTime.plusMinutes(wakeWindow);

            ActivityType napType = switch (napIndex + 1) {
                case 1 -> ActivityType.NAP1;
                case 2 -> ActivityType.NAP2;
                case 3 -> ActivityType.NAP3;
                case 4 -> ActivityType.NAP4;
                default -> ActivityType.NAP;
            };

            items.add(ScheduleItem.builder()
                    .activityType(napType)
                    .scheduledTime(napStartTime)
                    .durationMinutes(napDurationMinutes)
                    .note(String.format("낮잠 %d (약 %d분)", napIndex + 1, napDurationMinutes))
                    .build());

            // 다음 활동 시작 시간 = 낮잠 종료 시간
            currentTime = napStartTime.plusMinutes(napDurationMinutes);
        }

        // 4. 마지막 수유 (취침 전)
        LocalTime lastFeedingTime = currentTime.plusMinutes(
                guideline.getLastWakeWindowMinutes() != null
                        ? guideline.getLastWakeWindowMinutes() - 30
                        : guideline.getAverageWakeWindowMinutes() - 30
        );

        items.add(ScheduleItem.builder()
                .activityType(ActivityType.FEEDING)
                .scheduledTime(lastFeedingTime)
                .durationMinutes(30)
                .note("마지막 수유")
                .build());

        // 5. 취침
        int lastWakeWindow = guideline.getLastWakeWindowMinutes() != null
                ? guideline.getLastWakeWindowMinutes()
                : guideline.getAverageWakeWindowMinutes();

        LocalTime bedtime = currentTime.plusMinutes(lastWakeWindow);

        items.add(ScheduleItem.builder()
                .activityType(ActivityType.BEDTIME)
                .scheduledTime(bedtime)
                .durationMinutes(guideline.getNightSleepMinMinutes())
                .note(String.format("권장 취침 시간: %02d:%02d",
                        guideline.getRecommendedBedtimeHour(),
                        guideline.getRecommendedBedtimeMinute()))
                .build());

        return items;
    }

    /**
     * 수유 노트 생성
     */
    private String buildFeedingNote(AgeBasedSleepGuideline guideline, Baby baby) {
        return String.format("수유 (%d~%dml, 간격: %d분)",
                guideline.getFeedingAmountMinMl(),
                guideline.getFeedingAmountMaxMl(),
                guideline.getFeedingIntervalMinutes());
    }

    /**
     * AutoScheduleResponse 생성
     */
    private AutoScheduleResponse buildAutoScheduleResponse(
            DailySchedule dailySchedule,
            AgeBasedSleepGuideline guideline) {

        List<AutoScheduleResponse.ScheduleItemDetail> itemDetails = dailySchedule.getScheduleItems().stream()
                .map(item -> AutoScheduleResponse.ScheduleItemDetail.builder()
                        .id(item.getId())
                        .startTime(item.getScheduledTime())
                        .endTime(item.getDurationMinutes() != null
                                ? item.getScheduledTime().plusMinutes(item.getDurationMinutes())
                                : null)
                        .activityType(item.getActivityType())
                        .activityName(item.getActivityType().getKoreanName())
                        .durationMinutes(item.getDurationMinutes())
                        .note(item.getNote())
                        .build())
                .toList();

        long napCount = dailySchedule.getScheduleItems().stream()
                .filter(item -> item.getActivityType().name().startsWith("NAP"))
                .count();

        long feedingCount = dailySchedule.getScheduleItems().stream()
                .filter(item -> item.getActivityType() == ActivityType.FEEDING)
                .count();

        LocalTime bedtime = dailySchedule.getScheduleItems().stream()
                .filter(item -> item.getActivityType() == ActivityType.BEDTIME)
                .findFirst()
                .map(ScheduleItem::getScheduledTime)
                .orElse(null);

        return AutoScheduleResponse.builder()
                .scheduleId(dailySchedule.getId())
                .babyId(dailySchedule.getBabyId())
                .ageInMonths(dailySchedule.getAgeInMonths())
                .wakeUpTime(dailySchedule.getWakeUpTime())
                .bedtime(bedtime)
                .totalNapCount((int) napCount)
                .totalFeedingCount((int) feedingCount)
                .items(itemDetails)
                .build();
    }

    /**
     * 스케줄 동적 조정
     *
     * 실제 낮잠 시간이 변경되면 이후 스케줄을 자동으로 재계산합니다.
     *
     * @param babyId 아기 ID
     * @param request 조정 요청
     * @return 조정된 스케줄
     */
    @Transactional
    public AutoScheduleResponse adjustSchedule(Long babyId, AdjustScheduleRequest request) {
        log.info("스케줄 동적 조정 시작 - Baby ID: {}, Item ID: {}",
                babyId, request.getScheduleItemId());

        // TODO: 동적 조정 로직 구현
        // 1. 변경된 아이템 찾기
        // 2. 시간 차이 계산
        // 3. 이후 모든 아이템 시간 조정
        // 4. 과피로 방지 체크 (깨시 초과 시 경고)

        throw new UnsupportedOperationException("동적 조정 기능은 곧 구현됩니다.");
    }
}
