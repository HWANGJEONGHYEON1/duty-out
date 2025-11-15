#!/bin/bash

# Duty-Out Flutter App 로컬 실행 스크립트
# Android 에뮬레이터 또는 연결된 디바이스에서 실행됩니다.

echo "육퇴 Flutter App을 로컬에서 실행 중입니다..."
echo ""

# 필요한 의존성 받기
echo "의존성을 받는 중..."
flutter pub get

echo ""
echo "앱을 실행 중입니다..."

# 앱 실행
flutter run
