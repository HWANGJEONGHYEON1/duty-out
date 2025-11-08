# 🍼 육퇴의 정석 (Duty Out)

> **아기 수면 교육 앱** - 기상시간 입력만으로 개월별 맞춤 스케줄을 자동 생성하는 똑똑한 육아 도우미

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.0-green.svg)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.2%2B-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 프로젝트 개요

**육퇴의 정석**은 부모들의 가장 큰 고민인 "아기 수면 교육"을 돕는 모바일 앱입니다.

### 🎯 핵심 가치

1. **자동 스케줄 생성**: 기상시간만 입력하면 아기 월령에 맞는 하루 일과를 자동으로 생성
2. **개월별 맞춤 템플릿**: Sleepbetter.Baby 방법론 기반 1~24개월 표준 스케줄
3. **간편한 기록**: 원터치로 수면 시작/종료 기록
4. **패턴 분석**: 일/주/월 수면 패턴 분석 및 개선 제안

### ⭐ 핵심 기능

| 기능 | 설명 |
|------|------|
| **스케줄 자동 생성** | 기상시간 입력 → AI 기반 하루 일과 자동 생성 |
| **Wake Window 계산** | 개월별 깨어있는 시간 기반 낮잠 시간 계산 |
| **수면 기록** | 낮잠/밤잠 원터치 기록 및 품질 평가 |
| **통계 대시보드** | 총 수면시간, 낮잠 횟수, 목표 달성률 분석 |
| **교정월령 지원** | 조산아의 경우 교정월령 기반 스케줄 제공 |

---

## 🏗 프로젝트 구조

```
duty-out/
├── backend/                 # Spring Boot 백엔드
│   ├── src/main/java/com/dutyout/
│   │   ├── domain/         # 도메인 계층 (Baby, Schedule, Sleep)
│   │   ├── application/    # 애플리케이션 계층 (UseCase, DTO)
│   │   ├── presentation/   # API 계층 (Controller)
│   │   ├── infrastructure/ # 인프라 계층 (Config, External)
│   │   └── common/         # 공통 (Exception, Response)
│   ├── build.gradle
│   └── README.md
│
├── mobile/                  # Flutter 모바일 앱
│   ├── lib/
│   │   ├── core/           # 공통 기능
│   │   ├── features/       # 기능별 모듈 (Clean Architecture)
│   │   │   ├── auth/
│   │   │   ├── baby/
│   │   │   ├── schedule/   # 스케줄 (핵심)
│   │   │   └── sleep_record/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
│
├── REQUIREMENTS.md          # 요구사항 정의서
├── DEVELOPMENT_GUIDELINES.md # 개발 가이드라인
└── README.md               # 이 파일
```

---

## 🚀 빠른 시작

### 사전 요구사항

- **Backend**: JDK 17, PostgreSQL 15 (또는 H2)
- **Mobile**: Flutter 3.2+, Dart 3.2+

### 1️⃣ 백엔드 실행

```bash
cd backend

# 개발 모드 (H2 데이터베이스)
./gradlew bootRun --args='--spring.profiles.active=dev'

# 프로덕션 모드 (PostgreSQL)
./gradlew bootRun
```

**API 문서**: http://localhost:8080/swagger-ui.html

### 2️⃣ 모바일 앱 실행

```bash
cd mobile

# 패키지 설치
flutter pub get

# 실행
flutter run
```

---

## 💡 핵심 알고리즘: 스케줄 자동 생성

```
[사용자 입력]
기상시간: 07:00

[시스템 처리]
1. 아기 월령 확인: 6개월 (교정월령 고려)
2. 템플릿 로드: 5-6개월 템플릿 (낮잠 3회)
3. Wake Window 기반 계산:
   - 기상 07:00
   - 깨시1 (2시간) → 낮잠1 09:00 (1.5시간)
   - 깨시2 (2.5시간) → 낮잠2 13:00 (1.5시간)
   - 깨시3 (2.5시간) → 낮잠3 17:00 (1시간)
   - 마지막 깨시 (3시간) → 취침 21:00

[출력]
완성된 하루 일과 스케줄 (수유, 목욕 시간 포함)
```

**백엔드 구현**: `backend/src/main/java/com/dutyout/domain/schedule/service/ScheduleGenerationService.java`

---

## 🛠 기술 스택

### Backend
| 분류 | 기술 |
|------|------|
| Framework | Spring Boot 3.2.0 |
| Language | Java 17 |
| Database | PostgreSQL 15, H2 (dev) |
| Cache | Redis |
| Auth | Spring Security + OAuth 2.0 + JWT |
| API Docs | Swagger (SpringDoc OpenAPI 3) |
| Build | Gradle |

### Mobile
| 분류 | 기술 |
|------|------|
| Framework | Flutter 3.2+ |
| Language | Dart 3.2+ |
| Architecture | Clean Architecture |
| State Management | BLoC Pattern (flutter_bloc) |
| Network | Dio + Retrofit |
| Local DB | Hive |
| DI | GetIt + Injectable |

---

## 📊 데이터베이스 ERD

