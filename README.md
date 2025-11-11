# 육퇴의 정석 (Duty-Out) - 아기 수면 스케줄러

아기의 개월 수에 따른 자동 수면/수유 스케줄 생성 및 커뮤니티 기능을 제공하는 앱입니다.

## 목차

- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [프로젝트 구조](#프로젝트-구조)
- [백엔드 설정 및 실행](#백엔드-설정-및-실행)
- [Flutter 앱 설정 및 실행](#flutter-앱-설정-및-실행)
- [API 문서](#api-문서)
- [테스트](#테스트)
- [문제 해결](#문제-해결)

## 주요 기능

### 1. 자동 스케줄 생성 ⏰
- **개월별 맞춤 가이드라인**: 1~48개월 아기에 대한 전문가 수면 가이드라인 기반
- **기상 시간 기반 자동 생성**: 기상 시간만 입력하면 하루 전체 스케줄 자동 생성
- **Wake Window 계산**: 첫 번째 낮잠은 짧게, 마지막 낮잠은 길게 자동 조정
- **낮잠 횟수 및 시간**: 개월 수에 따라 낮잠 횟수(1~4회)와 총 낮잠 시간 자동 계산
- **수유 스케줄**: 모유/분유 여부에 따른 수유 시간 포함

### 2. 수유 기록 관리 🍼
- 수유 시간, 수유량, 수유 유형(모유/분유/이유식) 기록
- 일일 총 수유량 통계
- 수유 기록 조회, 수정, 삭제

### 3. 커뮤니티 💬
- **익명 게시판**: Blind 스타일의 익명 커뮤니티
- 게시글 작성, 수정, 삭제, 좋아요
- 댓글 작성, 수정, 삭제
- 검색 및 페이징 지원

## 기술 스택

### 백엔드
- **Java 17**
- **Spring Boot 3.2.0**
- **Clean Architecture + DDD** - 도메인 주도 설계
- **Spring Security + JWT** - 인증/인가
- **PostgreSQL** - 프로덕션 DB
- **H2 Database** - 개발/테스트 DB
- **Gradle 8.x** - 빌드 도구
- **JUnit 5 + Mockito** - 단위 테스트
- **@DataJpaTest** - H2 통합 테스트

### 프론트엔드
- **Flutter 3.0+**
- **Dart 3.0+**
- **Provider** - 상태 관리
- **Dio** - HTTP 클라이언트 (자동 JWT 주입, 401 자동 갱신)
- **flutter_secure_storage** - JWT 토큰 안전 저장
- **shared_preferences** - 사용자 설정 저장

## 프로젝트 구조

```
duty-out/
├── backend/                      # Spring Boot 백엔드
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/dutyout/
│   │   │   │   ├── domain/           # 도메인 계층 (DDD)
│   │   │   │   │   ├── auth/         # 인증 도메인
│   │   │   │   │   │   ├── entity/User.java
│   │   │   │   │   │   └── repository/UserRepository.java
│   │   │   │   │   ├── baby/         # 아기 도메인
│   │   │   │   │   │   ├── entity/Baby.java
│   │   │   │   │   │   └── repository/BabyRepository.java
│   │   │   │   │   ├── feeding/      # 수유 기록 도메인
│   │   │   │   │   │   ├── entity/FeedingRecord.java
│   │   │   │   │   │   └── repository/FeedingRecordRepository.java
│   │   │   │   │   ├── schedule/     # 스케줄 도메인 (핵심)
│   │   │   │   │   │   ├── entity/AgeBasedSleepGuideline.java
│   │   │   │   │   │   ├── entity/DailySchedule.java
│   │   │   │   │   │   └── repository/...
│   │   │   │   │   └── community/    # 커뮤니티 도메인
│   │   │   │   │       ├── entity/CommunityPost.java
│   │   │   │   │       ├── entity/Comment.java
│   │   │   │   │       └── repository/...
│   │   │   │   ├── application/      # 애플리케이션 계층
│   │   │   │   │   ├── service/
│   │   │   │   │   │   ├── AuthService.java
│   │   │   │   │   │   ├── AutoScheduleService.java  # 핵심 로직
│   │   │   │   │   │   ├── FeedingRecordService.java
│   │   │   │   │   │   └── CommunityService.java
│   │   │   │   │   └── dto/
│   │   │   │   ├── infrastructure/   # 인프라 계층
│   │   │   │   │   ├── repository/   # JPA 구현체
│   │   │   │   │   ├── security/
│   │   │   │   │   │   ├── JwtUtil.java
│   │   │   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   │   │   └── SecurityConfig.java
│   │   │   │   │   └── data/
│   │   │   │   │       └── SleepGuidelineDataLoader.java  # 초기 데이터
│   │   │   │   └── presentation/     # 프레젠테이션 계층
│   │   │   │       └── controller/
│   │   │   │           ├── AuthController.java
│   │   │   │           ├── BabyController.java
│   │   │   │           ├── FeedingRecordController.java
│   │   │   │           └── CommunityController.java
│   │   │   └── resources/
│   │   │       ├── application.yml
│   │   │       ├── application-dev.yml
│   │   │       ├── application-test.yml
│   │   │       └── application-prod.yml
│   │   └── test/                     # 테스트
│   │       └── java/com/dutyout/
│   │           ├── application/service/  # 단위 테스트 (Mockito)
│   │           └── infrastructure/       # 통합 테스트 (H2)
│   ├── build.gradle
│   └── gradlew
│
├── mobile/                       # Flutter 앱
│   ├── lib/
│   │   ├── config/
│   │   │   └── api_config.dart       # API URL 설정
│   │   ├── models/                   # 데이터 모델
│   │   │   ├── schedule_item.dart
│   │   │   ├── community_post.dart
│   │   │   ├── comment.dart
│   │   │   └── feeding_record.dart
│   │   ├── providers/                # Provider 상태 관리
│   │   │   ├── schedule_provider.dart
│   │   │   ├── community_provider.dart
│   │   │   └── feeding_provider.dart
│   │   ├── screens/                  # UI 화면
│   │   │   ├── home_screen.dart
│   │   │   ├── schedule_screen.dart
│   │   │   ├── community_screen.dart
│   │   │   └── post_detail_screen.dart
│   │   ├── services/                 # API 서비스
│   │   │   ├── api_client.dart       # Dio + 인터셉터
│   │   │   ├── auth_api_service.dart
│   │   │   ├── schedule_api_service.dart
│   │   │   ├── feeding_api_service.dart
│   │   │   ├── community_api_service.dart
│   │   │   └── storage_service.dart  # 토큰 저장
│   │   └── main.dart
│   └── pubspec.yaml
│
└── README.md
```

## 백엔드 설정 및 실행

### 1. 사전 요구사항

#### Java 17 설치

**Mac:**
```bash
# Homebrew로 설치
brew install openjdk@17

# PATH 설정
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 확인
java -version
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install openjdk-17-jdk

java -version
```

**Windows:**
- [Oracle JDK 17](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html) 또는 [OpenJDK 17](https://adoptium.net/) 다운로드 및 설치

### 2. 데이터베이스 설정

#### ✅ Option A: H2 Database (개발/테스트용 - 권장)

**가장 빠르고 간단합니다!** 별도 설정 없이 바로 실행 가능합니다.
- 인메모리 DB로 자동 생성
- 애플리케이션 재시작 시 데이터 초기화
- `application-dev.yml`에 이미 설정됨

#### Option B: PostgreSQL (프로덕션용)

**Mac:**
```bash
# PostgreSQL 설치
brew install postgresql@15
brew services start postgresql@15

# 데이터베이스 생성
psql postgres
```

**PostgreSQL 콘솔에서:**
```sql
CREATE DATABASE dutyout;
CREATE USER dutyout_user WITH PASSWORD 'dutyout123';
GRANT ALL PRIVILEGES ON DATABASE dutyout TO dutyout_user;
\q
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql-15

# PostgreSQL 시작
sudo systemctl start postgresql
sudo systemctl enable postgresql

# 데이터베이스 생성
sudo -u postgres psql
```

**PostgreSQL 콘솔에서:**
```sql
CREATE DATABASE dutyout;
CREATE USER dutyout_user WITH PASSWORD 'dutyout123';
GRANT ALL PRIVILEGES ON DATABASE dutyout TO dutyout_user;
\q
```

### 3. 백엔드 환경 설정

#### 개발 환경 (H2 사용 - 권장)

`backend/src/main/resources/application-dev.yml`이 이미 설정되어 있습니다:

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:dutyout
    driver-class-name: org.h2.Driver
    username: sa
    password:
  h2:
    console:
      enabled: true
      path: /h2-console
  jpa:
    hibernate:
      ddl-auto: create-drop  # 자동으로 테이블 생성
    show-sql: true           # SQL 쿼리 로그 출력
```

#### 프로덕션 환경 (PostgreSQL 사용)

`backend/src/main/resources/application-prod.yml` 수정:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/dutyout
    username: dutyout_user
    password: dutyout123  # 실제 비밀번호로 변경
  jpa:
    hibernate:
      ddl-auto: update      # 프로덕션에서는 validate 권장
    show-sql: false
```

#### JWT 시크릿 키 설정 (중요!)

`backend/src/main/resources/application.yml`:

```yaml
jwt:
  secret: your-very-secure-secret-key-minimum-32-characters-long-please-change-this
  access-token-validity: 3600000    # 1시간 (밀리초)
  refresh-token-validity: 604800000 # 7일 (밀리초)
```

**⚠️ 보안 주의**: 프로덕션에서는 환경 변수로 시크릿 키를 관리하세요:
```bash
export JWT_SECRET="your-production-secret-key-very-long-and-secure"
```

### 4. 백엔드 빌드 및 실행

프로젝트 루트에서:

```bash
cd backend
```

#### 방법 1: Gradle Wrapper 사용 (권장)

**개발 환경 실행 (H2 사용):**
```bash
# Windows
gradlew.bat bootRun --args="--spring.profiles.active=dev"

# Mac/Linux
./gradlew bootRun --args='--spring.profiles.active=dev'
```

**빌드 후 실행:**
```bash
# 빌드 (테스트 포함)
./gradlew clean build

# 빌드 (테스트 제외 - 빠름)
./gradlew clean build -x test

# JAR 파일 실행
java -jar build/libs/duty-out-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev
```

**프로덕션 환경 실행 (PostgreSQL 사용):**
```bash
./gradlew bootRun --args='--spring.profiles.active=prod'
```

#### 방법 2: IDE에서 실행

**IntelliJ IDEA:**
1. `backend` 폴더를 IntelliJ에서 Open
2. `src/main/java/com/dutyout/DutyOutApplication.java` 열기
3. 좌측의 실행 버튼 클릭 또는 `Shift + F10`
4. Run Configuration 설정:
   - **VM Options**: `-Dspring.profiles.active=dev`
   - **Program Arguments**: `--spring.profiles.active=dev`

**Eclipse:**
1. File > Import > Gradle > Existing Gradle Project
2. `backend` 폴더 선택
3. Run As > Spring Boot App
4. Run Configurations에서 환경 변수 설정

### 5. 백엔드 실행 확인

서버가 정상 실행되면:

```
Started DutyOutApplication in 5.123 seconds (JVM running for 5.789)
```

#### 확인할 URL:

- **API Base URL**: `http://localhost:8080`
- **H2 Console** (dev 프로필 사용 시): `http://localhost:8080/h2-console`
  - JDBC URL: `jdbc:h2:mem:dutyout`
  - Username: `sa`
  - Password: (비어있음)

#### Health Check:

```bash
curl http://localhost:8080/actuator/health

# 응답
{"status":"UP"}
```

#### 로그 확인:

초기 데이터 로드 확인:
```
INFO  c.d.i.d.SleepGuidelineDataLoader : ✅ 수면 가이드라인 데이터 로드 시작...
INFO  c.d.i.d.SleepGuidelineDataLoader : ✅ 수면 가이드라인 데이터 로드 완료: 13개
```

13개월치 수면 가이드라인 데이터가 자동으로 로드됩니다:
- 1, 2, 3, 4, 5, 6, 7, 8, 12, 18, 24, 36, 48개월

### 6. 테스트 실행 (선택 사항)

```bash
cd backend

# 전체 테스트 실행
./gradlew test

# 특정 테스트만 실행
./gradlew test --tests AutoScheduleServiceTest

# 테스트 커버리지 리포트
./gradlew test jacocoTestReport
open build/reports/jacoco/test/html/index.html  # Mac
```

## Flutter 앱 설정 및 실행

### 1. 사전 요구사항

#### Flutter SDK 설치

**Mac:**
```bash
# Homebrew로 설치 (권장)
brew install --cask flutter

# Flutter 버전 확인
flutter --version

# 환경 진단
flutter doctor
```

**Windows:**
1. [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) 다운로드
2. ZIP 압축 해제 (예: `C:\flutter`)
3. 환경 변수 PATH에 `C:\flutter\bin` 추가
4. `flutter doctor` 실행

**Ubuntu/Debian:**
```bash
# Snap으로 설치
sudo snap install flutter --classic

flutter doctor
```

#### Android Studio (Android 개발)

1. [Android Studio](https://developer.android.com/studio) 설치
2. Android Studio 실행 > SDK Manager
3. 필수 설치:
   - Android SDK Platform (최신)
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android Emulator

#### Xcode (iOS 개발 - Mac만 해당)

```bash
# Mac App Store에서 Xcode 설치

# Command Line Tools 설치
xcode-select --install

# CocoaPods 설치
sudo gem install cocoapods
```

### 2. Flutter 패키지 설치

```bash
cd mobile

# 패키지 설치
flutter pub get
```

설치되는 주요 패키지:
- `provider: ^6.1.1` - 상태 관리
- `dio: ^5.4.0` - HTTP 클라이언트
- `flutter_secure_storage: ^9.0.0` - JWT 토큰 저장
- `shared_preferences: ^2.2.2` - 설정 저장
- `intl: ^0.18.1` - 날짜/시간 포맷

### 3. API URL 설정 (중요!)

백엔드 서버 주소를 설정해야 Flutter 앱이 API와 통신할 수 있습니다.

#### 현재 설정 확인

`mobile/lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',  // 기본값
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

#### 환경별 설정

| 환경 | API URL | 설명 |
|------|---------|------|
| **iOS 시뮬레이터** | `http://localhost:8080` | Mac의 localhost와 동일 |
| **Android 에뮬레이터** | `http://10.0.2.2:8080` | 에뮬레이터의 특수 IP |
| **실제 디바이스** | `http://192.168.0.10:8080` | 컴퓨터의 로컬 IP |

#### iOS 시뮬레이터 (기본값 그대로 사용)

```bash
flutter run
```

#### Android 에뮬레이터

**Option A: 환경 변수로 실행**
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

**Option B: 코드 수정** (`mobile/lib/config/api_config.dart`):
```dart
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080',  // Android 에뮬레이터용
);
```

#### 실제 디바이스 (Wi-Fi 동일 네트워크 필요)

**1단계: 컴퓨터의 IP 주소 확인**

Mac/Linux:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1

# 출력 예시:
# inet 192.168.0.10 netmask 0xffffff00 broadcast 192.168.0.255
```

Windows:
```bash
ipconfig

# 출력에서 IPv4 주소 확인
```

**2단계: 백엔드 서버 외부 접속 허용**

`backend/src/main/resources/application-dev.yml`:
```yaml
server:
  address: 0.0.0.0  # 모든 네트워크 인터페이스에서 접속 허용
  port: 8080
```

백엔드 서버 재시작!

**3단계: Flutter 앱 실행**
```bash
# 예시: 컴퓨터 IP가 192.168.0.10인 경우
flutter run --dart-define=API_URL=http://192.168.0.10:8080
```

**4단계: 방화벽 확인**

Mac:
```bash
# 시스템 설정 > 네트워크 > 방화벽
# Java 또는 IntelliJ IDEA에 대한 수신 연결 허용
```

Windows:
- Windows Defender 방화벽 > 고급 설정
- 인바운드 규칙 > 새 규칙 > 포트 8080 허용

### 4. Flutter 앱 실행

#### 연결된 디바이스 확인

```bash
flutter devices

# 출력 예시:
# iPhone 15 Pro (mobile) • 12345678-ABCD • ios • iOS 17.0 (simulator)
# sdk gphone64 arm64 (mobile) • emulator-5554 • android • Android 13 (API 33) (emulator)
```

#### 앱 실행

**기본 실행 (첫 번째 디바이스):**
```bash
cd mobile
flutter run
```

**특정 디바이스에서 실행:**
```bash
# iOS 시뮬레이터
flutter run -d "iPhone 15 Pro"

# Android 에뮬레이터
flutter run -d emulator-5554 --dart-define=API_URL=http://10.0.2.2:8080

# 실제 디바이스
flutter run -d your-device-id --dart-define=API_URL=http://192.168.0.10:8080
```

**릴리즈 모드 (성능 최적화):**
```bash
flutter run --release
```

### 5. 앱 실행 확인 및 테스트

앱이 정상 실행되면:

#### 1단계: 회원가입
- 이메일, 비밀번호, 이름 입력
- 백엔드 API: `POST /auth/signup`

#### 2단계: 로그인
- JWT 토큰 발급 및 안전 저장
- 백엔드 API: `POST /auth/login`

#### 3단계: 아기 정보 등록
- 이름, 생년월일, 성별 입력
- 백엔드 API: `POST /babies`

#### 4단계: 자동 스케줄 생성 (핵심 기능!)
- **기상 시간 입력** (예: 07:00)
- **모유/분유 선택**
- 자동으로 하루 스케줄 생성
- 백엔드 API: `POST /babies/{babyId}/auto-schedule`

생성된 스케줄 예시 (4개월 아기):
```
07:00 - 기상 및 수유
08:50 - 낮잠 1 (80분)
10:10 - 기상 및 수유
12:25 - 낮잠 2 (80분)
13:45 - 기상 및 수유
16:00 - 낮잠 3 (80분)
17:20 - 기상
18:45 - 마지막 수유
19:30 - 취침
```

#### 5단계: 커뮤니티 사용
- 게시글 목록 조회
- 게시글 작성, 좋아요
- 댓글 작성

### 6. 디버깅 팁

#### Flutter DevTools

```bash
# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools

# 앱 실행 시 자동 연결
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

#### 로그 확인

```bash
# Flutter 로그
flutter logs

# 특정 태그만 필터링
flutter logs | grep "API"
```

#### Hot Reload vs Hot Restart

- **Hot Reload** (`r`): UI 변경 사항만 반영 (빠름)
- **Hot Restart** (`R`): 앱 전체 재시작 (상태 초기화)

## API 문서

### 인증 (Authentication)

#### 회원가입
```http
POST /auth/signup
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동"
}

Response: 201 Created
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동"
  },
  "timestamp": "2024-11-11T10:00:00"
}
```

#### 로그인
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response: 200 OK
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 1
  }
}
```

#### 토큰 갱신
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}

Response: 200 OK
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 아기 정보 (Baby)

#### 아기 등록
```http
POST /babies
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "name": "민준",
  "birthDate": "2024-07-15",
  "gender": "MALE"
}

Response: 201 Created
{
  "success": true,
  "data": {
    "id": 1,
    "name": "민준",
    "birthDate": "2024-07-15",
    "gender": "MALE",
    "ageInMonths": 4
  }
}
```

#### 아기 목록 조회
```http
GET /babies
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "민준",
      "birthDate": "2024-07-15",
      "gender": "MALE",
      "ageInMonths": 4
    }
  ]
}
```

### 자동 스케줄 생성 (핵심 기능) 🌟

#### 스케줄 자동 생성
```http
POST /babies/{babyId}/auto-schedule
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "wakeUpTime": "07:00",
  "isBreastfeeding": true
}

Response: 201 Created
{
  "success": true,
  "data": {
    "babyId": 1,
    "ageInMonths": 4,
    "totalNapCount": 3,
    "totalNapMinutes": 240,
    "items": [
      {
        "id": 1,
        "startTime": "07:00",
        "activityType": "WAKE_UP",
        "activityName": "기상 및 수유",
        "durationMinutes": null,
        "note": "하루의 시작"
      },
      {
        "id": 2,
        "startTime": "08:50",
        "activityType": "NAP1",
        "activityName": "낮잠 1",
        "durationMinutes": 80,
        "note": "첫 번째 낮잠"
      },
      {
        "id": 3,
        "startTime": "10:10",
        "activityType": "WAKE_UP",
        "activityName": "기상",
        "durationMinutes": null,
        "note": null
      },
      {
        "id": 4,
        "startTime": "10:45",
        "activityType": "FEEDING",
        "activityName": "수유",
        "durationMinutes": null,
        "note": "모유 수유"
      }
      // ... 더 많은 스케줄 아이템
    ]
  }
}
```

**activityType 종류:**
- `WAKE_UP`: 기상
- `NAP1`, `NAP2`, `NAP3`, `NAP4`: 낮잠 (개월별 차이)
- `BEDTIME`: 취침
- `FEEDING`: 수유
- `PLAY`: 놀이 시간

#### 스케줄 동적 조정
```http
PUT /babies/{babyId}/auto-schedule/adjust
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "scheduleItemId": 2,
  "actualStartTime": "09:00",
  "actualDurationMinutes": 60
}

