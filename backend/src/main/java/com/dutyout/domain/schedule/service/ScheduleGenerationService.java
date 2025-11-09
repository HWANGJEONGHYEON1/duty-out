package com.dutyout.domain.schedule.service;

import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.repository.BabyRepository;
import com.dutyout.domain.schedule.entity.*;
import com.dutyout.domain.schedule.repository.DailyScheduleRepository;
import com.dutyout.domain.schedule.repository.ScheduleTemplateRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * 스케줄 자동 생성 서비스
 *
 * ⭐ 핵심 기능: 기상시간 입력 → 개월별 맞춤 스케줄 자동 생성
 *
 * 알고리즘:
 * 1. 아기의 (교정)월령 확인
 * 2. 해당 월령의 템플릿 로드
 * 3. Wake Window(깨어있는 시간) 기반 낮잠 시간 계산
 * 4. 낮잠 시간 + 낮잠 소요 시간 = 다음 활동 시작 시간
 * 5. 마지막 깨시 후 취침 시간 계산
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class ScheduleGenerationService {

    private final BabyRepository babyRepository;
    private final ScheduleTemplateRepository templateRepository;
    private final DailyScheduleRepository dailyScheduleRepository;

    /**
     * 스케줄 자동 생성 (핵심 메서드)
     *
     * @param babyId 아기 ID
     * @param scheduleDate 스케줄 날짜
     * @param wakeUpTime 기상 시간
     * @return 생성된 일일 스케줄
     */
    @Transactional
    public DailySchedule generateSchedule(Long babyId, LocalDate scheduleDate, LocalTime wakeUpTime) {
        log.info("스케줄 생성 시작: babyId={}, date={}, wakeUpTime={}", babyId, scheduleDate, wakeUpTime);

        // 1. 아기 정보 조회
        Baby baby = babyRepository.findById(babyId)
                .orElseThrow(() -> new BusinessException(ErrorCode.BABY_NOT_FOUND));

        // 2. 교정 월령 계산
        int ageInMonths = baby.calculateCorrectedAgeInMonths();
        log.debug("아기 월령: {} 개월", ageInMonths);

        // 3. 해당 월령의 템플릿 조회
        ScheduleTemplate template = templateRepository.findClosestTemplateByAge(ageInMonths)
                .orElseThrow(() -> new BusinessException(ErrorCode.TEMPLATE_NOT_FOUND));
        log.debug("템플릿 조회 완료: ageMonths={}, napCount={}", template.getAgeMonths(), template.getNapCount());

        // 4. 기존 스케줄이 있으면 삭제
        dailyScheduleRepository.findByBabyIdAndScheduleDate(babyId, scheduleDate)
                .ifPresent(dailyScheduleRepository::delete);

        // 5. 새 스케줄 생성
        DailySchedule dailySchedule = DailySchedule.builder()
                .babyId(babyId)
                .scheduleDate(scheduleDate)
                .wakeUpTime(wakeUpTime)
                .ageInMonths(ageInMonths)
                .build();

        // 6. 스케줄 아이템 생성
        List<ScheduleItem> scheduleItems = generateScheduleItems(wakeUpTime, template);
        dailySchedule.addScheduleItems(scheduleItems);

        // 7. 저장
        DailySchedule savedSchedule = dailyScheduleRepository.save(dailySchedule);
        log.info("스케줄 생성 완료: scheduleId={}, items={}", savedSchedule.getId(), scheduleItems.size());

        return savedSchedule;
    }

    /**
     * 스케줄 아이템 생성 (핵심 알고리즘)
     *
     * Wake Window 기반 시간 계산:
     * - 기상 → (깨시1) → 낮잠1 → (낮잠1 소요시간) → (깨시2) → 낮잠2 → ...
     */
    private List<ScheduleItem> generateScheduleItems(LocalTime wakeUpTime, ScheduleTemplate template) {
        List<ScheduleItem> items = new ArrayList<>();
        LocalTime currentTime = wakeUpTime;

        // 1. 기상
        items.add(createScheduleItem(ActivityType.WAKE_UP, currentTime, 0));
        log.debug("기상: {}", currentTime);

        // 2. 낮잠 스케줄 생성
        int napCount = template.getNapCount();
        List<Integer> wakeWindows = template.getWakeWindowsMinutes();
        List<Integer> napDurations = template.getNapDurationsMinutes();

        for (int i = 0; i < napCount; i++) {
            // 2-1. Wake Window 만큼 시간 경과 → 낮잠 시간
            int wakeWindowMinutes = i < wakeWindows.size() ? wakeWindows.get(i) : 120; // 기본 2시간
            currentTime = currentTime.plusMinutes(wakeWindowMinutes);

            // 2-2. 수유 시간 (낮잠 30분 전)
            LocalTime feedingTime = currentTime.minusMinutes(30);
            items.add(createScheduleItem(ActivityType.FEEDING, feedingTime, 20));

            // 2-3. 낮잠 시작
            ActivityType napType = getNapType(i);
            int napDuration = i < napDurations.size() ? napDurations.get(i) : 90; // 기본 1.5시간
            items.add(createScheduleItem(napType, currentTime, napDuration));
            log.debug("낮잠 {}: {} ({}분)", i + 1, currentTime, napDuration);

            // 2-4. 낮잠 종료 후 시간
            currentTime = currentTime.plusMinutes(napDuration);
        }

        // 3. 마지막 깨시 후 취침
        int lastWakeWindow = napCount < wakeWindows.size() ?
                wakeWindows.get(napCount) : 180; // 기본 3시간

        // 저녁 수유/이유식 (취침 1시간 전)
        LocalTime dinnerTime = currentTime.plusMinutes(lastWakeWindow - 60);
        items.add(createScheduleItem(ActivityType.FEEDING, dinnerTime, 30));

        // 목욕 (취침 30분 전)
        LocalTime bathTime = currentTime.plusMinutes(lastWakeWindow - 30);
        items.add(createScheduleItem(ActivityType.BATH, bathTime, 20));

        // 취침
        LocalTime bedTime = currentTime.plusMinutes(lastWakeWindow);
        items.add(createScheduleItem(ActivityType.BEDTIME, bedTime, 0));
        log.debug("취침: {}", bedTime);

        return items;
    }

    /**
     * 스케줄 아이템 생성 헬퍼
     */
    private ScheduleItem createScheduleItem(ActivityType activityType, LocalTime scheduledTime, int durationMinutes) {
        return ScheduleItem.builder()
                .activityType(activityType)
                .scheduledTime(scheduledTime)
                .durationMinutes(durationMinutes > 0 ? durationMinutes : null)
                .build();
    }

    /**
     * 낮잠 인덱스 → ActivityType 변환
     */
    private ActivityType getNapType(int napIndex) {
        return switch (napIndex) {
            case 0 -> ActivityType.NAP1;
            case 1 -> ActivityType.NAP2;
            case 2 -> ActivityType.NAP3;
            case 3 -> ActivityType.NAP4;
            default -> ActivityType.NAP1;
        };
    }

    /**
     * 스케줄 조회
     */
    public DailySchedule getSchedule(Long babyId, LocalDate scheduleDate) {
        return dailyScheduleRepository.findByBabyIdAndScheduleDateWithItems(babyId, scheduleDate)
                .orElseThrow(() -> new BusinessException(ErrorCode.SCHEDULE_NOT_FOUND));
    }

    /**
     * 스케줄 수정 (특정 항목 시간 변경 시 후속 일정 재계산)
     */
    @Transactional
    public DailySchedule updateScheduleItem(Long scheduleId, Long itemId, LocalTime newTime) {
        // TODO: 향후 구현
        // 특정 일정 변경 시 그 이후 일정들을 자동으로 재조정하는 로직
        throw new UnsupportedOperationException("아직 구현되지 않았습니다.");
    }
}
