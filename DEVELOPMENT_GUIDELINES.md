# 🚀 육퇴의 정석 - 개발 가이드라인

> 아기 수면 교육 앱을 위한 Flutter & Spring Boot 실무 개발 규칙

---

## 📋 목차

1. [공통 개발 원칙](#1-공통-개발-원칙)
2. [Flutter 개발 가이드](#2-flutter-개발-가이드)
3. [Spring Boot 개발 가이드](#3-spring-boot-개발-가이드)
4. [API 설계 규칙](#4-api-설계-규칙)
5. [Git 브랜치 전략](#5-git-브랜치-전략)
6. [코드 리뷰 체크리스트](#6-코드-리뷰-체크리스트)

---

## 1. 공통 개발 원칙

### 1.1 클린 코드 (Clean Code)

#### ✅ DO
```java
// 명확하고 의미있는 이름 사용
public class BabySleepScheduleService {
    public SleepSchedule generateDailySchedule(LocalTime wakeUpTime, int ageInMonths) {
        // ...
    }
}
```

```dart
// Flutter
class SleepScheduleWidget extends StatelessWidget {
  final SleepSchedule schedule;

  const SleepScheduleWidget({
    Key? key,
    required this.schedule,
  }) : super(key: key);
}
```

#### ❌ DON'T
```java
// 축약어, 모호한 이름 사용
public class BSSvc {
    public SS genDaily(LT wt, int a) { // 이해 불가능
        // ...
    }
}
```

### 1.2 SOLID 원칙

#### Single Responsibility Principle (단일 책임 원칙)
```java
// ❌ BAD: 여러 책임을 가진 클래스
public class BabyService {
    public void saveBaby(Baby baby) { }
    public void sendNotification(String message) { } // 책임 분리 필요
    public void generatePdfReport() { } // 책임 분리 필요
}

// ✅ GOOD: 책임 분리
public class BabyService {
    public void saveBaby(Baby baby) { }
}

public class NotificationService {
    public void sendNotification(String message) { }
}

public class ReportService {
    public void generatePdfReport() { }
}
```

#### Dependency Inversion Principle (의존성 역전 원칙)
```dart
// ✅ GOOD: 추상화에 의존
abstract class SleepRepository {
  Future<List<SleepRecord>> findByDate(DateTime date);
}

class SleepRepositoryImpl implements SleepRepository {
  @override
  Future<List<SleepRecord>> findByDate(DateTime date) async {
    // 구현
  }
}

class SleepBloc {
  final SleepRepository repository; // 구체 클래스가 아닌 인터페이스에 의존

  SleepBloc(this.repository);
}
```

### 1.3 DRY (Don't Repeat Yourself)

```java
// ❌ BAD: 중복 코드
public void calculateNap1Time() {
    LocalTime napTime = wakeUpTime.plusHours(2);
    // 검증 로직
}

public void calculateNap2Time() {
    LocalTime napTime = nap1EndTime.plusHours(2);
    // 동일한 검증 로직 반복
}

// ✅ GOOD: 공통 로직 추출
private LocalTime calculateNextNapTime(LocalTime baseTime, int wakeWindowHours) {
    LocalTime napTime = baseTime.plusHours(wakeWindowHours);
    validateNapTime(napTime);
    return napTime;
}
```

---

## 2. Flutter 개발 가이드

### 2.1 프로젝트 구조 (Clean Architecture)

```
lib/
├── core/                        # 공통 기능
│   ├── constants/              # 상수
│   ├── error/                  # 에러 처리
│   ├── network/                # 네트워크 설정
│   └── utils/                  # 유틸리티
├── features/                    # 기능별 모듈
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/   # API, Local DB
│   │   │   ├── models/        # DTO (JSON 변환)
│   │   │   └── repositories/  # Repository 구현
│   │   ├── domain/
│   │   │   ├── entities/      # 비즈니스 모델
│   │   │   ├── repositories/  # Repository 인터페이스
│   │   │   └── usecases/      # 비즈니스 로직
│   │   └── presentation/
│   │       ├── bloc/          # 상태 관리 (BLoC)
│   │       ├── pages/         # 화면
│   │       └── widgets/       # 위젯
│   ├── sleep_schedule/
│   └── sleep_tracking/
└── main.dart
```

### 2.2 상태 관리 (BLoC Pattern)

#### ✅ 권장: BLoC 패턴 사용

```dart
// Event
abstract class SleepScheduleEvent {}

class LoadSchedule extends SleepScheduleEvent {
  final DateTime date;
  LoadSchedule(this.date);
}

class UpdateWakeUpTime extends SleepScheduleEvent {
  final TimeOfDay wakeUpTime;
  UpdateWakeUpTime(this.wakeUpTime);
}

// State
abstract class SleepScheduleState {}

class SleepScheduleLoading extends SleepScheduleState {}

class SleepScheduleLoaded extends SleepScheduleState {
  final SleepSchedule schedule;
  SleepScheduleLoaded(this.schedule);
}

class SleepScheduleError extends SleepScheduleState {
  final String message;
  SleepScheduleError(this.message);
}

// BLoC
class SleepScheduleBloc extends Bloc<SleepScheduleEvent, SleepScheduleState> {
  final GetScheduleUseCase getScheduleUseCase;
  final UpdateScheduleUseCase updateScheduleUseCase;

  SleepScheduleBloc({
    required this.getScheduleUseCase,
    required this.updateScheduleUseCase,
  }) : super(SleepScheduleLoading()) {
    on<LoadSchedule>(_onLoadSchedule);
    on<UpdateWakeUpTime>(_onUpdateWakeUpTime);
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<SleepScheduleState> emit,
  ) async {
    emit(SleepScheduleLoading());

    final result = await getScheduleUseCase(event.date);

    result.fold(
      (failure) => emit(SleepScheduleError(failure.message)),
      (schedule) => emit(SleepScheduleLoaded(schedule)),
    );
  }

  Future<void> _onUpdateWakeUpTime(
    UpdateWakeUpTime event,
    Emitter<SleepScheduleState> emit,
  ) async {
    // 구현
  }
}
```

### 2.3 Use Case 패턴

```dart
// ✅ GOOD: 단일 책임을 가진 UseCase
class GetScheduleUseCase {
  final SleepScheduleRepository repository;

  GetScheduleUseCase(this.repository);

  Future<Either<Failure, SleepSchedule>> call(DateTime date) async {
    try {
      final schedule = await repository.getScheduleByDate(date);
      return Right(schedule);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

### 2.4 Widget 설계 원칙

#### 작은 위젯으로 분리
```dart
// ❌ BAD: 하나의 거대한 위젯
class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 100줄 이상의 복잡한 UI
        ],
      ),
    );
  }
}

// ✅ GOOD: 작은 위젯으로 분리
class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ScheduleHeader(),
          ScheduleTimeline(),
          QuickActionButtons(),
        ],
      ),
    );
  }
}

