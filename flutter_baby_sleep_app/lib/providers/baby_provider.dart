import 'package:flutter/material.dart';

class Baby {
  final String id;
  final String name;
  final DateTime birthDate;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
  });

  int get ageInMonths {
    final now = DateTime.now();
    final months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    return months;
  }

  int get ageInDays {
    final now = DateTime.now();
    return now.difference(birthDate).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
    };
  }

  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birthDate']),
    );
  }
}

class BabyProvider extends ChangeNotifier {
  Baby? _currentBaby;

  Baby? get currentBaby => _currentBaby;

  bool get hasBaby => _currentBaby != null;

  void setBaby(Baby baby) {
    _currentBaby = baby;
    notifyListeners();
  }

  void updateBaby({String? name, DateTime? birthDate}) {
    if (_currentBaby != null) {
      _currentBaby = Baby(
        id: _currentBaby!.id,
        name: name ?? _currentBaby!.name,
        birthDate: birthDate ?? _currentBaby!.birthDate,
      );
      notifyListeners();
    }
  }

  void clearBaby() {
    _currentBaby = null;
    notifyListeners();
  }
}
