# 아기 수면 추적 앱 - 구현 완성 가이드

## 📋 개요

이 문서는 아기 정보 등록부터 스케줄 관리까지의 완전한 사용자 흐름을 설명합니다.

---

## 🎯 사용자 흐름

```
로그인 (더미 토큰)
    ↓
MainScreen 진입
    ↓
BabyProvider.baby == null 확인
    ├─ true → BabyRegistrationScreen 표시
    │         ├─ 아기 이름 입력
    │         ├─ 생년월일 선택 (DatePicker)
    │         ├─ 출생 주수 선택 (Slider)
    │         ├─ 성별 선택 (남아/여아)
    │         └─ "아기 등록하기" 클릭
    │             ├─ API: POST /api/v1/babies
    │             ├─ BabyProvider.baby 업데이트 (notifyListeners)
    │             └─ MainScreen 자동 재구성
    │
    └─ false → MainScreen 메인 화면 표시
             ├─ 탭 0: ScheduleScreen (기상 시간 입력 + 스케줄 관리)
             │         ├─ 기상 시간 입력 카드 (그래디언트)
             │         ├─ TimePicker로 시간 선택
             │         ├─ API: POST /api/v1/babies/{babyId}/auto-schedule
             │         └─ 스케줄 항목 목록 표시
             │
             ├─ 탭 1: NewStatisticsScreen (통계)
             ├─ 탭 2: CommunityScreen (커뮤니티)
             └─ 탭 3: ProfileScreen (설정)
                       ├─ 아기 이름 편집
                       ├─ 생년월일 표시
                       ├─ 월령 정보 표시
                       └─ 알림 설정
```

---

## 🎨 화면별 상세 설명

### 1️⃣ BabyRegistrationScreen
**파일**: `mobile/lib/screens/baby_registration_screen.dart`

#### 특징
- **Header**: 그래디언트 배경 (보라색 → 분홍색)
- **Progress Badge**: "필수정보 3/3" 표시
- **Form Fields**: Icon + Label + 입력 필드
- **Material Design 3**:
  - Border radius: 12-24dp
  - Box shadows 활용
  - Focus 상태 시 색상 변경

#### 구성 요소

```dart
Header (그래디언트)
  ↓
Form Area
  ├─ 아기 이름 TextField (Icon: child_care)
  ├─ 생년월일 DatePicker (Icon: calendar_today)
  ├─ 출생 주수 Slider (Icon: calendar_month)
  │  ├─ 진행도 표시 (39주)
  │  └─ 상태 배지 (정상/조산)
  ├─ 성별 선택 Buttons (Icon: person_outline)
  │  ├─ 👦 남아
  │  └─ 👧 여아
  └─ 등록하기 버튼 (높이: 56dp, 선택 아이콘 포함)
```

#### API 연동
```dart
await babyProvider.createBaby(
  name: _nameController.text,
  birthDate: DateFormat('yyyy-MM-dd').format(_selectedBirthDate!),
  gestationalWeeks: _gestationalWeeks,
  gender: _gender,
);
```

**Endpoint**: `POST /api/v1/babies`
**응답**: Baby 객체 (ID, 이름, 생년월일 등)
**상태 업데이트**: `notifyListeners()` → MainScreen 감지 → 자동 재구성

---

### 2️⃣ ScheduleScreen (스케줄 탭)
**파일**: `mobile/lib/screens/schedule_screen.dart`

#### 특징
- **기상 시간 입력 카드**: 그래디언트 배경, 큰 시간 표시 (56pt)
- **TimePicker 통합**: 클릭 시 시간 선택
- **자동 스케줄 생성**: 기상 시간 선택 후 API 호출
- **스케줄 목록**: 타입별 색상 구분, 편집 기능

#### 기상 시간 입력

```
┌─────────────────────────────┐
│   Header (그래디언트)         │
│ "일과 스케줄 편집"           │
│ 👶 예준이 (생후 XX일)       │
└─────────────────────────────┘

기상 시간 설정
├─ 제목: "기상 시간 설정"
├─ 설명: "하루 일과가 자동으로 생성돼요"
│
└─ 시간 선택 카드 (그래디언트)
   ├─ 시계 아이콘 (40pt)
   ├─ 큰 시간 (56pt): "07:00"
   ├─ 힌트: "탭하여 변경"
   └─ 로딩 중 → CircularProgressIndicator
```

#### 스케줄 항목 표시

```
타입별 색상 및 아이콘:
┌─ 기상 (wake)    → 노란색 (0xFFFFA500)
├─ 먹이기 (feed)  → 주황색 (0xFFFF9800)
├─ 낮잠 (sleep)   → 보라색 (0xFF9C27B0)
└─ 놀이 (play)    → 초록색 (0xFF4CAF50)

각 항목:
┌──────────────────────────┐
│ [아이콘]  시간 - 시간    │
│           활동명          │
│           ⏱️ XX분        │
│                      [편집] │
└──────────────────────────┘
```

#### API 연동