class ScheduleHeader extends StatelessWidget {
  // ...
}

class ScheduleTimeline extends StatelessWidget {
  // ...
}
```

#### const 생성자 사용
```dart
// ✅ GOOD: 성능 최적화
class ScheduleItem extends StatelessWidget {
  final String title;
  final TimeOfDay time;

  const ScheduleItem({
    Key? key,
    required this.title,
    required this.time,
  }) : super(key: key);
}
```

### 2.5 에러 처리

```dart
// ✅ GOOD: Either 타입으로 에러 처리
abstract class Failure {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({required String message}) : super(message: message);
}

// Repository
Future<Either<Failure, List<SleepRecord>>> getSleepRecords() async {
  try {
    final records = await remoteDataSource.getSleepRecords();
    return Right(records);
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message));
  } catch (e) {
    return Left(ServerFailure(message: '알 수 없는 오류가 발생했습니다.'));
  }
}
```

### 2.6 Flutter 주의사항

#### 1. 메모리 누수 방지
```dart
class _SchedulePageState extends State<SchedulePage> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = someStream.listen((data) {
      // ...
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // ✅ 반드시 구독 해제
    super.dispose();
  }
}
```

#### 2. BuildContext 사용 주의
```dart
// ❌ BAD: 비동기 후 context 사용
Future<void> loadData() async {
  await repository.getData();
  Navigator.push(context, ...); // 위험: context가 유효하지 않을 수 있음
}

