# 육퇴의 정석 - Backend (Spring Boot)

아기 수면 교육 앱 백엔드 서버

## 🌟 핵심 기능

- **스케줄 자동 생성**: 기상시간 입력 → 개월별 맞춤 스케줄 자동 생성
- **수면 기록 관리**: 낮잠/밤잠 기록 및 통계
- **OAuth 2.0 인증**: 카카오, 구글 소셜 로그인

## 🛠 기술 스택

- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Database**: PostgreSQL 15 / H2 (dev)
- **Cache**: Redis
- **Auth**: Spring Security + OAuth 2.0 + JWT
- **API Docs**: Swagger (SpringDoc OpenAPI 3)
- **Build**: Gradle

## 📁 프로젝트 구조

```
backend/
├── src/main/java/com/dutyout/
│   ├── domain/              # 도메인 계층
│   │   ├── baby/           # 아기 프로필
│   │   ├── sleep/          # 수면 기록
│   │   ├── schedule/       # 스케줄 (핵심)
│   │   └── user/           # 사용자/인증
│   ├── application/        # 애플리케이션 계층
│   │   └── dto/           # DTO (Request/Response)
│   ├── presentation/       # 프레젠테이션 계층
│   │   └── controller/    # REST API Controllers
│   ├── infrastructure/     # 인프라 계층
│   │   └── config/        # 설정
│   └── common/            # 공통 (Exception, Response 등)
└── src/main/resources/
    ├── application.yml    # 메인 설정
    ├── application-dev.yml # 개발 설정
    └── data.sql          # 초기 데이터 (스케줄 템플릿)
```

## 🚀 시작하기

### 사전 요구사항

- JDK 17
- PostgreSQL 15 (또는 H2로 개발)
- Redis (선택)

### 실행 방법

```bash
# 1. 프로젝트 클론
cd backend

# 2. 빌드
./gradlew build

# 3. 실행 (개발 모드 - H2 사용)
./gradlew bootRun --args='--spring.profiles.active=dev'

# 또는 프로덕션 모드 (PostgreSQL 필요)
./gradlew bootRun
```

### API 문서

서버 실행 후 Swagger UI 접속:
```
http://localhost:8080/swagger-ui.html
```

## 📊 주요 API 엔드포인트

### 아기 프로필
- `POST /api/v1/babies` - 아기 생성
- `GET /api/v1/babies/{id}` - 아기 조회
- `GET /api/v1/babies` - 내 아기 목록
- `DELETE /api/v1/babies/{id}` - 아기 삭제

### 스케줄 (핵심)
- `POST /api/v1/babies/{id}/schedules/generate` - **스케줄 자동 생성**
- `GET /api/v1/babies/{id}/schedules?date=2024-11-08` - 스케줄 조회

### 수면 기록
- `POST /api/v1/babies/{id}/sleep-records` - 수면 기록 시작
- `PUT /api/v1/babies/{id}/sleep-records/{recordId}/end` - 수면 종료
- `GET /api/v1/babies/{id}/sleep-records?date=2024-11-08` - 수면 기록 조회

## 🧪 테스트

```bash
# 모든 테스트 실행
./gradlew test

# 테스트 커버리지
./gradlew jacocoTestReport
```

## 🗄 데이터베이스 설정

### PostgreSQL (프로덕션)
```sql
CREATE DATABASE dutyout;
CREATE USER dutyout WITH PASSWORD 'dutyout123';
GRANT ALL PRIVILEGES ON DATABASE dutyout TO dutyout;
```

### 초기 데이터
`src/main/resources/data.sql`에 개월별 스케줄 템플릿 데이터가 포함되어 있습니다.

## 🔐 환경 변수

```bash
# OAuth 2.0
KAKAO_CLIENT_ID=your-kakao-client-id
KAKAO_CLIENT_SECRET=your-kakao-client-secret
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# JWT
JWT_SECRET=your-secret-key-minimum-32-characters-long

# Database
DB_URL=jdbc:postgresql://localhost:5432/dutyout
DB_USERNAME=dutyout
DB_PASSWORD=dutyout123
```

## 📝 개발 가이드

- [개발 가이드라인](../DEVELOPMENT_GUIDELINES.md) 참고
- Clean Code & SOLID 원칙 준수
- 모든 API는 `ApiResponse<T>` 형식으로 응답
- 예외는 `GlobalExceptionHandler`에서 처리

## 🏗 핵심 알고리즘: 스케줄 자동 생성

`ScheduleGenerationService.java` 참고

1. 아기 월령 확인 (교정월령 고려)
2. 해당 월령 템플릿 로드
3. Wake Window 기반 낮잠 시간 계산
4. 수유/목욕 시간 자동 배치
5. 마지막 깨시 후 취침 시간 계산

## 📄 라이선스

MIT License
