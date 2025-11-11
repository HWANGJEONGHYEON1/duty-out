# 아기 수면 스케줄러 앱 - Backend API 명세서

## 📋 목차
1. [개요](#개요)
2. [데이터 모델](#데이터-모델)
3. [API 엔드포인트](#api-엔드포인트)
4. [에러 처리](#에러-처리)

---

## 개요

### 기술 스택
- **Backend Framework**: Spring Boot 3.x
- **Database**: PostgreSQL / MySQL
- **ORM**: JPA/Hibernate
- **Authentication**: JWT
- **API Documentation**: Swagger/OpenAPI

### Base URL
```
Production: https://api.baby-sleep-scheduler.com/api/v1
Development: http://localhost:8080/api/v1
```

### 인증
- JWT Bearer Token 기반 인증
- Header: `Authorization: Bearer {token}`

---

## 데이터 모델

### 1. User (사용자)
부모/보호자 정보

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
```

### 2. Baby (아기)
아기 프로필 정보

```sql
CREATE TABLE babies (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    birth_weeks INT DEFAULT 39,
    gender ENUM('MALE', 'FEMALE', 'OTHER'),
    profile_image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_babies_user_id ON babies(user_id);
```

**Java Model:**
```java
@Entity
@Table(name = "babies")
public class Baby {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    private String name;

    @Column(name = "birth_date", nullable = false)
    private LocalDate birthDate;

    @Column(name = "birth_weeks")
    private Integer birthWeeks = 39;

    @Enumerated(EnumType.STRING)
    private Gender gender;

    @Column(name = "profile_image_url")
    private String profileImageUrl;

    // Getters, Setters, Constructors
}
```

### 3. SleepRecord (수면 기록)
아기의 수면 기록

```sql
CREATE TABLE sleep_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    baby_id BIGINT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    type ENUM('NAP', 'NIGHT') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (baby_id) REFERENCES babies(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_sleep_records_baby_id ON sleep_records(baby_id);
CREATE INDEX idx_sleep_records_start_time ON sleep_records(start_time);
```

**Java Model:**
```java
@Entity
@Table(name = "sleep_records")
public class SleepRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "baby_id")
    private Baby baby;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SleepType type;

    private String notes;

    @Transient
    public int getDurationMinutes() {
        return (int) Duration.between(startTime, endTime).toMinutes();
    }
}
```

### 4. FeedingRecord (수유 기록)
아기의 수유 기록

```sql
CREATE TABLE feeding_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    baby_id BIGINT NOT NULL,
    time TIMESTAMP NOT NULL,
    amount INT NOT NULL, -- ml
    type ENUM('BREAST', 'BOTTLE', 'SOLID') DEFAULT 'BOTTLE',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (baby_id) REFERENCES babies(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_feeding_records_baby_id ON feeding_records(baby_id);
CREATE INDEX idx_feeding_records_time ON feeding_records(time);
```

### 5. ScheduleItem (스케줄 항목)
일일 스케줄 항목

```sql
CREATE TABLE schedule_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    baby_id BIGINT NOT NULL,
    time TIME NOT NULL,
    activity VARCHAR(200) NOT NULL,
    type ENUM('WAKE', 'SLEEP', 'FEED', 'PLAY') NOT NULL,
    duration_minutes INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (baby_id) REFERENCES babies(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_schedule_items_baby_id ON schedule_items(baby_id);
CREATE INDEX idx_schedule_items_time ON schedule_items(time);
```

### 6. CommunityPost (커뮤니티 게시글)
부모들의 커뮤니티 게시글

```sql
CREATE TABLE community_posts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    author_nickname VARCHAR(50) NOT NULL, -- 익명 닉네임
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at);
CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
```

### 7. Comment (댓글)
게시글의 댓글

```sql
CREATE TABLE comments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content TEXT NOT NULL,
    author_nickname VARCHAR(50) NOT NULL, -- 익명 닉네임
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);
```

### 8. PostLike (게시글 좋아요)
게시글 좋아요 관계

```sql
CREATE TABLE post_likes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    post_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_post_like (post_id, user_id)
);

-- Indexes
CREATE INDEX idx_post_likes_post_id ON post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON post_likes(user_id);
```

---

## API 엔드포인트

### 인증 (Authentication)

#### 1. 회원가입
```http
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123!",
  "name": "홍길동",
  "phone": "010-1234-5678"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

#### 2. 로그인
```http
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 86400
  }
}
```

---

### 아기 프로필 (Baby Profile)

#### 1. 아기 정보 등록
```http
POST /babies
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "민준이",
  "birthDate": "2024-07-01",
  "birthWeeks": 39,
  "gender": "MALE"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "민준이",
    "birthDate": "2024-07-01",
    "birthWeeks": 39,
    "gender": "MALE",
    "ageInMonths": 4,
    "ageInDays": 133,
    "ageText": "4개월 10일"
  }
}
```

#### 2. 아기 정보 조회
```http
GET /babies/{babyId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "민준이",
    "birthDate": "2024-07-01",
    "birthWeeks": 39,
    "gender": "MALE",
    "ageInMonths": 4,
    "ageInDays": 133,
    "ageText": "4개월 10일"
  }
}
```

#### 3. 아기 정보 수정
```http
PUT /babies/{babyId}
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "name": "민준이",
  "birthDate": "2024-07-01",
  "birthWeeks": 39,
  "gender": "MALE"
}
```

#### 4. 내 아기 목록 조회
```http
GET /babies
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "민준이",
      "birthDate": "2024-07-01",
      "ageText": "4개월 10일"
    }
  ]
}
```

---

### 수면 기록 (Sleep Records)

#### 1. 수면 기록 생성
```http
POST /babies/{babyId}/sleep-records
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "startTime": "2024-11-11T08:50:00",
  "endTime": "2024-11-11T10:00:00",
  "type": "NAP",
  "notes": "낮잠 1차"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "startTime": "2024-11-11T08:50:00",
    "endTime": "2024-11-11T10:00:00",
    "type": "NAP",
    "durationMinutes": 70,
    "notes": "낮잠 1차"
  }
}
```

#### 2. 수면 기록 목록 조회
```http
GET /babies/{babyId}/sleep-records?startDate=2024-11-01&endDate=2024-11-11
Authorization: Bearer {token}
```

**Query Parameters:**
- `startDate`: 시작 날짜 (YYYY-MM-DD)
- `endDate`: 종료 날짜 (YYYY-MM-DD)
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "startTime": "2024-11-11T08:50:00",
        "endTime": "2024-11-11T10:00:00",
        "type": "NAP",
        "durationMinutes": 70
      }
    ],
    "totalElements": 50,
    "totalPages": 3,
    "currentPage": 0
  }
}
```

#### 3. 수면 기록 수정
```http
PUT /babies/{babyId}/sleep-records/{recordId}
Authorization: Bearer {token}
```

#### 4. 수면 기록 삭제
```http
DELETE /babies/{babyId}/sleep-records/{recordId}
Authorization: Bearer {token}
```

#### 5. 오늘 수면 통계
```http
GET /babies/{babyId}/sleep-records/today-stats
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "totalMinutes": 540,
    "napCount": 3,
    "nightSleepMinutes": 270,
    "napMinutes": 270,
    "sleepGoalPercentage": 62.5
  }
}
```

---

### 수유 기록 (Feeding Records)

#### 1. 수유 기록 생성
```http
POST /babies/{babyId}/feeding-records
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "time": "2024-11-11T10:00:00",
  "amount": 180,
  "type": "BOTTLE",
  "notes": "아침 수유"
}
```

#### 2. 수유 기록 목록 조회
```http
GET /babies/{babyId}/feeding-records?startDate=2024-11-01&endDate=2024-11-11
Authorization: Bearer {token}
```

#### 3. 오늘 수유 통계
```http
GET /babies/{babyId}/feeding-records/today-stats
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "totalAmount": 710,
    "feedingCount": 4,
    "averageAmount": 177.5,
    "records": [
      {
        "time": "2024-11-11T06:30:00",
        "amount": 180
      }
    ]
  }
}
```

---

### 스케줄 (Schedule)

#### 1. 스케줄 생성
```http
POST /babies/{babyId}/schedules
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "time": "07:00",
  "activity": "기상 및 수유",
  "type": "WAKE",
  "durationMinutes": null
}
```

#### 2. 스케줄 목록 조회
```http
GET /babies/{babyId}/schedules
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "time": "07:00",
      "activity": "기상 및 수유",
      "type": "WAKE",
      "durationMinutes": null,
      "timeString": "07:00"
    },
    {
      "id": 2,
      "time": "08:50",
      "activity": "낮잠 1",
      "type": "SLEEP",
      "durationMinutes": 70,
      "timeString": "08:50",
      "durationString": "1시간 10분"
    }
  ]
}
```

#### 3. 다음 스케줄 조회
```http
GET /babies/{babyId}/schedules/next
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "scheduleItem": {
      "id": 2,
      "time": "08:50",
      "activity": "낮잠 1",
      "type": "SLEEP"
    },
    "minutesUntilNext": 45
  }
}
```

#### 4. 스케줄 수정
```http
PUT /babies/{babyId}/schedules/{scheduleId}
Authorization: Bearer {token}
```

#### 5. 스케줄 삭제
```http
DELETE /babies/{babyId}/schedules/{scheduleId}
Authorization: Bearer {token}
```

---

### 통계 (Statistics)

#### 1. 주간 수면 통계
```http
GET /babies/{babyId}/statistics/weekly-sleep
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "weeklyData": [840, 810, 870, 795, 900, 855, 880],
    "days": ["월", "화", "수", "목", "금", "토", "일"],
    "averageMinutes": 850,
    "totalMinutes": 5950
  }
}
```

#### 2. 주간 수유 통계
```http
GET /babies/{babyId}/statistics/weekly-feeding
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "weeklyData": [800, 850, 900, 820, 880, 900, 870],
    "days": ["월", "화", "수", "목", "금", "토", "일"],
    "averageAmount": 860,
    "totalAmount": 6020
  }
}
```

---

### 커뮤니티 (Community)

#### 1. 게시글 목록 조회
```http
GET /community/posts?page=0&size=20&sort=createdAt,desc
Authorization: Bearer {token}
```

**Query Parameters:**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)
- `sort`: 정렬 기준 (createdAt,desc | likes,desc)

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "title": "4개월 아기 밤잠 통잠 성공했어요!",
        "content": "드디어 통잠 성공했어요...",
        "authorNickname": "익명1",
        "likesCount": 15,
        "commentsCount": 8,
        "createdAt": "2024-11-11T10:00:00",
        "isLikedByMe": false
      }
    ],
    "totalElements": 100,
    "totalPages": 5,
    "currentPage": 0
  }
}
```