Response: 200 OK
{
  "success": true,
  "data": {
    "adjustedItems": [...]  # 조정된 이후 스케줄
  }
}
```

### 수유 기록 (Feeding)

#### 수유 기록 생성
```http
POST /babies/{babyId}/feeding-records
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "feedingTime": "2024-11-11T09:30:00",
  "type": "BREAST",
  "amountMl": 150,
  "note": "왼쪽 10분, 오른쪽 10분"
}

Response: 201 Created
```

**type 종류:**
- `BREAST`: 모유
- `BOTTLE`: 분유
- `SOLID`: 이유식

#### 수유 기록 목록 조회
```http
GET /babies/{babyId}/feeding-records?startDate=2024-11-01&endDate=2024-11-11
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": [
    {
      "id": 1,
      "babyId": 1,
      "feedingTime": "2024-11-11T09:30:00",
      "type": "BREAST",
      "amountMl": 150,
      "note": "왼쪽 10분, 오른쪽 10분",
      "createdAt": "2024-11-11T09:30:00"
    }
  ]
}
```

#### 오늘 총 수유량 조회
```http
GET /babies/{babyId}/feeding-records/today-stats
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "totalAmountMl": 750,
    "feedingCount": 5,
    "averageAmountMl": 150
  }
}
```

### 커뮤니티 (Community)

#### 게시글 목록 조회 (페이징)
```http
GET /community/posts?page=0&size=20&search=수면
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "title": "4개월 아기 밤잠 통잠 성공했어요!",
        "content": "드디어 통잠 성공했어요. 수면교육 시작한지 2주만에...",
        "anonymousAuthor": "익명123",
        "likeCount": 15,
        "commentCount": 8,
        "createdAt": "2024-11-11T10:00:00"
      }
    ],
    "totalElements": 100,
    "totalPages": 5,
    "size": 20,
    "number": 0
  }
}
```

#### 게시글 작성
```http
POST /community/posts
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "title": "낮잠 30분만 자고 깨요",
  "content": "6개월 아기인데 낮잠을 30분만 자고 깨요. 어떻게 하면 낮잠을 길게 잘 수 있을까요?"
}