**기상 시간 업데이트**:
```dart
await scheduleProvider.updateWakeTime(newWakeTime, babyId: babyId);
```

**내부 동작**:
```
updateWakeTime()
  ↓
scheduleProvider._scheduleItems 업데이트
  ↓
generateAutoSchedule()
  ↓
API: POST /api/v1/babies/{babyId}/auto-schedule?time=HH:mm
  ↓
응답: { items: [...] } 파싱
  ↓
_scheduleItems 업데이트
  ↓
notifyListeners()
  ↓
UI 자동 재구성
```

**응답 예시**:
```json
{
  "items": [
    {
      "id": "uuid1",
      "type": "wake",
      "time": "07:00",
      "activity": "기상",
      "durationMinutes": 30
    },
    {
      "id": "uuid2",
      "type": "feed",
      "time": "07:30",
      "activity": "아침 먹이기",
      "durationMinutes": 30
    }
  ]
}
```

---

### 3️⃣ ProfileScreen (설정 탭)
**파일**: `mobile/lib/screens/profile_screen.dart`

#### 특징
- **편집 전용**: 아기 등록 폼 없음 (BabyRegistrationScreen에서 처리)
- **아기 정보 표시**: 이름, 생년월일, 월령
- **이름 편집 기능**: 인라인 편집 + 저장
- **알림 설정**: 토글 스위치

#### 구성

```
┌─────────────────────────┐
│   Header (그래디언트)    │
│ "아기 프로필"           │
│ "설정 및 관리"          │
└─────────────────────────┘

├─ 아바타 (👶 이모지)

├─ 아기 정보
│  ├─ 이름 (편집 가능)
│  │  ├─ 평상시: "예준이" [✎ 아이콘]
│  │  ├─ 편집 중: TextField [취소 아이콘]
│  │  └─ 저장 버튼
│  ├─ 생년월일: "2024-09-15"
│  ├─ 출생 주수: "39주"
│  └─ 현재 월령: "생후 45일"

└─ 알림 설정
   ├─ 다음 일정 알림 (토글)
   └─ 수면 기록 리마인더 (토글)
```

#### 이름 편집 API

```dart
await babyProvider.updateBabyInfo(
  babyId: babyId,
  name: _nameController.text,
);
```

**Endpoint**: `PUT /api/v1/babies/{babyId}`

---

## 🔄 상태 관리 (Provider Pattern)

### BabyProvider
**파일**: `mobile/lib/providers/baby_provider.dart`

```dart
class BabyProvider extends ChangeNotifier {
  Baby? _baby;

  // 게터
  Baby? get baby => _baby;

  // 아기 정보 로드
  Future<void> loadMyBabies() async {
    // API: GET /api/v1/babies
    // _baby = 첫 번째 아기 정보
  }

  // 아기 정보 생성 (BabyRegistrationScreen)
  Future<void> createBaby({
    required String name,
    required String birthDate,
    required int gestationalWeeks,
    required String gender,
  }) async {
    // API: POST /api/v1/babies
    // 응답으로 _baby 업데이트
    // notifyListeners() 호출
  }

  // 아기 정보 업데이트 (ProfileScreen)
  Future<void> updateBabyInfo({
    required int babyId,
    required String name,
  }) async {
    // API: PUT /api/v1/babies/{babyId}
    // _baby 업데이트
    // notifyListeners() 호출
  }
}
```

### ScheduleProvider
**파일**: `mobile/lib/providers/schedule_provider.dart`

```dart
class ScheduleProvider extends ChangeNotifier {
  DateTime _wakeTime = DateTime(2000, 1, 1, 7, 0);
  List<ScheduleItem> _scheduleItems = [];

  // 기상 시간 설정 + 스케줄 생성
  Future<void> updateWakeTime(DateTime time, {required int babyId}) async {
    _wakeTime = time;
    notifyListeners();

    // 자동 스케줄 생성
    await generateAutoSchedule(babyId: babyId, wakeUpTime: time);
  }

  // 자동 스케줄 생성
  Future<void> generateAutoSchedule({
    required int babyId,
    required DateTime wakeUpTime,
  }) async {
    // API: POST /api/v1/babies/{babyId}/auto-schedule
    // 응답 파싱
    // _scheduleItems 업데이트
    // notifyListeners() 호출
  }
}
```

---

## 🧪 테스트 시나리오

### 시나리오 1: 처음 사용자 (아기 등록)
```
1. 앱 실행
2. 로그인 (더미 토큰: "test-token-12345")
3. MainScreen 진입
4. BabyRegistrationScreen 표시 (baby == null)
5. 폼 작성:
   - 이름: "예준이"
   - 생년월일: 2024-09-15
   - 출생 주수: 39주
   - 성별: 남아
6. "아기 등록하기" 클릭
7. 로딩 표시 (CircularProgressIndicator)
8. API 호출 성공 → BabyProvider.baby 업데이트
9. MainScreen 자동 재구성
10. ScheduleScreen 표시 (모든 탭 활성화)
11. "스케줄이 생성되었습니다!" SnackBar
```

