package com.dutyout.application.dto.response;

import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.entity.Gender;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
public class BabyResponse {

    private Long id;
    private Long userId;
    private String name;
    private LocalDate birthDate;
    private Integer gestationalWeeks;
    private Gender gender;
    private String profileImage;
    private Integer ageInMonths;
    private Integer correctedAgeInMonths;
    private LocalDateTime createdAt;

    public static BabyResponse from(Baby baby) {
        return BabyResponse.builder()
                .id(baby.getId())
                .userId(baby.getUserId())
                .name(baby.getName())
                .birthDate(baby.getBirthDate())
                .gestationalWeeks(baby.getGestationalWeeks())
                .gender(baby.getGender())
                .profileImage(baby.getProfileImage())
                .ageInMonths(baby.calculateAgeInMonths())
                .correctedAgeInMonths(baby.calculateCorrectedAgeInMonths())
                .createdAt(baby.getCreatedAt())
                .build();
    }
}