Response: 201 Created
{
  "success": true,
  "data": {
    "id": 2,
    "title": "낮잠 30분만 자고 깨요",
    "content": "6개월 아기인데...",
    "anonymousAuthor": "익명456",
    "likeCount": 0,
    "commentCount": 0,
    "createdAt": "2024-11-11T11:00:00"
  }
}
```

#### 게시글 좋아요
```http
POST /community/posts/{postId}/like
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "id": 1,
    "likeCount": 16
  }
}
```

#### 댓글 작성
```http
POST /community/posts/{postId}/comments
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "content": "저희도 같은 고민이에요. 수면 교육 시작하려고 합니다."
}

Response: 201 Created
{
  "success": true,
  "data": {
    "id": 1,
    "postId": 2,
    "content": "저희도 같은 고민이에요...",
    "anonymousAuthor": "익명789",
    "createdAt": "2024-11-11T11:05:00"
  }
}
```

## 테스트

### 백엔드 테스트

#### 전체 테스트 실행
```bash
cd backend
./gradlew test
```

#### 특정 테스트 클래스 실행
```bash
./gradlew test --tests AutoScheduleServiceTest
./gradlew test --tests CommunityServiceTest
```

#### 테스트 커버리지 확인
```bash
./gradlew test jacocoTestReport

