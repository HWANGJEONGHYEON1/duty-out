package com.dutyout.application.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UpdateBabyRequest {

    @Size(max = 50, message = "이름은 50자를 초과할 수 없습니다.")
    private String name;

    private String profileImage;
}
