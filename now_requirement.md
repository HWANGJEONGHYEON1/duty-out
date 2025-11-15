# 현재 구현된 기능 명세서

## 📋 목차
1. [전체 구조](#전체-구조)
2. [메인 스크린](#메인-스크린)
3. [설정 탭 (아기 정보)](#설정-탭-아기-정보)
4. [스케줄 탭](#스케줄-탭)
5. [통계 탭](#통계-탭)
6. [커뮤니티 탭](#커뮤니티-탭)
7. [API 연동](#api-연동)
8. [로그인/인증](#로그인인증)

---

## 전체 구조

### 네비게이션 흐름
```
로그인 → 메인 스크린
         ├─ 아기 정보 없음 → 설정 탭만 활성화 (아기 정보 입력 화면)
         └─ 아기 정보 있음 → 모든 탭 활성화
             ├─ 📅 스케줄 탭
             ├─ 📊 통계 탭
             ├─ 💬 커뮤니티 탭
             └─ 👤 설정 탭
```

### 상태 관리
- **Provider**: BabyProvider, ScheduleProvider 사용
- **로컬 저장소**: SharedPreferences (토큰 저장)
- **API 클라이언트**: Dio (인터셉터로 자동 토큰 주입)

---

## 메인 스크린

### 기능
- ✅ 아기 정보 로드 (MainScreen initState)
- ✅ 아기 정보 유무에 따른 조건부 렌더링
- ✅ 네비게이션 탭 활성화/비활성화 제어

### 상세 기능

#### 1. 아기 정보 없음 상태
- **화면**: 설정 탭만 표시
- **네비게이션**: 다른 탭들은 비활성화 (opacity 0.5)
- **목적**: 아기 정보 입력 강제

#### 2. 아기 정보 있음 상태
- **화면**: 4개 탭 모두 활성화
  - 📅 스케줄
  - 📊 통계
  - 💬 커뮤니티
  - 👤 설정
- **네비게이션**: 탭 클릭으로 화면 전환

### 구현 파일
- `mobile/lib/screens/main_screen.dart`

---

## 설정 탭 (아기 정보)

### 화면 상태

#### 1️⃣ 아기 정보 없음 (초기 상태)

**섹션**: 아기 정보 입력

| 필드 | 타입 | 입력 방식 | 필수 |
|------|------|---------|------|
| 아기 이름 | TextField | 직접 입력 | ✅ |
| 생년월일 | DatePicker | 달력 선택 | ✅ |
| 출생 주수 | Slider | 30-42주 선택 | ✅ |
| 성별 | 고정값 | MALE (향후 확장 가능) | ✅ |

**버튼**:
- 🔵 "아기 등록" - 아기 정보 생성 API 호출
  - 로딩 상태: CircularProgressIndicator 표시
  - 성공: SnackBar "아기 정보가 등록되었습니다!"
  - 실패: SnackBar "등록 실패: {에러 메시지}"

#### 2️⃣ 아기 정보 있음 (등록 후 상태)

**섹션 1**: 아기 정보

| 필드 | 표시 | 편집 가능 |
|------|------|---------|
| 이름 | O | ✅ (클릭해서 편집) |
| 생년월일 | O | ❌ |
| 출생 주수 | O | ❌ |
| 현재 월령 | O | ❌ |

**이름 편집 기능**:
- 아이콘 클릭: ✏️ 편집 모드 진입
- 편집 모드에서:
  - TextField로 이름 입력
  - 아이콘 변경: ✏️ → ✖️ (취소)
  - "저장" 버튼 표시
  - 저장 중: 로딩 인디케이터
  - 저장 완료: "아기 정보가 저장되었습니다!" SnackBar
  - 에러: 빨간색 에러 박스 표시

**섹션 2**: 알림 설정

| 설정 | 기본값 | 기능 |
|------|-------|------|
| 다음 일정 알림 | ON | 토글 스위치 |
| 수면 기록 리마인더 | ON | 토글 스위치 |

### 구현 파일
- `mobile/lib/screens/profile_screen.dart`
- `mobile/lib/providers/baby_provider.dart`

---

## 스케줄 탭

### 화면 구성

#### 섹션 1: 헤더
- 제목: "일과 스케줄 편집"
- 아기 이름 및 월령 표시: "👶 {아기이름} ({월령})"

#### 섹션 2: 기상 시간 입력

**UI 요소**:
- 제목: "기상 시간 입력"
- 설명: "아기의 기상 시간을 입력하면 하루 일과가 자동으로 생성됩니다"
- 큰 시간 입력 박스
  - 🕐 아이콘
  - 시간 표시 (기본: 오늘 00:00)
  - 폰트 크기: 48px (큰 숫자)
  - 힌트: "탭하여 시간 변경"

**기능**:
- 탭 → TimePicker 열림
- 시간 선택 → 자동 API 호출 (generateAutoSchedule)
- 로딩 중: CircularProgressIndicator 표시
- 성공: "스케줄이 생성되었습니다!" SnackBar
- 실패: 빨간 에러 박스 표시 + 에러 메시지

#### 섹션 3: 생성된 스케줄 목록

**빈 상태** (스케줄 미생성):
```
🕐 (큰 아이콘)
"기상 시간을 입력하세요"
"상단의 기상 시간을 입력하면
하루 일과가 자동으로 생성됩니다"
```

**스케줄 항목** (생성 후):
- 시간 범위: "HH:MM - HH:MM"
- 활동명: "기상", "먹이기", "낮잠" 등
- 소요 시간: "{분} 분"
- 배경색: 활동 타입별 구분
  - 낮잠: 보라색 (0xFFF3E5F5)
  - 취침: 파란색 (0xFFE3F2FD)
  - 그 외: 흰색

**항목 상호작용**:
- 클릭 → 편집 다이얼로그 열림
- 편집 다이얼로그:
  - 시간 수정 (TimePicker)
  - 활동명 수정 (TextField)
  - "취소" / "저장" 버튼

### 구현 파일
- `mobile/lib/screens/schedule_screen.dart`
- `mobile/lib/providers/schedule_provider.dart`

---

## 통계 탭

### 현재 상태
⚠️ **미구현** - UI만 존재

### 구현 파일
- `mobile/lib/screens/new_statistics_screen.dart`

---

## 커뮤니티 탭

### 현재 상태
⚠️ **미구현** - UI만 존재

### 구현 파일
- `mobile/lib/screens/community_screen.dart`

---

## API 연동

### BabyProvider (아기 정보 관리)

| 메서드 | 역할 | API 엔드포인트 | 반환값 |
|--------|------|----------------|--------|
| `loadMyBabies()` | 내 아기 목록 조회 | GET `/api/v1/babies` | List<Baby> |
| `loadBaby(babyId)` | 특정 아기 상세 정보 | GET `/api/v1/babies/{babyId}` | Baby |
| `createBaby(...)` | 아기 정보 생성 | POST `/api/v1/babies` | Baby |
| `updateBabyInfo(babyId, name)` | 아기 이름 수정 | PUT `/api/v1/babies/{babyId}` | Baby |

**상태 관리**:
- `_baby`: 현재 선택된 아기 정보
- `_babies`: 아기 목록
- `_isLoading`: 로딩 상태
- `_error`: 에러 메시지

### ScheduleProvider (스케줄 관리)

| 메서드 | 역할 | API 엔드포인트 | 반환값 |
|--------|------|----------------|--------|
| `generateAutoSchedule(babyId, wakeUpTime)` | 자동 스케줄 생성 | POST `/api/v1/babies/{babyId}/auto-schedule` | Schedule |
| `updateWakeTime(time, babyId)` | 기상 시간 변경 및 스케줄 재생성 | 자동으로 generateAutoSchedule 호출 | void |

**상태 관리**:
- `_scheduleItems`: 생성된 스케줄 항목 목록
- `_wakeTime`: 기상 시간
- `_isLoading`: 로딩 상태
- `_error`: 에러 메시지

### BabyApiService (아기 API 클라이언트)

```dart
// 메서드 목록
getMyBabies() → Future<List<Map<String, dynamic>>>
getBaby(babyId) → Future<Map<String, dynamic>>
createBaby({name, birthDate, gestationalWeeks, gender, profileImage}) → Future<Map<String, dynamic>>
updateBaby({babyId, name, profileImage}) → Future<Map<String, dynamic>>
deleteBaby(babyId) → Future<void>
```

### ScheduleApiService (스케줄 API 클라이언트)

```dart
// 메서드 목록
generateAutoSchedule({babyId, wakeUpTime, isBreastfeeding}) → Future<Map<String, dynamic>>
```

### API 요청/응답 형식

#### CreateBaby 요청
```json
{
  "name": "string",
  "birthDate": "yyyy-MM-dd",
  "gestationalWeeks": 39,
  "gender": "MALE"
}
```

#### UpdateBaby 요청
```json
{
  "name": "string"
}
```

#### GenerateAutoSchedule 요청
```json
{
  "wakeUpTime": "HH:mm",
  "isBreastfeeding": true
}
```

#### 응답 형식
```json
{
  "code": "200",
  "message": "success",
  "data": { ... }
}
```

### 구현 파일
- `mobile/lib/services/baby_api_service.dart`
- `mobile/lib/services/schedule_api_service.dart`
- `mobile/lib/providers/baby_provider.dart`
- `mobile/lib/providers/schedule_provider.dart`

---

## 로그인/인증

### 현재 구현 상태
✅ **임시 로그인 시스템** (로컬 테스트용)

### 로그인 화면 기능

| 버튼 | 기능 | 저장되는 정보 |
|------|------|-------------|
| "Google로 시작" | 임시 로그인 (테스트용) | 더미 토큰, 사용자 정보 |
| "카카오로 시작" | 임시 로그인 (테스트용) | 더미 토큰, 사용자 정보 |
| "Apple로 시작" | 임시 로그인 (테스트용) | 더미 토큰, 사용자 정보 |

### 토큰 저장 정보
- `access_token`: "dummy_access_token_for_local_testing"
- `refresh_token`: "dummy_refresh_token_for_local_testing"
- `user_id`: "1"
- `user_name`: "Test User"

### API 인증 방식
- **헤더**: `Authorization: Bearer {access_token}`
- **자동 주입**: ApiClient 인터셉터에서 모든 API 요청에 자동 추가
- **로컬 테스트 모드**: JwtAuthenticationFilter에서 더미 토큰 감지

### 구현 파일
- `mobile/lib/screens/login_screen.dart`
- `mobile/lib/services/api_client.dart`
- `backend/src/main/java/com/dutyout/infrastructure/security/JwtAuthenticationFilter.java`

---

## 데이터 모델

### Baby 모델
```dart
class Baby {
  final int id;
  final String name;
  final DateTime birthDate;
  final int birthWeeks;

  // 계산 속성
  String get ageText;        // "생후 3개월"
  int get ageInDays;         // 90
}
```

### ScheduleItem 모델
```dart
class ScheduleItem {
  final String id;
  final DateTime time;
  final String activity;
  final String type;         // 'wake', 'sleep', 'feed', 'play'
  final int? durationMinutes;

  // 계산 속성
  String get timeString;     // "HH:MM"
  String get durationString; // "60분"
}
```

---

## 에러 처리

### 공통 에러 처리
- **로딩 실패**: SnackBar에 에러 메시지 표시
- **네트워크 오류**: "API 통신 실패: {에러메시지}"
- **검증 오류**: 각 필드별 유효성 검사 후 메시지 표시

### 구현 방식
- Try-Catch 블록으로 예외 처리
- setState()로 UI 업데이트
- mounted 체크로 위젯 소멸 후 업데이트 방지

---

## 로컬 테스트 설정

### 백엔드 설정
- H2 인메모리 데이터베이스
- 더미 토큰 인식 모드
- 경로: `/api/v1/` 통일

### 프론트엔드 설정
- ApiClient 베이스 URL: `http://localhost:8080` (로컬)
- 더미 토큰 자동 주입
- 토큰 로컬 저장

---

## 구현 완료 체크리스트

### ✅ 완료된 기능
- [x] 로그인 화면 (임시)
- [x] 메인 스크린 네비게이션
- [x] 설정 탭 - 아기 정보 입력 폼
- [x] 설정 탭 - 아기 정보 표시 및 편집
- [x] 스케줄 탭 - 기상 시간 입력
- [x] 스케줄 탭 - 스케줄 항목 표시
- [x] 스케줄 탭 - 항목 편집 다이얼로그
- [x] API 연동 (Baby, Schedule)
- [x] 토큰 관리 및 자동 주입
- [x] 에러 처리 및 사용자 피드백

### ⏳ 진행 중
- [ ] 실제 OAuth 로그인 구현
- [ ] 푸시 알림 기능
- [ ] 오프라인 모드

### ❌ 미구현
- [ ] 통계 탭 기능
- [ ] 커뮤니티 탭 기능
- [ ] 수면 기록 기능
- [ ] 먹이기 기록 기능
- [ ] 사진 업로드 기능

---

## 주요 파일 구조

```
mobile/lib/
├── screens/
│   ├── login_screen.dart          # 로그인
│   ├── main_screen.dart           # 메인 네비게이션
│   ├── profile_screen.dart        # 설정 탭
│   ├── schedule_screen.dart       # 스케줄 탭
│   ├── new_home_screen.dart       # 홈 탭 (미구현)
│   ├── new_statistics_screen.dart # 통계 탭 (미구현)
│   └── community_screen.dart      # 커뮤니티 탭 (미구현)
├── providers/
│   ├── baby_provider.dart         # 아기 정보 상태 관리
│   └── schedule_provider.dart     # 스케줄 상태 관리
├── services/
│   ├── api_client.dart            # HTTP 클라이언트
│   ├── baby_api_service.dart      # 아기 API
│   └── schedule_api_service.dart  # 스케줄 API
└── models/
    ├── baby.dart                  # Baby 모델
    └── schedule_item.dart         # ScheduleItem 모델
```

---

## 최종 사용자 흐름

```
1. 로그인 화면
   ↓
2. 임시 로그인 (더미 토큰 저장)
   ↓
3. 메인 스크린
   ↓
4. 아기 정보 없음 → 설정 탭에서 아기 정보 입력
   ↓
5. 아기 등록 완료 → 모든 탭 활성화
   ↓
6. 스케줄 탭에서 기상 시간 입력
   ↓
7. 자동 스케줄 생성 및 표시
   ↓
8. 스케줄 항목 클릭으로 편집 가능
```

---

*최종 업데이트: 2024-11-15*
*현재 구현된 기능 기준으로 작성*