// ✅ GOOD: mounted 체크
Future<void> loadData() async {
  await repository.getData();
  if (!mounted) return;
  Navigator.push(context, ...);
}
```

#### 3. ListView 성능 최적화
```dart
// ✅ GOOD: ListView.builder 사용
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ScheduleItemWidget(item: items[index]);
  },
)
```

---

## 3. Spring Boot 개발 가이드

### 3.1 프로젝트 구조 (Layered Architecture)

```
src/main/java/com/dutyout/
├── domain/                      # 도메인 계층
│   ├── baby/
│   │   ├── entity/
│   │   │   └── Baby.java
│   │   ├── repository/
│   │   │   └── BabyRepository.java
│   │   └── service/
│   │       ├── BabyService.java
│   │       └── BabyServiceImpl.java
│   ├── sleep/
│   └── schedule/
├── application/                 # 애플리케이션 계층
│   ├── dto/
│   │   ├── request/
│   │   │   └── CreateBabyRequest.java
│   │   └── response/
│   │       └── BabyResponse.java
│   └── usecase/
│       └── CreateBabyUseCase.java
├── presentation/                # 프레젠테이션 계층
│   └── controller/
│       └── BabyController.java
├── infrastructure/              # 인프라 계층
│   ├── config/
│   │   ├── SecurityConfig.java
│   │   └── JpaConfig.java
│   ├── external/
│   │   └── FcmClient.java
│   └── persistence/
│       └── JpaBabyRepository.java
└── common/                      # 공통
    ├── exception/
    ├── response/
    └── util/
```

### 3.2 Entity 설계

```java
// ✅ GOOD: JPA Entity
@Entity
@Table(name = "babies")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Baby extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(nullable = false)
    private LocalDate birthDate;

    @Column
    private Integer gestationalWeeks; // 출생 주수

    @Enumerated(EnumType.STRING)
    @Column(length = 10)
    private Gender gender;

    @Column(length = 500)
    private String profileImage;

    @Builder
    private Baby(Long userId, String name, LocalDate birthDate,
                 Integer gestationalWeeks, Gender gender) {
        validateUserId(userId);
        validateName(name);
        validateBirthDate(birthDate);

        this.userId = userId;
        this.name = name;
        this.birthDate = birthDate;
        this.gestationalWeeks = gestationalWeeks;
        this.gender = gender;
    }

    // ✅ 도메인 로직은 엔티티에
    public int calculateAgeInMonths() {
        return (int) ChronoUnit.MONTHS.between(birthDate, LocalDate.now());
    }

    public int calculateCorrectedAgeInMonths() {
        if (gestationalWeeks == null || gestationalWeeks >= 37) {
            return calculateAgeInMonths();
        }

        int weeksPremature = 40 - gestationalWeeks;
        LocalDate correctedBirthDate = birthDate.plusWeeks(weeksPremature);
        return (int) ChronoUnit.MONTHS.between(correctedBirthDate, LocalDate.now());
    }

    // ✅ 검증 로직
    private void validateUserId(Long userId) {
        if (userId == null || userId <= 0) {
            throw new IllegalArgumentException("유효하지 않은 사용자 ID입니다.");
        }
    }

    private void validateName(String name) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("이름은 필수입니다.");
        }
        if (name.length() > 50) {
            throw new IllegalArgumentException("이름은 50자를 초과할 수 없습니다.");
        }
    }

    private void validateBirthDate(LocalDate birthDate) {
        if (birthDate == null) {
            throw new IllegalArgumentException("생년월일은 필수입니다.");
        }
        if (birthDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("생년월일은 미래일 수 없습니다.");
        }
    }

    public void updateProfile(String name, String profileImage) {
        validateName(name);
        this.name = name;
        this.profileImage = profileImage;
    }
}