# 리포트 열기 (Mac)
open build/reports/jacoco/test/html/index.html

# 리포트 열기 (Linux)
xdg-open build/reports/jacoco/test/html/index.html
```

#### H2 통합 테스트
```bash
# @DataJpaTest 어노테이션 사용
./gradlew test --tests *RepositoryTest
```

### Flutter 테스트

```bash
cd mobile

# 단위 테스트
flutter test

# 위젯 테스트
flutter test test/widget_test.dart

# 커버리지
flutter test --coverage

# 커버리지 리포트 (genhtml 필요)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 문제 해결 (Troubleshooting)

### 백엔드 문제

#### 1. 포트 8080이 이미 사용 중

**증상:**
```
Port 8080 was already in use.
```

**해결:**

Mac/Linux:
```bash
# 포트 사용 프로세스 확인
lsof -i :8080

# 프로세스 종료
kill -9 <PID>
```

Windows:
```bash
# 포트 사용 프로세스 확인
netstat -ano | findstr :8080

# 프로세스 종료
taskkill /PID <PID> /F
```

**또는 다른 포트 사용:**
```bash
./gradlew bootRun --args='--spring.profiles.active=dev --server.port=8081'
```

#### 2. 데이터베이스 연결 실패

**증상:**
```
Failed to obtain JDBC Connection
```

