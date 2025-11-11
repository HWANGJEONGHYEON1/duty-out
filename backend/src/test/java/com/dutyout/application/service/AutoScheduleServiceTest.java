package com.dutyout.application.service;

import com.dutyout.application.dto.request.GenerateAutoScheduleRequest;
import com.dutyout.application.dto.response.AutoScheduleResponse;
import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.entity.Gender;
import com.dutyout.domain.baby.repository.BabyRepository;
import com.dutyout.domain.schedule.entity.AgeBasedSleepGuideline;
import com.dutyout.domain.schedule.entity.DailySchedule;
import com.dutyout.domain.schedule.repository.AgeBasedSleepGuidelineRepository;
import com.dutyout.domain.schedule.repository.DailyScheduleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;

/**
 * AutoScheduleService 단위 테스트
 *
 * Testing Strategy:
 * - Mockito를 사용한 의존성 격리
 * - 개월수별 가이드라인 기반 스케줄 생성 검증
 * - 낮잠, 수유, 취침 시간 계산 로직 검증
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("AutoScheduleService 단위 테스트")
class AutoScheduleServiceTest {

    @Mock
    private BabyRepository babyRepository;

    @Mock
    private AgeBasedSleepGuidelineRepository guidelineRepository;

    @Mock
    private DailyScheduleRepository dailyScheduleRepository;

    @InjectMocks
    private AutoScheduleService autoScheduleService;

    private Baby baby;
    private AgeBasedSleepGuideline guideline;
    private GenerateAutoScheduleRequest request;

    @BeforeEach
    void setUp() {
        // 3개월 아기
        baby = Baby.builder()
                .userId(1L)
                .name("테스트베이비")
                .birthDate(LocalDate.now().minusMonths(3))
                .gestationalWeeks(39)
                .gender(Gender.MALE)
                .build();

        // 3개월 가이드라인
        guideline = AgeBasedSleepGuideline.builder()
                .ageInMonths(3)
                .wakeWindowMinMinutes(90)
                .wakeWindowMaxMinutes(120)
                .napCount(4)
                .maxTotalNapMinutes(240) // 4시간
                .nightSleepMinMinutes(600) // 10시간
                .nightSleepMaxMinutes(720) // 12시간
                .recommendedBedtimeHour(19)
                .recommendedBedtimeMinute(30)
                .firstWakeWindowMinutes(90)
                .middleWakeWindowMinutes(105)
                .lastWakeWindowMinutes(120)
                .feedingAmountMinMl(120)
                .feedingAmountMaxMl(180)
                .breastfeedingCountMin(7)
                .breastfeedingCountMax(9)
                .formulaFeedingCountMin(5)
                .formulaFeedingCountMax(6)
                .feedingIntervalMinutes(180)
                .description("3개월 테스트 가이드라인")
                .build();

        request = GenerateAutoScheduleRequest.builder()
                .wakeUpTime(LocalTime.of(7, 0))
                .isBreastfeeding(true)
                .build();
    }

    @Test
    @DisplayName("자동 스케줄 생성 성공 - 3개월 아기")
    void generateAutoSchedule_Success_3MonthBaby() {
        // given
        given(babyRepository.findById(1L)).willReturn(Optional.of(baby));
        given(guidelineRepository.findClosestGuidelineByAge(3)).willReturn(Optional.of(guideline));
        given(dailyScheduleRepository.findByBabyIdAndScheduleDate(any(), any())).willReturn(Optional.empty());
        given(dailyScheduleRepository.save(any(DailySchedule.class))).willAnswer(invocation -> {
            DailySchedule schedule = invocation.getArgument(0);
            return schedule;
        });

        // when
        AutoScheduleResponse response = autoScheduleService.generateAutoSchedule(1L, request);

        // then
        assertThat(response).isNotNull();
        assertThat(response.getAgeInMonths()).isEqualTo(3);
        assertThat(response.getWakeUpTime()).isEqualTo(LocalTime.of(7, 0));
        assertThat(response.getTotalNapCount()).isEqualTo(4); // 3개월 = 4회 낮잠
        assertThat(response.getItems()).isNotEmpty();

        // 스케줄 아이템 검증
        assertThat(response.getItems()).anyMatch(item ->
                item.getActivityType().name().equals("WAKE_UP"));
        assertThat(response.getItems()).anyMatch(item ->
                item.getActivityType().name().equals("BEDTIME"));

        verify(dailyScheduleRepository, times(1)).save(any(DailySchedule.class));
    }

    @Test
    @DisplayName("자동 스케줄 생성 - 낮잠 시간 계산 검증")
    void generateAutoSchedule_NapTimeCalculation() {
        // given
        given(babyRepository.findById(1L)).willReturn(Optional.of(baby));
        given(guidelineRepository.findClosestGuidelineByAge(3)).willReturn(Optional.of(guideline));
        given(dailyScheduleRepository.findByBabyIdAndScheduleDate(any(), any())).willReturn(Optional.empty());
        given(dailyScheduleRepository.save(any(DailySchedule.class))).willAnswer(invocation -> invocation.getArgument(0));

        // when
        AutoScheduleResponse response = autoScheduleService.generateAutoSchedule(1L, request);

        // then
        // 첫 번째 낮잠은 기상 후 약 90분 후에 시작해야 함
        var firstNap = response.getItems().stream()
                .filter(item -> item.getActivityType().name().equals("NAP1"))
                .findFirst()
                .orElseThrow();

        LocalTime expectedFirstNapTime = request.getWakeUpTime().plusMinutes(90);
        assertThat(firstNap.getStartTime()).isEqualTo(expectedFirstNapTime);

        // 낮잠 지속 시간은 총 낮잠 시간을 낮잠 횟수로 나눈 값
        int expectedNapDuration = guideline.getMaxTotalNapMinutes() / guideline.getNapCount();
        assertThat(firstNap.getDurationMinutes()).isEqualTo(expectedNapDuration);
    }

    @Test
    @DisplayName("자동 스케줄 생성 - 수유 횟수 검증")
    void generateAutoSchedule_FeedingCount() {
        // given
        given(babyRepository.findById(1L)).willReturn(Optional.of(baby));
        given(guidelineRepository.findClosestGuidelineByAge(3)).willReturn(Optional.of(guideline));
        given(dailyScheduleRepository.findByBabyIdAndScheduleDate(any(), any())).willReturn(Optional.empty());
        given(dailyScheduleRepository.save(any(DailySchedule.class))).willAnswer(invocation -> invocation.getArgument(0));

        // when
        AutoScheduleResponse response = autoScheduleService.generateAutoSchedule(1L, request);

        // then
        long feedingCount = response.getItems().stream()
                .filter(item -> item.getActivityType().name().equals("FEEDING"))
                .count();

        // 수유 횟수는 낮잠 횟수와 비슷하거나 조금 많아야 함
        assertThat(feedingCount).isGreaterThanOrEqualTo(guideline.getNapCount());
    }

    @Test
    @DisplayName("자동 스케줄 생성 - 취침 시간 계산 검증")
    void generateAutoSchedule_BedtimeCalculation() {
        // given
        given(babyRepository.findById(1L)).willReturn(Optional.of(baby));
        given(guidelineRepository.findClosestGuidelineByAge(3)).willReturn(Optional.of(guideline));
        given(dailyScheduleRepository.findByBabyIdAndScheduleDate(any(), any())).willReturn(Optional.empty());
        given(dailyScheduleRepository.save(any(DailySchedule.class))).willAnswer(invocation -> invocation.getArgument(0));

        // when
        AutoScheduleResponse response = autoScheduleService.generateAutoSchedule(1L, request);

        // then
        assertThat(response.getBedtime()).isNotNull();

        // 취침 시간은 권장 시간대(19:00~20:00) 근처여야 함
        int bedtimeHour = response.getBedtime().getHour();
        assertThat(bedtimeHour).isBetween(18, 21);
    }
}