// BaseTimeEntity
@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter
public abstract class BaseTimeEntity {

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime modifiedAt;
}
```

### 3.3 Service 계층

```java
// ✅ GOOD: 인터페이스와 구현 분리
public interface BabyService {
    BabyResponse createBaby(CreateBabyRequest request);
    BabyResponse getBaby(Long babyId);
    List<BabyResponse> getBabiesByUserId(Long userId);
    BabyResponse updateBaby(Long babyId, UpdateBabyRequest request);
    void deleteBaby(Long babyId);
}

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BabyServiceImpl implements BabyService {

    private final BabyRepository babyRepository;
    private final UserService userService;

    @Override
    @Transactional
    public BabyResponse createBaby(CreateBabyRequest request) {
        // 1. 사용자 검증
        userService.validateUser(request.getUserId());

        // 2. 도메인 객체 생성
        Baby baby = Baby.builder()
                .userId(request.getUserId())
                .name(request.getName())
                .birthDate(request.getBirthDate())
                .gestationalWeeks(request.getGestationalWeeks())
                .gender(request.getGender())
                .build();

        // 3. 저장
        Baby savedBaby = babyRepository.save(baby);

        // 4. DTO 변환
        return BabyResponse.from(savedBaby);
    }

    @Override
    public BabyResponse getBaby(Long babyId) {
        Baby baby = babyRepository.findById(babyId)
                .orElseThrow(() -> new BabyNotFoundException("아기 정보를 찾을 수 없습니다."));

        return BabyResponse.from(baby);
    }

    @Override
    public List<BabyResponse> getBabiesByUserId(Long userId) {
        List<Baby> babies = babyRepository.findByUserId(userId);

        return babies.stream()
                .map(BabyResponse::from)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public BabyResponse updateBaby(Long babyId, UpdateBabyRequest request) {
        Baby baby = babyRepository.findById(babyId)
                .orElseThrow(() -> new BabyNotFoundException("아기 정보를 찾을 수 없습니다."));

        // ✅ 엔티티의 도메인 메서드 사용
        baby.updateProfile(request.getName(), request.getProfileImage());

        return BabyResponse.from(baby);
    }

    @Override
    @Transactional
    public void deleteBaby(Long babyId) {
        if (!babyRepository.existsById(babyId)) {
            throw new BabyNotFoundException("아기 정보를 찾을 수 없습니다.");
        }

        babyRepository.deleteById(babyId);
    }
}
```

### 3.4 Controller 설계

```java
@RestController
@RequestMapping("/api/v1/babies")
@RequiredArgsConstructor
@Tag(name = "Baby", description = "아기 프로필 관리 API")
public class BabyController {

    private final BabyService babyService;

    @PostMapping
    @Operation(summary = "아기 프로필 생성", description = "새로운 아기 프로필을 생성합니다.")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "생성 성공"),
        @ApiResponse(responseCode = "400", description = "잘못된 요청"),
        @ApiResponse(responseCode = "401", description = "인증 실패")
    })
    public ResponseEntity<ApiResponse<BabyResponse>> createBaby(
            @Valid @RequestBody CreateBabyRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {

        request.setUserId(Long.parseLong(userDetails.getUsername()));

        BabyResponse response = babyService.createBaby(request);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(ApiResponse.success(response));
    }

    @GetMapping("/{babyId}")
    @Operation(summary = "아기 프로필 조회", description = "아기 프로필을 조회합니다.")
    public ResponseEntity<ApiResponse<BabyResponse>> getBaby(
            @PathVariable Long babyId,
            @AuthenticationPrincipal UserDetails userDetails) {

        BabyResponse response = babyService.getBaby(babyId);

        // ✅ 권한 체크
        if (!response.getUserId().equals(Long.parseLong(userDetails.getUsername()))) {
            throw new UnauthorizedException("접근 권한이 없습니다.");
        }

        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @GetMapping
    @Operation(summary = "내 아기 목록 조회", description = "로그인한 사용자의 아기 목록을 조회합니다.")
    public ResponseEntity<ApiResponse<List<BabyResponse>>> getMyBabies(
            @AuthenticationPrincipal UserDetails userDetails) {

        Long userId = Long.parseLong(userDetails.getUsername());
        List<BabyResponse> responses = babyService.getBabiesByUserId(userId);

        return ResponseEntity.ok(ApiResponse.success(responses));
    }
}
```

### 3.5 DTO 설계

```java
// Request DTO
@Getter
@Setter
@NoArgsConstructor
public class CreateBabyRequest {

    private Long userId; // Controller에서 설정

    @NotBlank(message = "이름은 필수입니다.")
    @Size(max = 50, message = "이름은 50자를 초과할 수 없습니다.")
    private String name;

    @NotNull(message = "생년월일은 필수입니다.")
    @PastOrPresent(message = "생년월일은 미래일 수 없습니다.")
    private LocalDate birthDate;

    @Min(value = 22, message = "출생 주수는 22주 이상이어야 합니다.")
    @Max(value = 42, message = "출생 주수는 42주 이하여야 합니다.")
    private Integer gestationalWeeks;

    private Gender gender;
}

// Response DTO
@Getter
@Builder
public class BabyResponse {

    private Long id;
    private Long userId;
    private String name;
    private LocalDate birthDate;
    private Integer gestationalWeeks;
    private Gender gender;
    private String profileImage;
    private int ageInMonths;
    private int correctedAgeInMonths;
    private LocalDateTime createdAt;

    // ✅ Entity -> DTO 변환 메서드
    public static BabyResponse from(Baby baby) {
        return BabyResponse.builder()
                .id(baby.getId())
                .userId(baby.getUserId())
                .name(baby.getName())
                .birthDate(baby.getBirthDate())
                .gestationalWeeks(baby.getGestationalWeeks())
                .gender(baby.getGender())
                .profileImage(baby.getProfileImage())
                .ageInMonths(baby.calculateAgeInMonths())
                .correctedAgeInMonths(baby.calculateCorrectedAgeInMonths())
                .createdAt(baby.getCreatedAt())
                .build();
    }
}
```

### 3.6 예외 처리

```java
// Custom Exception
@Getter
public class BabyNotFoundException extends RuntimeException {
    private final String code = "BABY_NOT_FOUND";

    public BabyNotFoundException(String message) {
        super(message);
    }
}

// Global Exception Handler
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(BabyNotFoundException.class)
    public ResponseEntity<ApiResponse<Void>> handleBabyNotFoundException(
            BabyNotFoundException ex) {

        log.error("BabyNotFoundException: {}", ex.getMessage());

        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(ex.getCode(), ex.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Map<String, String>>> handleValidationException(
            MethodArgumentNotValidException ex) {

        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage())
        );

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error("VALIDATION_ERROR", "입력값 검증 실패", errors));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleException(Exception ex) {
        log.error("Unexpected error", ex);

        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("INTERNAL_ERROR", "서버 오류가 발생했습니다."));
    }
}
```

### 3.7 Spring Boot 주의사항

#### 1. N+1 문제 방지
```java
// ❌ BAD: N+1 문제 발생
@Query("SELECT s FROM SleepRecord s WHERE s.babyId = :babyId")
List<SleepRecord> findByBabyId(@Param("babyId") Long babyId);
// 이후 s.getBaby()를 호출할 때마다 추가 쿼리 발생