**해결:**

PostgreSQL 실행 확인:
```bash
# Mac
brew services list
brew services restart postgresql@15

# Linux
sudo systemctl status postgresql
sudo systemctl start postgresql
```

`application-prod.yml` 설정 확인:
- URL: `jdbc:postgresql://localhost:5432/dutyout`
- Username/Password 정확한지 확인

**또는 H2로 전환:**
```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```

#### 3. Gradle 빌드 실패

**증상:**
```
Could not resolve all dependencies
```

**해결:**
```bash
# Gradle 캐시 정리
./gradlew clean --refresh-dependencies

# 오프라인 모드 비활성화
./gradlew build --no-daemon

# Gradle Wrapper 재다운로드
./gradlew wrapper --gradle-version=8.5
```

#### 4. JWT 토큰 오류

**증상:**
```
JWT signature does not match
```

**해결:**
- `application.yml`의 `jwt.secret` 값이 변경되었는지 확인
- Flutter 앱에서 기존 토큰 삭제 후 재로그인
- 시크릿 키는 최소 32자 이상 권장

```yaml
jwt:
  secret: very-long-and-secure-secret-key-minimum-32-characters
```

#### 5. 초기 데이터 로드 안됨

**증상:**
수면 가이드라인 데이터가 로드되지 않음

