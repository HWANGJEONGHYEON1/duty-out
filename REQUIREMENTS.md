# 🍼 아기 수면 교육 앱 요구사항 정의서

## 1. 프로젝트 개요
**앱 이름**: 육퇴의 정석
**목표**: 개월수별 맞춤형 수면 스케줄 관리 및 수면 패턴 분석 앱
**기반 자료**: Sleepbetter.Baby 수면 교육 방법론

---

## 2. 핵심 기능 요구사항 (MVP - Phase 1)

### 2.1 사용자 인증 및 프로필
| ID | 기능 | 세부 요구사항 | 우선순위 |
|---|---|---|---|
| AUTH-001 | 소셜 로그인 | 카카오, 구글 OAuth 2.0 로그인 | P0 |
| PROF-001 | 아기 프로필 생성 | 이름, 생년월일, 출생주수(교정월령 계산용) | P0 |
| PROF-002 | 월령 자동 계산 | 실제 개월수 및 교정월령 자동 계산 및 표시 | P0 |
| PROF-003 | 다중 프로필 | 최대 3명까지 형제자매 프로필 관리 | P2 |

### 2.2 일과 스케줄 관리 (핵심 기능)
| ID | 기능 | 세부 요구사항 | 우선순위 |
|---|---|---|---|
| SCH-001 | **기상시간 입력** | 아침 기상시간 입력 시 전체 일과 자동 생성 | P0 |
| SCH-002 | **개월별 템플릿** | 1~24개월 표준 스케줄 템플릿 제공<br>- 3~5개월: 낮잠 3-4회<br>- 6~8개월: 낮잠 2-3회<br>- 9~11개월: 낮잠 2회<br>- 12개월 이상: 낮잠 1-2회 | P0 |
| SCH-003 | **자동 일정 계산** | 깨어있는 시간(깨시) 기반 다음 일정 자동 계산<br>- 다음 낮잠 시간<br>- 수유/이유식 시간<br>- 취침 시간 | P0 |
| SCH-004 | **일정 수정** | 특정 일정 수정 시 후속 일정 자동 재계산 | P0 |
| SCH-005 | **드래그 수정** | 타임라인에서 일정 블록 드래그로 시간 조정 | P1 |

### 2.3 수면 기록 및 추적
| ID | 기능 | 세부 요구사항 | 우선순위 |
|---|---|---|---|
| REC-001 | 수면 기록 | 시작/종료 시간 원터치 기록 | P0 |
| REC-002 | 수면 타입 분류 | 낮잠1, 낮잠2, 낮잠3, 밤잠 구분 | P0 |
| REC-003 | 수면 품질 기록 | 잘잠/보통/못잠, 깨어난 횟수 | P1 |
| REC-004 | 수유/기저귀 기록 | 수유(모유/분유), 기저귀 교체 기록 | P1 |
| REC-005 | 메모 기능 | 특이사항 메모 (예: 뒤집기 시도, 이앓이) | P1 |

### 2.4 통계 및 분석
| ID | 기능 | 세부 요구사항 | 우선순위 |
|---|---|---|---|
| STAT-001 | **일간 통계** | - 총 수면 시간<br>- 낮잠 횟수 및 시간<br>- 밤잠 시간<br>- 깨어있던 총 시간 | P0 |
| STAT-002 | 주간 트렌드 | 7일간 수면 패턴 그래프 | P1 |
| STAT-003 | 월간 리포트 | 월별 수면 개선도 분석 | P2 |
| STAT-004 | 목표 달성률 | 권장 수면 시간 대비 달성률 | P1 |

### 2.5 알림 및 리마인더
| ID | 기능 | 세부 요구사항 | 우선순위 |
|---|---|---|---|
| NOTI-001 | 다음 일정 알림 | 낮잠/수유/취침 10분 전 푸시 알림 | P0 |
| NOTI-002 | 깨시 초과 경고 | 적정 깨어있는 시간 초과 시 알림 | P1 |
| NOTI-003 | 수면 기록 리마인더 | 기록 누락 시 알림 | P1 |

---

## 3. 기술 스택 (Spring Boot 기반)

