# 아기 수면 스케줄러 (Baby Sleep Scheduler)

아기의 수면 패턴을 관리하고 추적하는 Flutter 애플리케이션입니다.

## 주요 기능

- **수면 기록**: 아기의 수면 시작/종료 시간을 기록하고 관리
- **자동 스케줄 생성**: 월령에 맞는 수면 스케줄 자동 생성
- **수면 통계**: 수면 패턴을 시각화하고 분석
- **프로필 관리**: 아기 정보 등록 및 관리

## 시작하기

### 필수 요구사항

- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상
- Android Studio / Xcode (플랫폼별 개발 도구)

### 설치 방법

1. 저장소 클론
```bash
git clone <repository-url>
cd duty-out/flutter_baby_sleep_app
```

2. 의존성 설치
```bash
flutter pub get
```

3. Flutter SDK 경로 설정 (Android)

   `android/local.properties` 파일을 생성하고 Flutter SDK 경로를 추가:
```properties
flutter.sdk=/path/to/flutter/sdk
```

4. 앱 실행
```bash
# Android
flutter run

# iOS (macOS에서만)
flutter run -d ios

# Web
flutter run -d chrome
```

## 프로젝트 구조

```
flutter_baby_sleep_app/
├── lib/
│   ├── main.dart                 # 앱 진입점
│   ├── providers/                # 상태 관리 (Provider)
│   │   ├── baby_provider.dart
│   │   ├── schedule_provider.dart
│   │   └── sleep_record_provider.dart
│   └── screens/                  # UI 화면
│       ├── home_screen.dart
│       ├── schedule_screen.dart
│       ├── statistics_screen.dart
│       ├── profile_screen.dart
│       └── sleep_tracking_screen.dart
├── android/                      # Android 플랫폼 설정
├── ios/                         # iOS 플랫폼 설정
├── web/                         # Web 플랫폼 설정
└── pubspec.yaml                 # 프로젝트 의존성
```

## 사용 기술

- **Flutter**: UI 프레임워크
- **Provider**: 상태 관리
- **Material Design**: UI 디자인
- **fl_chart**: 차트 및 그래프 (통계 화면)
- **shared_preferences**: 로컬 데이터 저장

## 개발

### 디버그 모드 실행
```bash
flutter run
```

### 릴리스 빌드
```bash
# Android APK
flutter build apk --release

# iOS (macOS에서만)
flutter build ios --release

# Web
flutter build web
```

### 코드 포맷팅
```bash
flutter format .
```

### 정적 분석
```bash
flutter analyze
```

## 백엔드 연동

이 Flutter 앱은 Spring Boot 백엔드와 연동할 수 있습니다.

백엔드 설정:
1. `backend/` 디렉토리로 이동
2. Spring Boot 애플리케이션 실행
3. Flutter 앱에서 API 엔드포인트 설정 (필요시)

## 트러블슈팅

### Android 빌드 에러
- `android/local.properties`에 Flutter SDK 경로가 올바르게 설정되어 있는지 확인
- `flutter clean` 후 `flutter pub get` 실행

### iOS 빌드 에러
- `cd ios && pod install` 실행
- Xcode에서 Signing & Capabilities 설정 확인

### 의존성 에러
```bash
flutter clean
flutter pub get
```

## 라이선스

이 프로젝트는 개인 프로젝트입니다.

## 기여

프로젝트에 대한 제안이나 버그 리포트는 이슈로 등록해 주세요.
