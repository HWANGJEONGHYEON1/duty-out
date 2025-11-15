# 로컬 테스트 가이드

## 🚀 빠른 시작

### 사전 요구사항
- Java 17 이상
- Flutter SDK
- Android 에뮬레이터 또는 iOS 시뮬레이터

---

## Backend 실행

### 1단계: Backend 터미널 열기
```bash
cd backend
./run-local.sh
```

### 2단계: 실행 확인
Backend가 성공적으로 시작되면 아래와 같은 로그가 나타나야 합니다:

```
o.s.b.w.embedded.tomcat.TomcatWebServer : Tomcat started on port(s): 8080 (http) with context path ''
```

**주요 로그 메시지:**
- 더미 토큰 감지: `로컬 테스트 모드: 더미 토큰 감지`
- 테스트 사용자 인증: `로컬 테스트 모드: 테스트용 사용자로 인증됨 - User ID: 1`

---

## Flutter 앱 실행

### 1단계: Flutter 터미널 열기 (새 터미널)
```bash
cd mobile
./run-local.sh
```

또는 수동으로:
```bash
cd mobile
flutter pub get
flutter run
```

### 2단계: 앱이 에뮬레이터에서 실행될 때까지 대기

---

## 테스트 플로우

### 1️⃣ 로그인 (임시 모드)
- 로그인 화면에서 **아무 버튼이나 클릭** (카카오, Apple, Google)
- 더미 토큰이 저장되고 MainScreen으로 이동

**Backend 로그:**
```
로컬 테스트 모드: 더미 토큰 감지
로컬 테스트 모드: 테스트용 사용자로 인증됨 - User ID: 1
```

### 2️⃣ 아기 정보 등록
- MainScreen 진입
- 아기 정보가 없으면 **BabyRegistrationScreen** 자동 이동
- 아래 정보 입력:
  - 아기 이름: "예쁜이" (또는 원하는 이름)
  - 생년월일: 날짜 선택
  - 출생 주수: 슬라이더로 선택 (기본 39주)
  - 성별: 남아 또는 여아 선택
- **등록하기** 버튼 클릭

### 3️⃣ 스케줄 생성 (핵심 기능)
- 하단 탭에서 📅 **스케줄** 선택
- **기상 시간** 클릭
- 시간 선택 (예: 오전 7:00)
- 자동으로 일과 스케줄 생성됨

**생성되는 일과 예시:**
```
06:00 - 기상
06:30 - 수유/이유식
...
23:00 - 취침
```

### 4️⃣ 다른 화면 테스트
- 📊 **통계**: 일일/주간/월간 수면 통계
- 💬 **커뮤니티**: 게시글 작성/조회
- 👤 **설정**: 프로필 관리

---

## 🐛 디버깅 - 로그 확인

### Backend 로그에서 확인할 사항

**1. 인증 성공:**
```
로컬 테스트 모드: 테스트용 사용자로 인증됨 - User ID: 1
```

**2. API 요청:**
```
POST /api/v1/babies/1/auto-schedule - 기상 시간: HH:mm
```

**3. 에러 발생:**
```
[ERROR] SecurityContext에 사용자 인증을 설정할 수 없습니다.
```

### Flutter 콘솔에서 확인할 사항

**1. API 호출 성공:**
```
[INFO] 스케줄 생성 성공
```

**2. 에러 발생:**
```
[ERROR] DioException [bad response]: 403 Forbidden
```

---

## 자주 발생하는 문제 & 해결책

### 1️⃣ 403 Forbidden 에러

**원인:** API 경로 또는 인증 토큰 문제

**해결책:**
```bash
# Backend 재시작
cd backend
./run-local.sh

# Flutter 앱 재실행
flutter clean
flutter pub get
flutter run
```

### 2️⃣ "아기 정보를 찾을 수 없습니다" 에러

**원인:** 아기 정보 API 요청 실패

**디버깅:**
1. Backend 로그에서 `POST /api/v1/babies` 요청 확인
2. 네트워크 연결 확인 (에뮬레이터 ↔ localhost:8080)
3. 타임아웃 발생 시: AndroidManifest.xml에서 cleartext 트래픽 허용 확인

### 3️⃣ "로컬 테스트 모드" 로그가 안 보임

**원인:** 더미 토큰이 제대로 전달되지 않음

**해결책:**
```bash
# 앱 캐시 삭제
flutter clean

# 앱 재실행
flutter run

# 로그인 후 콘솔에서 로그 확인
```

---

## API 엔드포인트 (로컬)

### 기본 URL
```
http://localhost:8080/api/v1
```

### 주요 엔드포인트

| 기능 | Method | 엔드포인트 |
|------|--------|-----------|
| 아기 목록 조회 | GET | `/babies` |
| 아기 정보 조회 | GET | `/babies/{babyId}` |
| 스케줄 생성 | POST | `/babies/{babyId}/auto-schedule` |
| 수유 기록 생성 | POST | `/babies/{babyId}/feeding-records` |
| 게시글 목록 | GET | `/community/posts` |
| 게시글 작성 | POST | `/community/posts` |

---

## 🧪 수동 API 테스트 (curl 사용)

### 스케줄 생성 테스트
```bash
curl -X POST http://localhost:8080/api/v1/babies/1/auto-schedule \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer dummy_access_token_for_local_testing" \
  -d '{"wakeUpTime": "07:00", "isBreastfeeding": true}'
```

### 게시글 생성 테스트
```bash
curl -X POST http://localhost:8080/api/v1/community/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer dummy_access_token_for_local_testing" \
  -d '{"title": "테스트", "content": "테스트 게시글"}'
```

---

## 📊 로그 레벨 조정

### Backend (application.yml)
```yaml
logging:
  level:
    com.dutyout: DEBUG  # 앱 로그
    org.springframework.security: DEBUG  # 보안 관련 로그
    org.springframework.web: DEBUG  # 웹 요청 로그
```

### Flutter (api_client.dart)
코드에서 debugPrint 로그를 봅니다:
```
flutter run | grep "API\|로그인\|스케줄"
```

---

## ✅ 체크리스트

로컬 테스트를 시작하기 전에 확인하세요:

- [ ] Java 17 이상 설치 확인: `java -version`
- [ ] Flutter SDK 설치 확인: `flutter --version`
- [ ] 에뮬레이터 또는 시뮬레이터 실행 중: `flutter devices`
- [ ] Backend 실행: `./run-local.sh` (backend 디렉토리)
- [ ] Backend localhost:8080 접속 확인
- [ ] Flutter 앱 실행: `./run-local.sh` (mobile 디렉토리)

---

## 📱 Android 에뮬레이터 네트워크 설정

Android 에뮬레이터가 localhost에 접근하지 못하는 경우:

```dart
// lib/config/api_config.dart 수정
static const String baseUrl = 'http://10.0.2.2:8080';  // 기본값
```

- `localhost` → `10.0.2.2`로 변경 (Android만)
- iOS 시뮬레이터는 그대로 `localhost` 사용

---

## 🎯 주요 기능 테스트 순서

1. ✅ 로그인 (더미 토큰)
2. ✅ 아기 정보 등록
3. ✅ 기상 시간 입력 → 스케줄 자동 생성
4. ✅ 게시글 작성 (커뮤니티)
5. ✅ 통계 조회

---

**문제가 발생하면 Backend 로그와 Flutter 콘솔을 확인하세요!**
