# 육퇴의 정석 - Mobile (Flutter)

아기 수면 교육 앱 모바일 클라이언트

## 🌟 핵심 기능

- **스케줄 자동 생성**: 기상시간 입력 → 개월별 맞춤 스케줄 자동 표시
- **수면 기록**: 원터치 수면 시작/종료 기록
- **통계 대시보드**: 일/주/월 수면 패턴 분석
- **OAuth 로그인**: 카카오, 구글 소셜 로그인

## 🛠 기술 스택

- **Framework**: Flutter 3.2+
- **Language**: Dart 3.2+
- **Architecture**: Clean Architecture
- **State Management**: BLoC Pattern (flutter_bloc)
- **Network**: Dio + Retrofit
- **Local Storage**: Hive + SharedPreferences
- **DI**: GetIt + Injectable
- **Error Handling**: Dartz (Either)

## 📁 프로젝트 구조

```
mobile/lib/
├── core/                    # 공통 기능
│   ├── constants/          # 상수
│   ├── error/              # 에러 처리
│   ├── network/            # 네트워크 설정
│   └── utils/              # 유틸리티
├── features/                # 기능별 모듈
│   ├── auth/               # 인증
│   ├── baby/               # 아기 프로필
│   ├── schedule/           # 스케줄 (핵심)
│   │   ├── data/
│   │   │   ├── datasources/   # API, Local DB
│   │   │   ├── models/        # DTO
│   │   │   └── repositories/  # Repository 구현
│   │   ├── domain/
│   │   │   ├── entities/      # 도메인 모델
│   │   │   ├── repositories/  # Repository 인터페이스
│   │   │   └── usecases/      # 비즈니스 로직
│   │   └── presentation/
│   │       ├── bloc/          # BLoC
│   │       ├── pages/         # 화면
│   │       └── widgets/       # 위젯
│   └── sleep_record/       # 수면 기록
└── main.dart
```

## 🚀 시작하기

### 사전 요구사항

- Flutter SDK 3.2+
- Dart SDK 3.2+
- Android Studio / Xcode

### 설치 및 실행

```bash
# 1. 프로젝트 이동
cd mobile

# 2. 패키지 설치
flutter pub get

# 3. 코드 생성 (모델, Retrofit 등)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. 실행
flutter run
```

### 빌드

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Android App Bundle (Play Store)
flutter build appbundle
```

## 🧪 테스트

```bash
# 단위 테스트
flutter test

# 위젯 테스트
flutter test test/widget_test.dart

# 통합 테스트
flutter drive --target=test_driver/app.dart
```

## 📱 주요 화면

### 메인 대시보드
- 오늘의 스케줄 타임라인
- 다음 일정까지 카운트다운
- 빠른 수면 기록 버튼

### 스케줄 편집 화면
- 기상시간 입력 → 자동 스케줄 생성
- 드래그로 일정 시간 조정
- 일정별 메모 추가

### 통계 화면
- 일/주/월 탭 전환
- 수면 패턴 그래프
- 목표 달성률

## 🎨 디자인 시스템

```dart
// 주요 색상
primaryColor: Colors.blue
accentColor: Colors.blueAccent

// 타이포그래피
fontFamily: NotoSans
headlineSize: 24.0
bodySize: 16.0
```

## 🔌 API 연동

백엔드 서버 URL 설정:
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'http://your-backend-url:8080';
```

## 📝 개발 가이드

- [개발 가이드라인](../DEVELOPMENT_GUIDELINES.md) 참고
- Clean Architecture & SOLID 원칙 준수
- BLoC 패턴 사용
- const 생성자 사용으로 성능 최적화
- Either<Failure, T> 로 에러 처리

## 🏗 핵심 로직

### 스케줄 생성 플로우

1. 사용자가 기상시간 입력
2. `GenerateScheduleUseCase` 호출
3. `ScheduleRepository` → 백엔드 API 요청
4. 생성된 스케줄을 BLoC으로 상태 업데이트
5. UI에 스케줄 타임라인 표시

## 🔐 환경 설정

```
# .env 파일 (루트)
API_BASE_URL=http://localhost:8080
KAKAO_APP_KEY=your-kakao-app-key
GOOGLE_CLIENT_ID=your-google-client-id
```

## 📄 라이선스

MIT License
