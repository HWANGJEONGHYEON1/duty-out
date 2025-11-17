package com.dutyout.presentation.controller;

import com.dutyout.application.dto.request.CreateBabyRequest;
import com.dutyout.application.dto.request.UpdateBabyRequest;
import com.dutyout.application.dto.response.BabyResponse;
import com.dutyout.common.response.ApiResponse;
import com.dutyout.domain.baby.entity.Baby;
import com.dutyout.domain.baby.service.BabyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 아기 프로필 관리 API
 */
@RestController
@RequestMapping("/api/v1/babies")
@RequiredArgsConstructor
@Tag(name = "Baby", description = "아기 프로필 관리 API")
public class BabyController {

    private final BabyService babyService;

    @PostMapping
    @Operation(summary = "아기 프로필 생성", description = "새로운 아기 프로필을 생성합니다.")
    public ResponseEntity<ApiResponse<BabyResponse>> createBaby(
            @Valid @RequestBody CreateBabyRequest request) {

        // TODO: 실제 인증 구현 시 @AuthenticationPrincipal로 userId 획득
        request.setUserId(1L); // 임시

        Baby baby = babyService.createBaby(request.toEntity());
        BabyResponse response = BabyResponse.from(baby);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    @GetMapping("/{babyId}")
    @Operation(summary = "아기 프로필 조회")
    public ResponseEntity<ApiResponse<BabyResponse>> getBaby(@PathVariable Long babyId) {
        Baby baby = babyService.getBaby(babyId);
        return ResponseEntity.ok(ApiResponse.success(BabyResponse.from(baby)));
    }

    @GetMapping
    @Operation(summary = "내 아기 목록 조회")
    public ResponseEntity<ApiResponse<List<BabyResponse>>> getMyBabies() {
        // TODO: 실제 인증 구현 시 userId 획득
        Long userId = 1L; // 임시

        List<BabyResponse> responses = babyService.getBabiesByUserId(userId).stream()
                .map(BabyResponse::from)
                .collect(Collectors.toList());

        return ResponseEntity.ok(ApiResponse.success(responses));
    }

    @PutMapping("/{babyId}")
    @Operation(summary = "아기 프로필 수정", description = "아기 정보(이름, 생년월일, 출생 주수, 성별, 프로필 이미지)를 수정합니다.")
    public ResponseEntity<ApiResponse<BabyResponse>> updateBaby(
            @PathVariable Long babyId,
            @Valid @RequestBody UpdateBabyRequest request) {

        Baby baby = babyService.updateBaby(
                babyId,
                request.getName(),
                request.getProfileImage(),
                request.getBirthDate(),
                request.getGestationalWeeks(),
                request.getGender()
        );
        BabyResponse response = BabyResponse.from(baby);

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @DeleteMapping("/{babyId}")
    @Operation(summary = "아기 프로필 삭제")
    public ResponseEntity<ApiResponse<Void>> deleteBaby(@PathVariable Long babyId) {
        babyService.deleteBaby(babyId);
        return ResponseEntity.ok(ApiResponse.success());
    }
}