// ✅ GOOD: Fetch Join 사용
@Query("SELECT s FROM SleepRecord s JOIN FETCH s.baby WHERE s.babyId = :babyId")
List<SleepRecord> findByBabyIdWithBaby(@Param("babyId") Long babyId);
```

#### 2. @Transactional 적절히 사용
```java
// ✅ GOOD
@Transactional(readOnly = true) // 읽기 전용 트랜잭션
public class BabyServiceImpl implements BabyService {

    @Transactional // 쓰기 작업에는 readOnly 제거
    public BabyResponse createBaby(CreateBabyRequest request) {
        // ...
    }

    public BabyResponse getBaby(Long babyId) {
        // 읽기 전용
    }
}
```

#### 3. 순환 참조 방지
```java
// ❌ BAD: 순환 참조
@Entity
public class Baby {
    @OneToMany(mappedBy = "baby")
    private List<SleepRecord> sleepRecords;
}

@Entity
public class SleepRecord {
    @ManyToOne
    private Baby baby;
}
// JSON 직렬화 시 무한 루프 발생

// ✅ GOOD: DTO 사용으로 해결
public class BabyResponse {
    // SleepRecord는 포함하지 않음
}
```

#### 4. Repository 네이밍 규칙
```java
// ✅ GOOD: Spring Data JPA 규칙 준수
public interface BabyRepository extends JpaRepository<Baby, Long> {
    List<Baby> findByUserId(Long userId);
    Optional<Baby> findByIdAndUserId(Long id, Long userId);
    boolean existsByUserIdAndName(Long userId, String name);