#### 2. 게시글 상세 조회
```http
GET /community/posts/{postId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "4개월 아기 밤잠 통잠 성공했어요!",
    "content": "드디어 통잠 성공했어요. 수면교육 시작한지 2주만에...",
    "authorNickname": "익명1",
    "likesCount": 15,
    "commentsCount": 8,
    "createdAt": "2024-11-11T10:00:00",
    "updatedAt": "2024-11-11T10:00:00",
    "isLikedByMe": false,
    "isMine": false
  }
}
```

#### 3. 게시글 작성
```http
POST /community/posts
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "4개월 아기 밤잠 통잠 성공했어요!",
  "content": "드디어 통잠 성공했어요. 수면교육 시작한지 2주만에...",
  "authorNickname": "익명123"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "4개월 아기 밤잠 통잠 성공했어요!",
    "content": "드디어 통잠 성공했어요...",
    "authorNickname": "익명123",
    "createdAt": "2024-11-11T10:00:00"
  }
}
```

#### 4. 게시글 수정
```http
PUT /community/posts/{postId}
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "title": "수정된 제목",
  "content": "수정된 내용"
}
```

#### 5. 게시글 삭제
```http
DELETE /community/posts/{postId}
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "게시글이 삭제되었습니다."
}
```

#### 6. 게시글 좋아요
```http
POST /community/posts/{postId}/like
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "isLiked": true,
    "likesCount": 16
  }
}
```