**해결:**
`SleepGuidelineDataLoader.java` 확인:
```java
@Profile({"dev", "local", "test"})  // prod는 제외
```

dev 프로필로 실행:
```bash
./gradlew bootRun --args='--spring.profiles.active=dev'
```

### Flutter 문제

#### 1. 패키지 설치 실패

**증상:**
```
pub get failed
```

**해결:**
```bash
# Flutter 업그레이드
flutter upgrade

# 캐시 정리
flutter clean
flutter pub cache repair
flutter pub get

# 특정 패키지 재설치
flutter pub remove dio
flutter pub add dio
```

#### 2. API 연결 실패

**증상:**
```
SocketException: Failed host lookup: 'localhost'
DioException: Connection refused
```

**해결 체크리스트:**

1. **백엔드 서버 실행 확인**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

2. **올바른 API URL 사용**
   - iOS 시뮬레이터: `http://localhost:8080` ✅
   - Android 에뮬레이터: `http://10.0.2.2:8080` ✅
   - 실제 디바이스: `http://192.168.0.10:8080` (실제 IP) ✅

3. **실제 디바이스: 같은 Wi-Fi 네트워크 확인**

4. **백엔드 외부 접속 허용**
   ```yaml
   # application-dev.yml
   server:
     address: 0.0.0.0
   ```

