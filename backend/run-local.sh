#!/bin/bash

# Duty-Out Backend 로컬 실행 스크립트
# H2 인메모리 데이터베이스를 사용하여 추가 설정 없이 실행됩니다.

echo "육퇴 Backend를 로컬에서 실행 중입니다..."
echo ""

# dev 프로필로 실행
./gradlew bootRun --args='--spring.profiles.active=dev'
