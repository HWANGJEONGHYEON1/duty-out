package com.dutyout;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * 육퇴의 정석 - 아기 수면 교육 앱 백엔드
 *
 * 핵심 기능:
 * - 개월별 맞춤형 수면 스케줄 자동 생성
 * - 수면 패턴 기록 및 분석
 * - OAuth 2.0 기반 소셜 로그인
 *
 * 참고:
 * - Redis는 프로덕션 환경에서만 사용 (dev 환경에서는 자동 구성 제외)
 */
@SpringBootApplication(exclude = {RedisAutoConfiguration.class})
@EnableJpaAuditing
public class DutyOutApplication {

    public static void main(String[] args) {
        SpringApplication.run(DutyOutApplication.class, args);
    }
}
