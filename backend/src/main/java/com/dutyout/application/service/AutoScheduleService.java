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
    private final com.dutyout.domain.schedule.service.StandardScheduleService standardScheduleService;

    /**
     * 자동 스케줄 생성 (표준 스케줄 기반)
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
        // unique 제약 위반 방지를 위해 기존 스케줄을 먼저 삭제
        LocalDate today = LocalDate.now();
        int deletedCount = dailyScheduleRepository.deleteByBabyIdAndScheduleDate(babyId, today);
        log.info("기존 스케줄 삭제 완료 - 삭제 건수: {}", deletedCount);

        // 4. 표준 스케줄 조회 및 기상 시간에 맞게 조정
        List<com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem> standardItems =
                standardScheduleService.getStandardSchedule(ageInMonths);
        List<com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem> adjustedItems =
                standardScheduleService.adjustScheduleToWakeTime(standardItems, request.getWakeUpTime());

        // 5. 스케줄 아이템 생성
        List<ScheduleItem> scheduleItems = new ArrayList<>();
        for (com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem item : adjustedItems) {
            scheduleItems.add(ScheduleItem.builder()
                    .activityType(item.getActivityType())
                    .scheduledTime(item.getTime())
                    .durationMinutes(item.getDurationMinutes())
                    .note(item.getNote())
                    .build());
        }

        // 6. DailySchedule 생성 및 저장
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

        // 7. Response 생성
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
     * 스케줄 동적 조정 (실제 수면 시간 기준)
     *
     * 사용자가 실제 수면 시간을 입력하면, 해당 시간을 기준으로 다음 스케줄을 재계산합니다.
     * 예: 13:00에 낮잠 예정 → 실제로 40분만 잠 → 다음 스케줄은 13:40부터 시작
     *
     * @param babyId 아기 ID
     * @param request 조정 요청
     * @return 조정된 스케줄
     */
    @Transactional
    public AutoScheduleResponse adjustSchedule(Long babyId, AdjustScheduleRequest request) {
        log.info("스케줄 동적 조정 시작 - Baby ID: {}, Item ID: {}",
                babyId, request.getScheduleItemId());

        // 1. 아기 정보 조회
        Baby baby = babyRepository.findById(babyId)
                .orElseThrow(() -> new BusinessException(ErrorCode.BABY_NOT_FOUND));

        // 2. 오늘의 일일 스케줄 조회
        LocalDate today = LocalDate.now();
        DailySchedule dailySchedule = dailyScheduleRepository.findByBabyIdAndScheduleDate(babyId, today)
                .orElseThrow(() -> new BusinessException(ErrorCode.SCHEDULE_NOT_FOUND));

        // 3. 변경된 아이템 찾기
        ScheduleItem changedItem = null;
        int changedItemIndex = -1;
        for (int i = 0; i < dailySchedule.getScheduleItems().size(); i++) {
            ScheduleItem item = dailySchedule.getScheduleItems().get(i);
            if (item.getId().equals(request.getScheduleItemId())) {
                changedItem = item;
                changedItemIndex = i;
                break;
            }
        }

        if (changedItem == null) {
            throw new BusinessException(ErrorCode.SCHEDULE_NOT_FOUND);
        }

        // 4. 실제 수면 시간 처리
        LocalTime actualEndTime;

        if (request.getActualDurationMinutes() != null) {
            // 실제 수면 시간(분)을 입력한 경우
            // 예: 13:00에 시작, 40분 잠 → 13:40에 종료
            log.info("실제 수면 시간: {}분 (예정: {}분)",
                    request.getActualDurationMinutes(),
                    changedItem.getDurationMinutes());

            // 실제 수면 시간 업데이트
            changedItem.updateDuration(request.getActualDurationMinutes());

            // 종료 시간 계산
            actualEndTime = changedItem.getScheduledTime().plusMinutes(request.getActualDurationMinutes());

        } else if (request.getActualEndTime() != null) {
            // 종료 시간을 직접 입력한 경우
            actualEndTime = request.getActualEndTime();

            // 실제 수면 시간 계산
            long actualDuration = java.time.temporal.ChronoUnit.MINUTES.between(
                    changedItem.getScheduledTime(), actualEndTime);
            changedItem.updateDuration((int) actualDuration);

        } else if (request.getActualStartTime() != null) {
            // 시작 시간을 변경한 경우
            LocalTime originalStart = changedItem.getScheduledTime();
            changedItem.updateScheduledTime(request.getActualStartTime());

            // 종료 시간 계산 (기존 duration 사용)
            if (changedItem.getDurationMinutes() != null) {
                actualEndTime = request.getActualStartTime().plusMinutes(changedItem.getDurationMinutes());
            } else {
                actualEndTime = request.getActualStartTime();
            }

        } else {
            throw new BusinessException(ErrorCode.INVALID_INPUT);
        }

        log.info("활동 종료 시간: {}", actualEndTime);

        // 5. 다음 활동부터 시간 재계산 (실제 종료 시간 기준)
        LocalTime currentTime = actualEndTime;

        // 6. 가이드라인 조회 (깨시 적용을 위해)
        int ageInMonths = baby.calculateAgeInMonths();
        AgeBasedSleepGuideline guideline = guidelineRepository.findClosestGuidelineByAge(ageInMonths)
                .orElse(null);

        // 7. 표준 스케줄 조회 (깨시 정보 확인용)
        List<com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem> standardItems =
                standardScheduleService.getStandardSchedule(ageInMonths);

        // 8. 이후 모든 아이템의 시간 재계산
        for (int i = changedItemIndex + 1; i < dailySchedule.getScheduleItems().size(); i++) {
            ScheduleItem item = dailySchedule.getScheduleItems().get(i);

            // 이전 활동과의 간격 계산 (표준 스케줄 기준)
            int intervalMinutes = calculateIntervalFromStandard(standardItems, changedItemIndex, i);

            // 간격을 적용하여 새 시간 계산
            if (intervalMinutes > 0) {
                // 표준 스케줄의 간격을 사용
                LocalTime adjustedTime = currentTime.plusMinutes(intervalMinutes);
                item.updateScheduledTime(adjustedTime);

                // 다음 활동을 위해 현재 시간 업데이트
                if (item.getDurationMinutes() != null) {
                    currentTime = adjustedTime.plusMinutes(item.getDurationMinutes());
                } else {
                    currentTime = adjustedTime;
                }

                log.debug("조정된 아이템 {}: {} (간격: {}분)",
                        item.getActivityType(), adjustedTime, intervalMinutes);
            } else {
                // 간격 정보가 없으면 기존 로직 사용 (단순 shift)
                // 이는 표준 스케줄에 없는 커스텀 아이템의 경우
                log.debug("표준 간격 없음 - 기존 위치 유지: {}", item.getActivityType());
            }
        }

        // 9. 과피로 방지 경고
        if (guideline != null && changedItem.getDurationMinutes() != null) {
            int totalWakeTime = calculateTotalWakeTime(dailySchedule, guideline);
            if (totalWakeTime > guideline.getWakeWindowMaxMinutes() * guideline.getNapCount()) {
                log.warn("경고: 아기의 깨시가 권장치를 초과했습니다. 총 깨시: {} 분", totalWakeTime);
            }
        }

        // 10. 저장
        dailySchedule = dailyScheduleRepository.save(dailySchedule);

        log.info("스케줄 동적 조정 완료 - 조정된 아이템: {}", changedItem.getActivityType());

        // 11. Response 생성
        return buildAutoScheduleResponse(dailySchedule, guideline);
    }

    /**
     * 표준 스케줄 기준으로 두 아이템 간의 간격 계산
     *
     * @param standardItems 표준 스케줄 아이템
     * @param fromIndex 시작 인덱스
     * @param toIndex 종료 인덱스
     * @return 간격 (분)
     */
    private int calculateIntervalFromStandard(
            List<com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem> standardItems,
            int fromIndex,
            int toIndex) {

        try {
            if (fromIndex >= 0 && toIndex < standardItems.size()) {
                // 표준 스케줄에서 해당 인덱스의 아이템 찾기
                com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem fromItem =
                        standardItems.get(fromIndex);
                com.dutyout.domain.schedule.service.StandardScheduleService.StandardScheduleItem toItem =
                        standardItems.get(toIndex);

                // 종료 시간 계산 (fromItem)
                LocalTime fromEnd = fromItem.getTime();
                if (fromItem.getDurationMinutes() != null && fromItem.getDurationMinutes() > 0) {
                    fromEnd = fromEnd.plusMinutes(fromItem.getDurationMinutes());
                }

                // 간격 계산
                long interval = java.time.temporal.ChronoUnit.MINUTES.between(fromEnd, toItem.getTime());
                return (int) interval;
            }
        } catch (Exception e) {
            log.warn("표준 스케줄 간격 계산 실패: {}", e.getMessage());
        }

        return 0; // 간격 정보 없음
    }

    /**
     * 총 깨시 계산
     */
    private int calculateTotalWakeTime(DailySchedule dailySchedule, AgeBasedSleepGuideline guideline) {
        int totalWakeTime = 0;
        for (ScheduleItem item : dailySchedule.getScheduleItems()) {
            if (item.getDurationMinutes() != null && !item.getActivityType().equals(ActivityType.BEDTIME)) {
                totalWakeTime += item.getDurationMinutes();
            }
        }
        return totalWakeTime;
    }
}
