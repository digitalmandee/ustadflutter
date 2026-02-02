import 'package:ustaad/Helpers/capitalize.dart';

class Child {
  final String id;
  final String firstName;
  final String lastname;
  final String age;
  final String school;
  final String gender;
  final String grade;
  final String pic;
  final String curriculum;

  Child({
    required this.pic,
    required this.firstName,
    required this.lastname,
    required this.id,
    required this.age,
    required this.school,
    required this.gender,
    required this.grade,
    required this.curriculum,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? '',
      firstName: capitalizeEachWord(json['firstName'] ?? ''),
      lastname: capitalizeEachWord(json['lastName'] ?? ''),
      age: json['age'].toString(),
      school: json['schoolName'] ?? '',
      gender: json['gender'] ?? '',
      grade: json['grade'] ?? '',
      pic: json['image'] ?? '',
      curriculum: json['curriculum'] ?? '',
    );
  }
}