5. **방화벽 확인**
   - Mac: 시스템 설정 > 네트워크 > 방화벽 > Java 허용
   - Windows: Windows Defender 방화벽 > 포트 8080 허용

#### 3. iOS 빌드 실패

**증상:**
```
CocoaPods not installed
```

**해결:**
```bash
# CocoaPods 설치
sudo gem install cocoapods

# Pod 설치
cd mobile/ios
pod install
cd ../..

# 캐시 정리 후 재실행
flutter clean
flutter pub get
flutter run
```

**증상:**
```
Signing for "Runner" requires a development team
```

**해결:**
1. Xcode에서 `mobile/ios/Runner.xcworkspace` 열기
2. Runner 프로젝트 선택
3. Signing & Capabilities 탭
4. Team 선택 (Apple Developer 계정 필요)

#### 4. Android 빌드 실패

**증상:**
```
Gradle build failed
```

**해결:**
```bash
# Android SDK 확인
flutter doctor -v

# Gradle 정리
cd mobile/android
./gradlew clean
cd ../..

# Flutter 정리
flutter clean
flutter pub get
flutter run
```

**증상:**
```
MinSdkVersion 21 cannot be smaller than version 23
```

**해결:**
`mobile/android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        minSdkVersion 23  // 변경
    }
}
```

#### 5. 토큰 저장 오류

**증상:**
```
PlatformException (flutter_secure_storage)
```

**해결:**

Android:
```bash
# 앱 삭제 후 재설치
flutter clean
flutter run
```

iOS:
```bash
# 시뮬레이터 리셋
# Device > Erase All Content and Settings

# 또는 명령어
xcrun simctl erase all
```

#### 6. Hot Reload 작동 안 함

**증상:**
코드 변경이 반영되지 않음

**해결:**
- Hot Restart 사용: `R` (대문자)
- 또는 완전 재시작: `flutter run` 다시 실행

#### 7. 실제 디바이스 연결 안됨

**증상:**
```
No devices found
```

**Android 해결:**
```bash
# USB 디버깅 활성화 (디바이스 설정)
# 설정 > 개발자 옵션 > USB 디버깅 ON

# ADB 확인
adb devices

# ADB 재시작
adb kill-server
adb start-server

# Flutter 인식 확인
flutter devices
```

**iOS 해결:**
```bash
# Mac에서 디바이스 신뢰 확인
# 디바이스에서 "이 컴퓨터를 신뢰하시겠습니까?" 허용

# Xcode에서 서명 설정
open mobile/ios/Runner.xcworkspace
# Signing & Capabilities > Team 선택

# Flutter 인식 확인
flutter devices
```

### 네트워크 문제

#### 실제 디바이스에서 API 연결 안됨

