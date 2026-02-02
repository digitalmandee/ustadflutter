import 'dart:io';

class TutorOnboardData {
  /// MULTI SELECT FIELDS
  List<String> selectedSubjects;
  List<String> selectedGrades;
  List<String> selectedCurriculums;

  /// BANK DETAILS
  String? selectedBank;
  String? accountNumber;

  /// FILES
  File? resumeFile;
  File? idFrontFile;
  File? idBackFile;

  TutorOnboardData({
    this.selectedSubjects = const [],
    this.selectedGrades = const [],
    this.selectedCurriculums = const [],
    this.selectedBank,
    this.accountNumber,
    this.resumeFile,
    this.idFrontFile,
    this.idBackFile,
  });

  Map<String, dynamic> toJson() {
    return {
      "subjects": selectedSubjects.map((s) => s.toString()).toList(),
      "grades": selectedGrades.map((g) => g.toString()).toList(),
      "curriculums": selectedCurriculums.map((c) => c.toString()).toList(),
      "bank_name": selectedBank,
      "account_number": accountNumber,
    };
  }
}
