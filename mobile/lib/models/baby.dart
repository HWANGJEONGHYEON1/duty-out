class Baby {
  final String id;
  final String name;
  final DateTime birthDate;
  final int birthWeeks;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.birthWeeks = 39,
  });

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
