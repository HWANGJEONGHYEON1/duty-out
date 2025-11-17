import 'package:flutter/foundation.dart';
import '../models/baby.dart';
import '../services/baby_api_service.dart';

class BabyProvider with ChangeNotifier {
  final BabyApiService _babyApiService = BabyApiService();

  Baby? _baby;
  List<Baby> _babies = [];
  bool _isLoading = false;
  String? _error;

  Baby? get baby => _baby;
  List<Baby> get babies => _babies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateBaby(Baby baby) {
    _baby = baby;
    notifyListeners();
  }

  /// 내 아기 목록 조회
  Future<void> loadMyBabies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _babyApiService.getMyBabies();
      _babies = response.map((baby) => Baby.fromJson(baby)).toList();

      // 첫 번째 아기를 기본값으로 설정
      if (_babies.isNotEmpty) {
        _baby = _babies[0];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '아기 목록 조회 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 특정 아기 정보 조회
  Future<void> loadBaby(int babyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _babyApiService.getBaby(babyId: babyId);
      _baby = Baby.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '아기 정보 조회 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 아기 프로필 생성
  Future<void> createBaby({
    required String name,
    required String birthDate,
    required int gestationalWeeks,
    required String gender,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _babyApiService.createBaby(
        name: name,
        birthDate: birthDate,
        gestationalWeeks: gestationalWeeks,
        gender: gender,
        profileImage: profileImage,
      );
      _baby = Baby.fromJson(response);
      _babies.add(_baby!);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '아기 프로필 생성 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 아기 정보 수정 (이름만)
  Future<void> updateBabyInfo({
    required int babyId,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _babyApiService.updateBaby(
        babyId: babyId,
        name: name,
      );
      _baby = Baby.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '아기 정보 수정 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 아기 정보 수정 (모든 정보)
  Future<void> updateBabyAllInfo({
    required int babyId,
    String? name,
    DateTime? birthDate,
    int? gestationalWeeks,
    String? gender,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _babyApiService.updateBaby(
        babyId: babyId,
        name: name,
        birthDate: birthDate != null ?
          '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}' : null,
        gestationalWeeks: gestationalWeeks,
        gender: gender,
      );
      _baby = Baby.fromJson(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '아기 정보 수정 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