✅ **검증**:
- [x] BabyRegistrationScreen UI 표시
- [x] 폼 유효성 검사
- [x] API 호출 (createBaby)
- [x] 상태 업데이트 (notifyListeners)
- [x] UI 자동 전환

---

### 시나리오 2: 기상 시간 설정
```
1. ScheduleScreen 진입
2. 기상 시간 카드 클릭 ("07:00")
3. TimePicker 열림
4. 시간 선택: 06:30
5. "확인" 클릭
6. 로딩 표시 (56pt CircularProgressIndicator)
7. API 호출: generateAutoSchedule(babyId, 06:30)
8. 스케줄 항목 목록 표시:
   - 06:30 기상 (노란색)
   - 07:00 먹이기 (주황색)
   - 09:00 낮잠 (보라색)
   - 11:00 놀이 (초록색)
9. "스케줄이 생성되었습니다!" SnackBar
```

✅ **검증**:
- [x] TimePicker 동작
- [x] 로딩 상태 표시
- [x] API 호출 (generateAutoSchedule)
- [x] 스케줄 항목 파싱 및 표시
- [x] 타입별 색상 구분
- [x] SnackBar 알림

---

### 시나리오 3: 스케줄 항목 편집
```
1. 스케줄 항목 클릭 (예: "07:00 먹이기")
2. 편집 다이얼로그 열림
3. 시간 수정: 07:00 → 07:15
4. 활동명 수정: "아침 먹이기" → "첫 아침 먹이기"
5. "저장" 클릭
6. "스케줄이 저장되었습니다!" SnackBar
```

✅ **검증**:
- [x] Dialog UI 표시
- [x] 필드 수정 가능
- [x] 저장 처리 (로컬 상태 업데이트)

---

### 시나리오 4: 프로필 수정 (설정 탭)
```
1. 하단 네비게이션 "👤 설정" 클릭
2. ProfileScreen 표시
3. 아기 이름 "예준이" 클릭
4. 편집 모드 활성화 (TextField)
5. 이름 변경: "예준이" → "준호"
6. "저장" 버튼 클릭
7. API 호출: updateBabyInfo(babyId, "준호")
8. "아기 정보가 저장되었습니다!" SnackBar
9. 아기 정보 다시 표시 (갱신된 이름)
```

✅ **검증**:
- [x] ProfileScreen 표시
- [x] 이름 편집 가능
- [x] API 호출 (updateBabyInfo)
- [x] UI 업데이트
- [x] 알림 설정 토글 가능

---

## 📱 UI/UX 특징

### Material Design 3 적용
- ✅ 부드러운 모서리 (borderRadius: 12-24dp)
- ✅ 그래디언트 배경 (보라색 #667EEA → 분홍색 #764BA2)
- ✅ 박스 그림자 (elevation, shadow)
- ✅ 명확한 타이포그래피 (계층 구조)
- ✅ 색상 투명도 활용 (withOpacity)
- ✅ 일관된 간격 (padding, margin)

### 인터랙션
- ✅ 로딩 상태 표시 (CircularProgressIndicator)
- ✅ 성공/에러 메시지 (SnackBar)
- ✅ 포커스 상태 시각화 (border color 변경)
- ✅ 비활성화 상태 표시 (opacity 변경)
- ✅ 부드러운 전환 (자동 재구성)

---

## 🚀 다음 단계

### 추가 기능 (Optional)
1. **이미지 업로드**: 아기 사진 저장
2. **타임존 설정**: 지역별 시간대
3. **푸시 알림**: 스케줄 알림
4. **데이터 동기화**: 클라우드 백업
5. **통계 대시보드**: 수면 패턴 분석

### 성능 최적화
1. **이미지 캐싱**: 빠른 로딩
2. **배치 처리**: API 호출 최소화
3. **오프라인 모드**: 로컬 캐싱
4. **코드 분할**: 동적 로딩

---

## 📝 커밋 히스토리

```
e536f03 refactor: Restructure baby registration flow
3572de9 fix: Use ScheduleScreen instead of NewHomeScreen
6cb184a refactor: Modernize UI with Material Design 3
0e6d4ec fix: Use Opacity widget instead of Container opacity
```

---

## ✅ 완성 체크리스트

- [x] BabyRegistrationScreen 구현 및 스타일링
- [x] MainScreen 리팩토링 (조건부 렌더링)
- [x] ScheduleScreen 통합 (기상 시간 입력)
- [x] ProfileScreen 수정 (편집 전용)
- [x] Material Design 3 적용
- [x] API 연동 (create, update, auto-schedule)
- [x] 상태 관리 (Provider Pattern)
- [x] 에러 처리 및 사용자 피드백
- [x] 테스트 시나리오 검증

---

## 📞 문의

구현 내용이나 추가 기능 요청은 담당 개발자에게 문의하세요.

**최종 업데이트**: 2024-11-16
**상태**: 🎉 완성 - PR 준비 완료
