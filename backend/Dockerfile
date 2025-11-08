FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Gradle 파일 복사
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle

# 소스 코드 복사
COPY src ./src

# 빌드
RUN chmod +x gradlew
RUN ./gradlew build -x test

# 실행 이미지
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# JAR 파일 복사
COPY --from=build /app/build/libs/*.jar app.jar

# 포트 노출
EXPOSE 8080

# 실행
ENTRYPOINT ["java", "-jar", "app.jar"]