    @Query("SELECT b FROM Baby b WHERE b.birthDate >= :startDate")
    List<Baby> findBabiesBornAfter(@Param("startDate") LocalDate startDate);
}
```

---

## 4. API 설계 규칙

### 4.1 RESTful API 규칙

```
✅ GOOD
GET    /api/v1/babies              - 목록 조회
POST   /api/v1/babies              - 생성
GET    /api/v1/babies/{id}         - 단건 조회
PUT    /api/v1/babies/{id}         - 전체 수정
PATCH  /api/v1/babies/{id}         - 부분 수정
DELETE /api/v1/babies/{id}         - 삭제

GET    /api/v1/babies/{id}/schedules           - 아기의 스케줄 목록
POST   /api/v1/babies/{id}/schedules           - 스케줄 생성
GET    /api/v1/babies/{id}/sleep-records       - 아기의 수면 기록

❌ BAD
POST   /api/v1/getBabies           - 동사 사용 X
GET    /api/v1/babies/delete/{id}  - GET으로 삭제 X
POST   /api/v1/baby-create         - 동사 사용 X
```

### 4.2 API 응답 형식

```json
// ✅ 성공 응답
{
  "success": true,
  "data": {
    "id": 1,
    "name": "지우",
    "birthDate": "2024-01-15",
    "ageInMonths": 10
  },
  "message": null,
  "timestamp": "2024-11-08T10:30:00"
}

// ✅ 에러 응답
{
  "success": false,
  "error": {
    "code": "BABY_NOT_FOUND",
    "message": "아기 정보를 찾을 수 없습니다.",
    "details": null
  },
  "timestamp": "2024-11-08T10:30:00"
}

// ✅ 검증 에러 응답
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "입력값 검증 실패",
    "details": {
      "name": "이름은 필수입니다.",
      "birthDate": "생년월일은 미래일 수 없습니다."
    }
  },
  "timestamp": "2024-11-08T10:30:00"
}
```

### 4.3 HTTP 상태 코드

```
✅ 올바른 사용
200 OK              - 조회, 수정 성공
201 Created         - 생성 성공
204 No Content      - 삭제 성공
400 Bad Request     - 잘못된 요청
401 Unauthorized    - 인증 실패
403 Forbidden       - 권한 없음
404 Not Found       - 리소스 없음
409 Conflict        - 충돌 (중복 등)
500 Internal Error  - 서버 오류
```

---

## 5. Git 브랜치 전략

### 5.1 Git Flow

```
main (production)
  ├── develop
  │     ├── feature/auth-kakao-login
  │     ├── feature/sleep-schedule-auto-generation
  │     ├── feature/sleep-tracking
  │     └── release/v1.0.0
  └── hotfix/critical-bug-fix
```

### 5.2 브랜치 네이밍 규칙

```
feature/기능명               - 새로운 기능
feature/auth-kakao-login
feature/sleep-auto-schedule

bugfix/버그명                - 버그 수정
bugfix/schedule-calculation-error

hotfix/긴급-버그             - 프로덕션 긴급 수정
hotfix/data-loss-on-save

refactor/리팩토링-대상       - 코드 개선
refactor/baby-service-cleanup