```
┌─────────────┐       ┌──────────────────┐       ┌──────────────┐
│    users    │       │      babies      │       │sleep_records │
├─────────────┤       ├──────────────────┤       ├──────────────┤
│ id (PK)     │───┐   │ id (PK)          │───┬───│ id (PK)      │
│ email       │   │   │ user_id (FK)     │   │   │ baby_id (FK) │
│ name        │   └──→│ name             │   │   │ type         │
│ provider    │       │ birth_date       │   │   │ start_time   │
└─────────────┘       │ gestational_weeks│   │   │ end_time     │
                      └──────────────────┘   │   │ quality      │
                                             │   └──────────────┘
                      ┌──────────────────┐   │
                      │ daily_schedules  │   │
                      ├──────────────────┤   │
                      │ id (PK)          │───┘
                      │ baby_id (FK)     │
                      │ schedule_date    │
                      │ wake_up_time     │
                      │ age_in_months    │
                      └──────────────────┘
                              │
                              ↓
                      ┌──────────────────┐
                      │ schedule_items   │
                      ├──────────────────┤
                      │ id (PK)          │
                      │ daily_schedule_id│
                      │ activity_type    │
                      │ scheduled_time   │
                      └──────────────────┘
```

---

## 📱 주요 화면 (예정)

### 1. 메인 대시보드
- 오늘의 스케줄 타임라인 (세로 스크롤)
- 다음 일정까지 카운트다운 (원형 프로그레스)
- 빠른 수면 기록 버튼

### 2. 스케줄 편집 화면
- 기상시간 입력 → 자동 생성
- 드래그로 시간 조정
- 일정별 메모 추가

### 3. 통계 화면
- 일/주/월 탭 전환
- 수면 패턴 그래프
- 평균값 및 목표 달성률

---

## 📖 API 명세

### 아기 프로필
```http
POST   /api/v1/babies
GET    /api/v1/babies/{id}
GET    /api/v1/babies
DELETE /api/v1/babies/{id}
```

### 스케줄 (핵심)
```http
POST   /api/v1/babies/{id}/schedules/generate
GET    /api/v1/babies/{id}/schedules?date=2024-11-08
```

**요청 예시**:
```json
POST /api/v1/babies/1/schedules/generate
{
  "scheduleDate": "2024-11-08",
  "wakeUpTime": "07:00"
}
```

**응답 예시**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "babyId": 1,
    "scheduleDate": "2024-11-08",
    "wakeUpTime": "07:00",
    "ageInMonths": 6,
    "scheduleItems": [
      {
        "id": 1,
        "activityType": "WAKE_UP",
        "scheduledTime": "07:00",
        "durationMinutes": null
      },
      {
        "id": 2,
        "activityType": "NAP1",
        "scheduledTime": "09:00",
        "durationMinutes": 90
      }
      // ...
    ]
  },
  "timestamp": "2024-11-08T07:00:00"
}
```

---

## 🧪 테스트

### Backend
```bash
cd backend
./gradlew test                # 모든 테스트
./gradlew test --tests *BabyServiceTest  # 특정 테스트
./gradlew jacocoTestReport   # 커버리지
```

### Mobile
```bash
cd mobile
flutter test                 # 단위 테스트
flutter test --coverage      # 커버리지
```

---

## 🔐 환경 설정

### Backend (.env 또는 환경변수)
```bash
# OAuth
KAKAO_CLIENT_ID=your-kakao-client-id
KAKAO_CLIENT_SECRET=your-kakao-client-secret
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# JWT
JWT_SECRET=your-secret-key-32-characters-long

# Database
DB_URL=jdbc:postgresql://localhost:5432/dutyout
DB_USERNAME=dutyout
DB_PASSWORD=dutyout123
```

### Mobile (.env)
```bash
API_BASE_URL=http://localhost:8080
KAKAO_APP_KEY=your-kakao-app-key
```

---

## 📚 개발 문서

- [요구사항 정의서](REQUIREMENTS.md)
- [개발 가이드라인](DEVELOPMENT_GUIDELINES.md)
- [Backend README](backend/README.md)
- [Mobile README](mobile/README.md)

---

## 🗺 개발 로드맵

### Phase 1 (MVP) - 2개월
- [x] 프로젝트 셋업 및 구조 설계
- [x] 아기 프로필 관리
- [x] **스케줄 자동 생성 (핵심)**
- [x] 수면 기록 기본 기능
- [ ] OAuth 2.0 인증 구현
- [ ] 기본 UI/UX

### Phase 2 (개선) - 1개월
- [ ] 알림 시스템 (FCM)
- [ ] 통계 고도화 (그래프)
- [ ] UI/UX 개선

### Phase 3 (확장) - 1개월
- [ ] 파트너 모드 (부모 공유)
- [ ] 데이터 내보내기 (PDF, CSV)
- [ ] Apple Watch 연동
- [ ] 커뮤니티 기능

---

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**개발 규칙**: [DEVELOPMENT_GUIDELINES.md](DEVELOPMENT_GUIDELINES.md) 참고

---

## 📄 라이선스

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 개발팀

- **Product Owner**: [Your Name]
- **Backend**: [Your Name]
- **Mobile**: [Your Name]

---

## 📞 문의

- **Email**: your-email@example.com
- **Issues**: [GitHub Issues](https://github.com/yourusername/duty-out/issues)

---

## 🙏 참고 자료

- [Sleepbetter.Baby](https://sleepbetter.baby/) - 수면 교육 방법론
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Spring Boot Best Practices](https://www.baeldung.com/spring-boot-best-practices)

---

<p align="center">
  Made with ❤️ for tired parents
</p>

<p align="center">
  ⭐ Star this repo if you find it helpful!
</p>