```yaml
Backend:
  Framework: Spring Boot 3.2.x
  Language: Java 17 or Kotlin
  Database: PostgreSQL 15
  Cache: Redis 7.x

Authentication:
  Spring Security + OAuth 2.0
  JWT Token (Access: 15분, Refresh: 30일)

API:
  REST API
  SpringDoc OpenAPI 3 (Swagger)

Notification:
  Firebase Cloud Messaging (FCM)

Build & Deploy:
  Gradle
  Docker
  AWS EC2 or Cloud Run
```

---

## 4. 데이터 모델 (주요 엔티티)

### 4.1 Baby (아기 프로필)
```java
Baby {
  id: Long
  userId: Long
  name: String
  birthDate: LocalDate
  gestationalWeeks: Integer // 출생 주수
  gender: String
  profileImage: String
  createdAt: LocalDateTime
}
```

### 4.2 ScheduleTemplate (수면 스케줄 템플릿)
```java
ScheduleTemplate {
  id: Long
  ageMonths: Integer
  scheduleData: JSON // 시간별 활동 정보
  napCount: Integer
  totalSleepHours: Float
}
```

### 4.3 DailySchedule (일일 스케줄)
```java
DailySchedule {
  id: Long
  babyId: Long
  date: LocalDate
  wakeUpTime: LocalTime
  scheduleItems: List<ScheduleItem>
  modifiedAt: LocalDateTime
}
```

### 4.4 SleepRecord (수면 기록)
```java
SleepRecord {
  id: Long
  babyId: Long
  type: Enum(NAP1, NAP2, NAP3, NIGHT)
  startTime: LocalDateTime
  endTime: LocalDateTime
  quality: Enum(GOOD, NORMAL, BAD)
  wakeCount: Integer
  memo: String
}
```

---

## 5. 화면 구성 (UI/UX)

### 5.1 메인 대시보드
- **오늘의 스케줄 타임라인** (세로 스크롤)
- **다음 일정까지 카운트다운** (원형 프로그레스)
- **빠른 기록 버튼** (수면 시작/종료)

### 5.2 스케줄 편집 화면
- **기상시간 입력 → 전체 일과 자동 생성**
- **각 일정 탭하여 수정**
- **드래그로 시간 조정**

### 5.3 통계 화면
- **일/주/월 탭 전환**
- **수면 패턴 그래프**
- **평균값 비교**

---

## 6. GitHub 참고 프로젝트 기반 추가 기능

### 6.1 추가 고려사항
| 기능 | 설명 | 참고 프로젝트 |
|---|---|---|
| **적응형 스케줄** | 아기 컨디션에 따른 유연한 조정 | babynaps |
| **Apple Watch 연동** | 빠른 기록을 위한 워치앱 | maby |
| **수면 교육 타이머** | Ferber 방식 점진적 수면 훈련 | SleepTrainer |
| **백색소음 재생** | 수면 유도 사운드 | BabaTrack |

---

## 7. 개발 로드맵

### Phase 1 (2개월) - MVP
- **Week 1-2**: 프로젝트 셋업, 인증 구현
- **Week 3-4**: 아기 프로필, 월령 계산
- **Week 5-6**: 핵심 - 스케줄 자동 생성 및 수정
- **Week 7-8**: 수면 기록, 기본 통계

### Phase 2 (1개월) - 개선
- **Week 9-10**: 알림 시스템
- **Week 11-12**: 통계 고도화, UI 개선

### Phase 3 (1개월) - 확장
- 파트너 모드 (부모 공유)
- 데이터 내보내기
- 커뮤니티 기능

---

## 8. 성공 지표 (KPI)
- **DAU/MAU**: 일일/월간 활성 사용자
- **기록 지속률**: 7일 이상 연속 기록 비율
- **스케줄 준수율**: 생성된 스케줄 대비 실제 수면 시간
- **앱 리텐션**: 30일 후 잔존율

---

## 9. 핵심 알고리즘: 스케줄 자동 생성

> 이 프로젝트의 가장 중요한 기능은 **기상시간 입력 → 자동 스케줄 생성 → 수정 시 재계산** 로직입니다.

### 9.1 깨어있는 시간 (Wake Window) 기준표