test/테스트-대상             - 테스트 추가
test/sleep-record-integration

docs/문서명                  - 문서 작업
docs/api-specification
```

### 5.3 커밋 메시지 규칙

```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅 (기능 변경 없음)
refactor: 코드 리팩토링
test: 테스트 코드 추가
chore: 빌드 설정 등

예시:
feat: 개월별 수면 스케줄 자동 생성 기능 구현
fix: 교정월령 계산 오류 수정
refactor: BabyService의 중복 코드 제거
test: SleepScheduleService 단위 테스트 추가
docs: API 명세서 업데이트
```

---

## 6. 코드 리뷰 체크리스트

### 6.1 공통

- [ ] 코드가 요구사항을 충족하는가?
- [ ] 네이밍이 명확하고 일관성 있는가?
- [ ] 중복 코드가 없는가?
- [ ] 주석이 필요한 복잡한 로직에 설명이 있는가?
- [ ] 테스트 코드가 작성되었는가?
- [ ] 보안 취약점이 없는가? (SQL Injection, XSS 등)
- [ ] 민감한 정보가 하드코딩되지 않았는가?

### 6.2 Flutter

- [ ] StatelessWidget을 우선 사용했는가?
- [ ] const 생성자를 사용했는가?
- [ ] 위젯이 적절히 분리되었는가? (100줄 이하)
- [ ] dispose()에서 리소스를 정리하는가?
- [ ] async/await 후 mounted 체크를 하는가?
- [ ] ListView.builder를 사용했는가?
- [ ] BLoC 패턴을 올바르게 사용했는가?

### 6.3 Spring Boot

- [ ] @Transactional이 적절히 사용되었는가?
- [ ] N+1 문제가 없는가?
- [ ] 순환 참조가 없는가?
- [ ] DTO와 Entity를 분리했는가?
- [ ] 예외 처리가 적절한가?
- [ ] 인증/인가가 올바르게 구현되었는가?
- [ ] SQL 쿼리가 최적화되었는가?

---

## 7. 성능 최적화

### 7.1 Flutter

```dart
// ✅ 1. ListView.builder 사용
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// ✅ 2. const 생성자
const Text('Hello')

// ✅ 3. 이미지 캐싱
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
)

// ✅ 4. 필요할 때만 rebuild
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        // ...
      },
    );
  }
}
```

### 7.2 Spring Boot

```java
// ✅ 1. 인덱스 추가
@Table(name = "sleep_records", indexes = {
    @Index(name = "idx_baby_date", columnList = "baby_id, date")
})

// ✅ 2. 페이징 처리
@GetMapping
public Page<BabyResponse> getBabies(
        @PageableDefault(size = 20) Pageable pageable) {
    return babyService.getBabies(pageable);
}

// ✅ 3. 캐싱
@Cacheable(value = "scheduleTemplates", key = "#ageInMonths")
public ScheduleTemplate getTemplateByAge(int ageInMonths) {
    // ...
}

