import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Models/Tutor%20Side/subjects_model.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/urls.dart';

class About {
  final String about;
  final List<String> subjects;
  final List<String> grades;
  final List<String> curriculum;

  About({
    required this.about,
    required this.subjects,
    required this.grades,
    required this.curriculum,
  });

  About copyWith({
    String? about,
    List<String>? subjects,
    List<String>? grades,
    List<String>? curriculum,
  }) {
    return About(
      about: about ?? this.about,
      subjects: subjects ?? this.subjects,
      grades: grades ?? this.grades,
      curriculum: curriculum ?? this.curriculum,
    );
  }
}

class AboutProvider with ChangeNotifier {
  About? _aboutData;
  About? get aboutData => _aboutData;
  Map<String, dynamic>? profileData;
  String totalExp = "0";
  bool isVerified = false;
  bool get hasAbout => _aboutData != null && _aboutData!.about.isNotEmpty;

  final AppDio dio;

  AboutProvider(BuildContext context) : dio = AppDio(context);
  List<String> tempSubjects = [];
  List<String> tempGrades = [];
  List<String> tempCurriculums = [];

  void initTempSelections() {
    if (_aboutData != null) {
      tempSubjects = List.from(_aboutData!.subjects);
      tempGrades = List.from(_aboutData!.grades);
      tempCurriculums = List.from(_aboutData!.curriculum);
      notifyListeners(); // ✅ This makes UI update immediately
    }
  }

  void updateTempSelections({
    required List<String> subjects,
    required List<String> grades,
    required List<String> curriculums,
  }) {
    tempSubjects = subjects;
    tempGrades = grades;
    tempCurriculums = curriculums;
    notifyListeners();
  }

  void toggleSelection<T>(T item, List<T> list) {
    final exists = list.any(
      (e) =>
          (e is String
              ? e.toLowerCase()
              : (e as SubjectsModel).name.toLowerCase()) ==
          (item is String
              ? item.toLowerCase()
              : (item as SubjectsModel).name.toLowerCase()),
    );

    if (exists) {
      list.removeWhere(
        (e) =>
            (e is String
                ? e.toLowerCase()
                : (e as SubjectsModel).name.toLowerCase()) ==
            (item is String
                ? item.toLowerCase()
                : (item as SubjectsModel).name.toLowerCase()),
      );
    } else {
      list.add(item);
    }
    notifyListeners();
  }

  Future<void> fetchAboutData(context) async {
    try {
      final response = await dio.get(path: AppUrls.getTutorProfile);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        profileData = data;
        isVerified = data["user"]["isAdminVerified"];
        totalExp = data["totalExperience"].toString();
        final tutor = data["user"]['Tutor'];

        if (tutor != null) {
          _aboutData = About(
            about: tutor['about'] ?? '',
            subjects: tutor['subjects'] != null
                ? List<String>.from(tutor['subjects'])
                : [],
            grades: tutor['grade'] != null
                ? List<String>.from(tutor['grade'])
                : [],
            curriculum: tutor['curriculum'] != null
                ? List<String>.from(tutor['curriculum'])
                : [],
          );
        } else {
          _aboutData = null;
          AppToast.error(
            context: context,
            msg: "${response.data["errors"][0]["message"]}",
          );
        }

        notifyListeners();
      } else if (response.statusCode == 401 &&
          response.data["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );

        handleTokenExpiration();
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(context: context, msg: message);
    }
  }

  Future<bool> addAboutData(String about, context) async {
    Map<String, dynamic> body = {
      "about": about,
      "subjects": tempSubjects,
      "grade": tempGrades,
      "curriculum": tempCurriculums,
    };

    try {
      final response = await dio.post(path: AppUrls.addAbout, data: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchAboutData(context);
        return true;
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      if (kDebugMode) print("Add About Error: $e");
    }

    return false;
  }

  Future<bool> updateAboutData(String about, context) async {
    final body = {
      "about": about,
      "subjects": tempSubjects,
      "grade": tempGrades,
      "curriculum": tempCurriculums,
    };

    final response = await dio.postJson(path: AppUrls.editAbout, data: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _aboutData = _aboutData!.copyWith(
        about: about,
        subjects: tempSubjects,
        grades: tempGrades,
        curriculum: tempCurriculums,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void clear() {
    _aboutData = null;
    profileData = null;
    totalExp = "0";
    isVerified = false;

    tempSubjects.clear();
    tempGrades.clear();
    tempCurriculums.clear();

    notifyListeners();
  }
}