| 월령 | 낮잠 횟수 | 깨시 1 | 깨시 2 | 깨시 3 | 깨시 4 | 총 수면시간 |
|------|----------|--------|--------|--------|--------|------------|
| 1-2개월 | 4-5회 | 1h | 1h | 1h | 1h | 14-17h |
| 3-4개월 | 3-4회 | 1.5h | 1.5h | 2h | 2h | 12-15h |
| 5-6개월 | 3회 | 2h | 2.5h | 2.5h | - | 12-14h |
| 7-8개월 | 2-3회 | 2.5h | 3h | 3h | - | 11-13h |
| 9-11개월 | 2회 | 3h | 3.5h | - | - | 11-12h |
| 12-18개월 | 1-2회 | 4h | 5h | - | - | 11-12h |

### 9.2 스케줄 생성 알고리즘 예시

```java
public DailySchedule generateSchedule(LocalTime wakeUpTime, int ageInMonths) {
    ScheduleTemplate template = getTemplateByAge(ageInMonths);

    List<ScheduleItem> items = new ArrayList<>();
    LocalTime currentTime = wakeUpTime;

    // 기상
    items.add(new ScheduleItem("기상", currentTime, WAKE_UP));

    // 낮잠 스케줄 생성
    for (int i = 0; i < template.getNapCount(); i++) {
        int wakeWindow = template.getWakeWindows().get(i);

        // 다음 낮잠 시간 = 현재 시간 + 깨어있는 시간
        currentTime = currentTime.plusHours(wakeWindow);

        items.add(new ScheduleItem("낮잠 " + (i + 1), currentTime, NAP));

        // 낮잠 시간 추가
        currentTime = currentTime.plusMinutes(template.getNapDuration(i));
    }

    // 취침
    int lastWakeWindow = template.getLastWakeWindow();
    currentTime = currentTime.plusHours(lastWakeWindow);
    items.add(new ScheduleItem("취침", currentTime, BEDTIME));

    return new DailySchedule(LocalDate.now(), wakeUpTime, items);
}
```

---

## 10. API 엔드포인트 (예시)

```
# 인증
POST   /api/v1/auth/kakao/login
POST   /api/v1/auth/google/login
POST   /api/v1/auth/refresh

# 아기 프로필
GET    /api/v1/babies
POST   /api/v1/babies
GET    /api/v1/babies/{id}
PUT    /api/v1/babies/{id}
DELETE /api/v1/babies/{id}

# 스케줄
GET    /api/v1/babies/{id}/schedules?date=2024-11-08
POST   /api/v1/babies/{id}/schedules/generate
PUT    /api/v1/babies/{id}/schedules/{scheduleId}

# 수면 기록
GET    /api/v1/babies/{id}/sleep-records?startDate=2024-11-01&endDate=2024-11-08
POST   /api/v1/babies/{id}/sleep-records
PUT    /api/v1/babies/{id}/sleep-records/{recordId}

# 통계
GET    /api/v1/babies/{id}/statistics/daily?date=2024-11-08
GET    /api/v1/babies/{id}/statistics/weekly?startDate=2024-11-01
GET    /api/v1/babies/{id}/statistics/monthly?yearMonth=2024-11
```

---

## 11. 보안 고려사항

1. **인증/인가**
   - JWT 토큰 기반 인증
   - Refresh Token을 통한 자동 갱신
   - 사용자별 아기 프로필 접근 권한 체크

2. **데이터 보호**
   - HTTPS 통신 필수
   - 민감한 정보 암호화 저장
   - SQL Injection 방지 (Prepared Statement)

3. **API 보안**
   - Rate Limiting (사용자당 분당 60회)
   - CORS 설정
   - XSS 방지

---

## 12. 테스트 전략

### 12.1 Backend (Spring Boot)
- **단위 테스트**: Service, Repository 레이어
- **통합 테스트**: API 엔드포인트
- **테스트 커버리지**: 최소 80% 이상

### 12.2 Frontend (Flutter)
- **단위 테스트**: BLoC, UseCase
- **위젯 테스트**: 주요 UI 컴포넌트
- **통합 테스트**: 전체 플로우 (로그인 → 스케줄 생성 → 기록)

---

## 부록: 참고 자료

- [Sleepbetter.Baby 수면 교육 방법론](https://sleepbetter.baby/)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Spring Boot Best Practices](https://www.baeldung.com/spring-boot-best-practices)

---

📅 최초 작성: 2024-11-08
📝 최종 수정: 2024-11-08
👥 작성자: Product Team