#### 7. 게시글 좋아요 취소
```http
DELETE /community/posts/{postId}/like
Authorization: Bearer {token}
```

---

### 댓글 (Comments)

#### 1. 댓글 목록 조회
```http
GET /community/posts/{postId}/comments?page=0&size=20
Authorization: Bearer {token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "postId": 1,
        "content": "축하드려요! 수면교육 방법 공유해주시면 감사하겠습니다.",
        "authorNickname": "익명10",
        "createdAt": "2024-11-11T11:00:00",
        "isMine": false
      }
    ],
    "totalElements": 8,
    "totalPages": 1,
    "currentPage": 0
  }
}
```

#### 2. 댓글 작성
```http
POST /community/posts/{postId}/comments
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "content": "축하드려요! 수면교육 방법 공유해주시면 감사하겠습니다.",
  "authorNickname": "익명10"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "postId": 1,
    "content": "축하드려요!",
    "authorNickname": "익명10",
    "createdAt": "2024-11-11T11:00:00"
  }
}
```

#### 3. 댓글 수정
```http
PUT /community/posts/{postId}/comments/{commentId}
Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "content": "수정된 댓글 내용"
}
```

#### 4. 댓글 삭제
```http
DELETE /community/posts/{postId}/comments/{commentId}
Authorization: Bearer {token}
```

