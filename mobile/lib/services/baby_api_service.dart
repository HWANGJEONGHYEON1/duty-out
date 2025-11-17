import 'api_client.dart';

/// 아기 프로필 API 서비스
///
/// 아기 프로필의 CRUD API를 제공합니다.
class BabyApiService {
  final ApiClient _apiClient = ApiClient();

  /// 내 아기 목록 조회
  ///
  /// 현재 로그인한 사용자의 모든 아기 프로필을 조회합니다.
  Future<List<Map<String, dynamic>>> getMyBabies() async {
    final response = await _apiClient.get(
      '/api/v1/babies',
    );

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('아기 목록 조회 실패: ${response.statusCode}');
  }

  /// 아기 프로필 조회
  ///
  /// [babyId] 아기 ID
  Future<Map<String, dynamic>> getBaby({required int babyId}) async {
    final response = await _apiClient.get(
      '/api/v1/babies/$babyId',
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('아기 정보 조회 실패: ${response.statusCode}');
  }

  /// 아기 프로필 생성
  ///
  /// [name] 아기 이름
  /// [birthDate] 생년월일 (YYYY-MM-DD 형식)
  /// [gestationalWeeks] 출생 주수
  /// [gender] 성별 (MALE, FEMALE)
  /// [profileImage] 프로필 이미지 (선택)
  Future<Map<String, dynamic>> createBaby({
    required String name,
    required String birthDate,
    required int gestationalWeeks,
    required String gender,
    String? profileImage,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/babies',
      data: {
        'name': name,
        'birthDate': birthDate,
        'gestationalWeeks': gestationalWeeks,
        'gender': gender,
        if (profileImage != null) 'profileImage': profileImage,
      },
    );

    if (response.statusCode == 201) {
      return response.data['data'];
    }

    throw Exception('아기 프로필 생성 실패: ${response.statusCode}');
  }

  /// 아기 프로필 수정
  ///
  /// [babyId] 아기 ID
  /// [name] 아기 이름 (선택)
  /// [birthDate] 생년월일 (YYYY-MM-DD 형식, 선택)
  /// [gestationalWeeks] 출생 주수 (선택)
  /// [gender] 성별 (MALE, FEMALE, 선택)
  /// [profileImage] 프로필 이미지 (선택)
  Future<Map<String, dynamic>> updateBaby({
    required int babyId,
    String? name,
    String? birthDate,
    int? gestationalWeeks,
    String? gender,
    String? profileImage,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (birthDate != null) data['birthDate'] = birthDate;
    if (gestationalWeeks != null) data['gestationalWeeks'] = gestationalWeeks;
    if (gender != null) data['gender'] = gender;
    if (profileImage != null) data['profileImage'] = profileImage;

    final response = await _apiClient.put(
      '/api/v1/babies/$babyId',
      data: data,
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    }

    throw Exception('아기 프로필 수정 실패: ${response.statusCode}');
  }

  /// 아기 프로필 삭제
  ///
  /// [babyId] 아기 ID
  Future<void> deleteBaby({required int babyId}) async {
    final response = await _apiClient.delete(
      '/api/v1/babies/$babyId',
    );

    if (response.statusCode != 200) {
      throw Exception('아기 프로필 삭제 실패: ${response.statusCode}');
    }
  }
}
