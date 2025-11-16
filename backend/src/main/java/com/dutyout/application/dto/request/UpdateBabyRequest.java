package com.dutyout.application.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 아기 정보 수정 요청 DTO
 *
 * 이름과 프로필 이미지만 수정할 때 사용합니다.
 * 생년월일, 출생주수 등은 수정할 수 없습니다.
 */
@Getter
@Setter
@NoArgsConstructor
public class UpdateBabyRequest {

    @NotBlank(message = "이름은 필수입니다.")
    @Size(max = 50, message = "이름은 50자를 초과할 수 없습니다.")
    private String name;

    private String profileImage;
}
