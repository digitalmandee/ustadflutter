class TutorModel {
  final String tutorId;
  final String firstName;
  final String lastName;
  final List<String> subjects;
  final String address;
  final List<String> grades;
  final List<String> curriculums;
  final String image;
  final String email;
  final String phone;
  final double rating;
  final double experience; // 🔥 change int → double
  final String gender; // 🔥 change int → double

  TutorModel({
    required this.tutorId,
    required this.firstName,
    required this.lastName,
    required this.curriculums,
    required this.grades,
    required this.subjects,
    required this.address,
    required this.image,
    required this.email,
    required this.phone,
    required this.rating,
    required this.experience,
    required this.gender,
  });

  factory TutorModel.fromJson(Map<String, dynamic> json) {
    final tutor = json['tutor'] ?? {};
    final tutorProfile = tutor['Tutor'] ?? {};
    final reviewStats = tutor['reviewStats'] ?? json['reviewStats'] ?? {};

    return TutorModel(
      tutorId: (json['tutorId'] ?? tutor['id'] ?? '').toString(),
      firstName: tutor['firstName'] ?? 'Unknown',
      lastName: tutor['lastName'] ?? 'Unknown',
      gender: (tutor['gender'] ?? 'Unknown').toString().toLowerCase(),
      subjects: List<String>.from(tutorProfile['subjects'] ?? []),
      address: json['address'] ?? 'Unknown Area',
      image: tutor['image'] ?? '',
      email: tutor['email'] ?? '',
      phone: tutor['phone'] ?? '',
      rating: (reviewStats['averageRating'] as num? ?? 0).toDouble(),
      experience:
          ((tutor['totalExperienceMonths'] ??
                      tutor['totalExperience'] ??
                      json['totalExperienceMonths'] ??
                      0)
                  as num)
              .toDouble(),
      grades: List<String>.from(tutorProfile['grade'] ?? []),
      curriculums: List<String>.from(tutorProfile['curriculum'] ?? []),
    );
  }
}
