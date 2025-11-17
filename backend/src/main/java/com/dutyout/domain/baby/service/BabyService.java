package com.dutyout.domain.baby.service;

import com.dutyout.common.exception.BusinessException;
import com.dutyout.common.exception.ErrorCode;
import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.repository.BabyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

/**
 * 아기 프로필 관리 서비스
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class BabyService {

    private static final int MAX_BABIES_PER_USER = 3;

    private final BabyRepository babyRepository;

    /**
     * 아기 프로필 생성
     */
    @Transactional
    public Baby createBaby(Baby baby) {
        // 최대 3명 제한 확인
        long count = babyRepository.countByUserId(baby.getUserId());
        if (count >= MAX_BABIES_PER_USER) {
            throw new BusinessException(ErrorCode.BABY_LIMIT_EXCEEDED);
        }

        log.info("아기 프로필 생성: userId={}, name={}", baby.getUserId(), baby.getName());
        return babyRepository.save(baby);
    }

    /**
     * 아기 프로필 조회
     */
    public Baby getBaby(Long babyId) {
        return babyRepository.findById(babyId)
                .orElseThrow(() -> new BusinessException(ErrorCode.BABY_NOT_FOUND));
    }

    /**
     * 사용자의 모든 아기 조회
     */
    public List<Baby> getBabiesByUserId(Long userId) {
        return babyRepository.findByUserId(userId);
    }

    /**
     * 아기 프로필 업데이트 (모든 정보)
     */
    @Transactional
    public Baby updateBaby(Long babyId, String name, String profileImage, LocalDate birthDate, Integer gestationalWeeks) {
        Baby baby = getBaby(babyId);
        baby.updateBabyInfo(name, profileImage, birthDate, gestationalWeeks);
        log.info("아기 프로필 업데이트: babyId={}, name={}", babyId, name);
        return baby;
    }

    /**
     * 아기 프로필 업데이트 (이름, 프로필 이미지만)
     */
    @Transactional
    public Baby updateBabyProfile(Long babyId, String name, String profileImage) {
        Baby baby = getBaby(babyId);
        baby.updateProfile(name, profileImage);
        log.info("아기 프로필 업데이트: babyId={}", babyId);
        return baby;
    }

    /**
     * 아기 프로필 삭제
     */
    @Transactional
    public void deleteBaby(Long babyId) {
        if (!babyRepository.existsById(babyId)) {
            throw new BusinessException(ErrorCode.BABY_NOT_FOUND);
        }
        babyRepository.deleteById(babyId);
        log.info("아기 프로필 삭제: babyId={}", babyId);
    }

    /**
     * 권한 확인 (해당 아기가 사용자의 것인지)
     */
    public void validateOwnership(Long babyId, Long userId) {
        Baby baby = getBaby(babyId);
        if (!baby.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.FORBIDDEN);
        }
    }
}
