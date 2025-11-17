class Baby {
  final int id;
  final String name;
  final DateTime birthDate;
  final int birthWeeks;
  final String? gender;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.birthWeeks = 39,
    this.gender,
  });

  /// JSON으로부터 Baby 객체 생성
  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      birthDate: json['birthDate'] is String
          ? DateTime.parse(json['birthDate'])
          : json['birthDate'],
      birthWeeks: json['birthWeeks'] ?? 39,
      gender: json['gender'],
    );
  }

  /// Baby 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'birthWeeks': birthWeeks,
      if (gender != null) 'gender': gender,
    };
  }

  int get ageInDays {
    return DateTime.now().difference(birthDate).inDays;
  }

  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }
    return months;
  }

  int get daysInCurrentMonth {
    final now = DateTime.now();
    if (now.day >= birthDate.day) {
      return now.day - birthDate.day;
    } else {
      return now.day + (DateTime(now.year, now.month, 0).day - birthDate.day);
    }
  }

  String get ageText {
    return '$ageInMonths개월 $daysInCurrentMonth일';
  }
}
