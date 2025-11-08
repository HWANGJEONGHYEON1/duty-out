import 'package:equatable/equatable.dart';

/// 아기 엔티티
class Baby extends Equatable {
  final int id;
  final int userId;
  final String name;
  final DateTime birthDate;
  final int? gestationalWeeks;
  final Gender? gender;
  final String? profileImage;
  final int ageInMonths;
  final int correctedAgeInMonths;
  final DateTime createdAt;

  const Baby({
    required this.id,
    required this.userId,
    required this.name,
    required this.birthDate,
    this.gestationalWeeks,
    this.gender,
    this.profileImage,
    required this.ageInMonths,
    required this.correctedAgeInMonths,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        birthDate,
        gestationalWeeks,
        gender,
        profileImage,
        ageInMonths,
        correctedAgeInMonths,
        createdAt,
      ];
}

enum Gender { male, female }
