import 'package:flutter/foundation.dart';
import '../models/baby.dart';

class BabyProvider with ChangeNotifier {
  Baby? _baby;

  Baby? get baby => _baby;

  void initializeMockData() {
    _baby = Baby(
      id: '1',
      name: '민준이',
      birthDate: DateTime(2024, 7, 1),
      birthWeeks: 39,
    );
    notifyListeners();
  }

  void updateBaby(Baby baby) {
    _baby = baby;
    notifyListeners();
  }
}