---

## 에러 처리

### 에러 응답 형식
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": "상세 에러 정보 (optional)"
  }
}
```

### HTTP 상태 코드

| 코드 | 설명 |
|------|------|
| 200 | OK - 성공 |
| 201 | Created - 리소스 생성 성공 |
| 204 | No Content - 성공 (응답 본문 없음) |
| 400 | Bad Request - 잘못된 요청 |
| 401 | Unauthorized - 인증 실패 |
| 403 | Forbidden - 권한 없음 |
| 404 | Not Found - 리소스 없음 |
| 409 | Conflict - 리소스 충돌 |
| 500 | Internal Server Error - 서버 오류 |

### 에러 코드

| 코드 | 메시지 | 설명 |
|------|--------|------|
| AUTH_001 | 인증 토큰이 없습니다 | Authorization 헤더 누락 |
| AUTH_002 | 유효하지 않은 토큰입니다 | JWT 토큰 검증 실패 |
| AUTH_003 | 만료된 토큰입니다 | JWT 토큰 만료 |
| USER_001 | 이미 존재하는 이메일입니다 | 회원가입 시 이메일 중복 |
| USER_002 | 사용자를 찾을 수 없습니다 | 존재하지 않는 사용자 |
| BABY_001 | 아기 정보를 찾을 수 없습니다 | 존재하지 않는 아기 ID |
| BABY_002 | 접근 권한이 없습니다 | 다른 사용자의 아기 정보 접근 |
| POST_001 | 게시글을 찾을 수 없습니다 | 존재하지 않는 게시글 |
| POST_002 | 게시글 수정 권한이 없습니다 | 작성자가 아닌 사용자의 수정 시도 |
| COMMENT_001 | 댓글을 찾을 수 없습니다 | 존재하지 않는 댓글 |
| VALIDATION_001 | 유효하지 않은 입력값입니다 | 입력 검증 실패 |

---

## 페이지네이션

모든 목록 조회 API는 페이지네이션을 지원합니다.

### 요청 파라미터
- `page`: 페이지 번호 (0부터 시작, default: 0)
- `size`: 페이지 크기 (default: 20, max: 100)
- `sort`: 정렬 기준 (예: createdAt,desc)

### 응답 형식
```json
{
  "content": [],
  "totalElements": 100,
  "totalPages": 5,
  "currentPage": 0,
  "size": 20,
  "hasNext": true,
  "hasPrevious": false
}
```

---

## 보안 고려사항

1. **비밀번호**: BCrypt로 암호화 저장
2. **JWT 토큰**:
   - Access Token 유효기간: 24시간
   - Refresh Token 유효기간: 30일
3. **CORS**: 허용된 도메인만 접근 가능
4. **Rate Limiting**: IP당 분당 100 요청 제한
5. **XSS/SQL Injection**: 입력값 검증 및 sanitization

---

## 추가 기능 제안

### Phase 2
- [ ] Push 알림 (FCM)
- [ ] 이미지 업로드 (프로필 사진, 게시글 이미지)
- [ ] 아기 성장 차트
- [ ] 백신 접종 기록
- [ ] 육아 일기

### Phase 3
- [ ] 실시간 채팅
- [ ] 소셜 로그인 (Google, Apple, Kakao)
- [ ] 데이터 내보내기 (CSV, PDF)
- [ ] AI 기반 수면 패턴 분석
- [ ] 다중 아기 지원 개선

---

## 참고사항

- 모든 날짜/시간은 ISO 8601 형식 사용 (YYYY-MM-DDTHH:mm:ss)
- 시간대(Timezone)는 클라이언트에서 로컬 시간으로 변환
- 모든 텍스트는 UTF-8 인코딩
- API 버전은 URL에 포함 (/api/v1/)