// ✅ 4. 배치 처리
@Transactional
public void saveSleepRecords(List<SleepRecord> records) {
    sleepRecordRepository.saveAll(records);
}
```

---

## 8. 보안 체크리스트

### 8.1 인증/인가

```java
// ✅ JWT 토큰 검증
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/auth/**").permitAll()
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(),
                           UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

### 8.2 입력값 검증

```java
// ✅ GOOD: DTO 검증
public class CreateBabyRequest {
    @NotBlank
    @Pattern(regexp = "^[가-힣a-zA-Z0-9\\s]{1,50}$")
    private String name;

    @NotNull
    @PastOrPresent
    private LocalDate birthDate;
}
```

### 8.3 SQL Injection 방지

```java
// ✅ GOOD: Parameterized Query
@Query("SELECT b FROM Baby b WHERE b.name = :name")
List<Baby> findByName(@Param("name") String name);

// ❌ BAD: String concatenation
@Query(value = "SELECT * FROM babies WHERE name = '" + name + "'", nativeQuery = true)
```

---

## 9. 테스트 가이드

### 9.1 Flutter 테스트

```dart
// Unit Test
void main() {
  group('Baby', () {
    test('should calculate age in months correctly', () {
      final baby = Baby(
        birthDate: DateTime(2023, 1, 1),
      );

      expect(baby.ageInMonths, equals(22));
    });
  });
}

// Widget Test
void main() {
  testWidgets('ScheduleItem displays time correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScheduleItem(
          title: '낮잠 1',
          time: TimeOfDay(hour: 9, minute: 0),
        ),
      ),
    );

    expect(find.text('09:00'), findsOneWidget);
  });
}

// Integration Test
void main() {
  testWidgets('full schedule flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // 1. 기상시간 입력
    await tester.enterText(find.byKey(Key('wakeUpTime')), '07:00');
    await tester.tap(find.byKey(Key('generateButton')));
    await tester.pumpAndSettle();

    // 2. 스케줄이 생성되었는지 확인
    expect(find.text('낮잠 1'), findsOneWidget);
  });
}
```

### 9.2 Spring Boot 테스트

```java
// Unit Test
@ExtendWith(MockitoExtension.class)
class BabyServiceTest {

    @Mock
    private BabyRepository babyRepository;

    @InjectMocks
    private BabyServiceImpl babyService;

    @Test
    void createBaby_Success() {
        // Given
        CreateBabyRequest request = new CreateBabyRequest();
        request.setName("지우");
        request.setBirthDate(LocalDate.of(2024, 1, 1));

        Baby baby = Baby.builder()
                .name("지우")
                .birthDate(LocalDate.of(2024, 1, 1))
                .build();

        when(babyRepository.save(any(Baby.class))).thenReturn(baby);

        // When
        BabyResponse response = babyService.createBaby(request);

        // Then
        assertThat(response.getName()).isEqualTo("지우");
        verify(babyRepository, times(1)).save(any(Baby.class));
    }
}

// Integration Test
@SpringBootTest
@AutoConfigureMockMvc
class BabyControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser
    void createBaby_Integration_Success() throws Exception {
        // Given
        CreateBabyRequest request = new CreateBabyRequest();
        request.setName("지우");
        request.setBirthDate(LocalDate.of(2024, 1, 1));

        // When & Then
        mockMvc.perform(post("/api/v1/babies")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.name").value("지우"));
    }
}
```

---

## 10. 문서화

### 10.1 코드 주석

```java
/**
 * 아기의 교정월령을 계산합니다.
 *
 * <p>교정월령은 조산아의 경우 실제 발달 단계를 파악하기 위해 사용됩니다.
 * 출생 주수가 37주 미만인 경우에만 계산하며, 그 외에는 실제 월령을 반환합니다.</p>
 *
 * @return 교정월령 (개월 단위)
 * @see #calculateAgeInMonths()
 */
public int calculateCorrectedAgeInMonths() {
    // 구현
}
```

### 10.2 API 문서 (Swagger)

```java
@Operation(
    summary = "아기 프로필 생성",
    description = "새로운 아기 프로필을 생성합니다. 교정월령 계산을 위해 출생 주수를 입력할 수 있습니다."
)
@ApiResponses({
    @ApiResponse(responseCode = "201", description = "생성 성공"),
    @ApiResponse(responseCode = "400", description = "잘못된 요청"),
    @ApiResponse(responseCode = "401", description = "인증 실패")
})
public ResponseEntity<ApiResponse<BabyResponse>> createBaby(
        @Parameter(description = "아기 프로필 정보")
        @Valid @RequestBody CreateBabyRequest request) {
    // 구현
}
```

---

## 마무리

이 가이드라인은 육퇴의 정석 프로젝트의 코드 품질과 일관성을 유지하기 위한 기준입니다.
모든 개발자는 이 규칙을 숙지하고 준수해야 하며, 예외가 필요한 경우 팀과 논의 후 결정합니다.

**코드 리뷰 시 이 문서를 체크리스트로 활용하세요.**

---

📅 최초 작성: 2024-11-08
📝 최종 수정: 2024-11-08
👥 작성자: Development Team
