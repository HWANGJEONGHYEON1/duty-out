import 'package:flutter/foundation.dart';
import '../models/baby.dart';

class BabyProvider with ChangeNotifier {
  Baby? _baby;

  Baby? get baby => _baby;

  void updateBaby(Baby baby) {
    _baby = baby;
    notifyListeners();
  }

  // TODO: API 연결 필요
  // Future<void> loadBaby() async {
  //   // API 호출로 아기 정보 불러오기
  // }
}