**완전한 해결 가이드:**

**1단계: 같은 Wi-Fi 확인**
- 컴퓨터와 디바이스가 같은 Wi-Fi 네트워크에 연결

**2단계: 컴퓨터 IP 확인**
```bash
# Mac/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig

# 예시 출력: 192.168.0.10
```

**3단계: 백엔드 외부 접속 허용**

`backend/src/main/resources/application-dev.yml`:
```yaml
server:
  address: 0.0.0.0  # 중요!
  port: 8080
```

백엔드 재시작!

**4단계: 방화벽 설정**

Mac:
```bash
# 시스템 설정 > 네트워크 > 방화벽 > 옵션
# Java 또는 IntelliJ IDEA 수신 연결 허용
```

Windows:
```bash
# Windows Defender 방화벽 > 고급 설정
# 인바운드 규칙 > 새 규칙
# 포트 > TCP > 특정 로컬 포트: 8080 > 연결 허용
```

**5단계: Flutter 앱 실행**
```bash
flutter run --dart-define=API_URL=http://192.168.0.10:8080
```

**6단계: 연결 테스트**

디바이스 브라우저에서:
```
http://192.168.0.10:8080/actuator/health
```

응답이 오면 성공!

## 개발 팁

### 1. 개발 워크플로우

**백엔드 개발:**
```bash
# 1. dev 프로필로 실행 (H2)
./gradlew bootRun --args='--spring.profiles.active=dev'

# 2. 코드 수정

# 3. 테스트 실행
./gradlew test --tests YourTest

# 4. 변경사항 확인
curl http://localhost:8080/your-endpoint
```

**Flutter 개발:**
```bash
# 1. Hot Reload 모드로 실행
flutter run

# 2. 코드 수정

# 3. Hot Reload: r (소문자) - UI 변경만
# 4. Hot Restart: R (대문자) - 전체 재시작
# 5. 종료: q
```

### 2. 로그 레벨 조정

`backend/src/main/resources/application-dev.yml`:
```yaml
logging:
  level:
    root: INFO
    com.dutyout: DEBUG  # 프로젝트 패키지만 DEBUG
    org.springframework.web: DEBUG  # HTTP 요청 로그
    org.hibernate.SQL: DEBUG  # SQL 쿼리
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE  # SQL 파라미터
```

### 3. H2 Console 사용

개발 환경에서 H2 Console로 데이터 확인:

1. `http://localhost:8080/h2-console` 접속
2. JDBC URL: `jdbc:h2:mem:dutyout`
3. Username: `sa`
4. Password: (비어있음)
5. Connect 클릭

**유용한 쿼리:**
```sql
-- 전체 테이블 확인
SHOW TABLES;

-- 수면 가이드라인 데이터 확인
SELECT * FROM age_based_sleep_guideline ORDER BY age_in_months;

-- 특정 개월 수 가이드라인
SELECT * FROM age_based_sleep_guideline WHERE age_in_months = 4;

-- 생성된 스케줄 확인
SELECT * FROM daily_schedule;
SELECT * FROM schedule_item;

-- 사용자 확인
SELECT * FROM users;
```

## 아키텍처 설명

### 백엔드: Clean Architecture + DDD

```
Presentation Layer (Controller)
        ↓ Request DTO
Application Layer (Service)
        ↓ Domain Model
Domain Layer (Entity, Repository Interface)
        ↓ Repository Implementation
Infrastructure Layer (JPA, Security, External)
```

**계층별 역할:**
- **Domain**: 비즈니스 로직, 엔티티, 리포지토리 인터페이스
- **Application**: 유즈케이스, 도메인 조합, 트랜잭션
- **Infrastructure**: JPA 구현, 외부 API, 보안 설정
- **Presentation**: REST API, DTO 변환

### Flutter: Provider 패턴

```
UI (Screen)
   ↓ Provider.of<T> / Consumer<T>
Provider (ChangeNotifier)
   ↓ API Service
API Client (Dio)
   ↓ HTTP Request
Backend
```

**주요 Provider:**
- `ScheduleProvider`: 스케줄 관리
- `CommunityProvider`: 커뮤니티 관리
- `FeedingProvider`: 수유 기록 관리
- `AuthProvider`: 인증 상태 관리

## 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 기여

버그 리포트나 기능 제안은 이슈로 등록해주세요.

## 연락처

프로젝트 관련 문의: [이메일 주소]

---

<p align="center">
  Made with ❤️ for tired parents
</p>

<p align="center">
  ⭐ 도움이 되셨다면 Star를 눌러주세요!
</p>
