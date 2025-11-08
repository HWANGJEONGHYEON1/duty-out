package com.dutyout.application.dto.request;

import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.entity.Gender;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
public class CreateBabyRequest {

    private Long userId; // Controller에서 인증 정보로 설정

    @NotBlank(message = "이름은 필수입니다.")
    @Size(max = 50, message = "이름은 50자를 초과할 수 없습니다.")
    private String name;

    @NotNull(message = "생년월일은 필수입니다.")
    @PastOrPresent(message = "생년월일은 미래일 수 없습니다.")
    private LocalDate birthDate;

    @Min(value = 22, message = "출생 주수는 22주 이상이어야 합니다.")
    @Max(value = 42, message = "출생 주수는 42주 이하여야 합니다.")
    private Integer gestationalWeeks;

    private Gender gender;

    private String profileImage;

    public Baby toEntity() {
        return Baby.builder()
                .userId(userId)
                .name(name)
                .birthDate(birthDate)
                .gestationalWeeks(gestationalWeeks)
                .gender(gender)
                .profileImage(profileImage)
                .build();
    }
}
