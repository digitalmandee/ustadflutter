import 'package:flutter/material.dart';
import 'package:ustaad/Models/Parent%20Side/get_nearby_tutor_model.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class GetTutorsProvider extends ChangeNotifier {
  final AppDio dio;
  GetTutorsProvider(BuildContext context) : dio = AppDio(context);

  List<TutorModel> _tutors = [];
  List<TutorModel> _filteredTutors = [];
  List<TutorModel> get tutors => _filteredTutors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 🎯 Subject list for dropdown/chips
  final List<String> availableGrades = [
    "KG-1",
    "KG-2",
    "Grade 1",
    "Grade 2",
    "Grade 3",
    "Grade 4",
    "Grade 5",
    "Grade 6",
    "Grade 7",
    "Grade 8",
    "Matriculation",
    "Intermediate",
    "O Level",
    "A Level",
  ];

  final List<String> availableCurriculums = [
    "Cambridge",
    "American",
    "IB",
    "FBISE",
    "Punjab Board",
    "Sindh Board",
    "Local"
  ];
  final List<String> availableSubjects = [
    "Urdu",
    "English",
    "Mathematics",
    "General Science",
    "Biology",
    "Physics",
    "Chemistry",
    "Computer Science",
    "Social Studies",
    "Pakistan Studies",
    "Islamiat (Compulsory)",
    "Islamiat Elective",
    "Ethics (for Non-Muslims)",
    "Nazra Quran / Islamic Education",
    "Drawing / Art",
    "Education",
    "Civics",
    "Sociology",
    "Psychology",
    "Economics",
    "Principles of Economics",
    "Principles of Accounting",
    "Principles of Commerce",
    "Business Math & Statistics",
    "Statistics",
    "Fine Arts",
    "History",
    "Geography",
    "Persian",
    "Arabic",
    "French",
    "Home Economics"
  ];

  Future<void> fetchTutors({
    double? latitude,
    double? longitude,
    String? subject,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await dio.get(
        path: AppUrls.getTutor,
        queryParameters: {
          if (latitude != null && longitude != null) "latitude": latitude,
          if (latitude != null && longitude != null) "longitude": longitude,
          if (subject != null && subject.isNotEmpty)
            "category": subject.toLowerCase(),
          if (latitude != null && longitude != null) "radius": 100,
          "limit": 20,
          "offset": 0,
        },
      );

      final List data = res.data['data'];
      print("here is the data: ${data[0]["tutor"]['gender']}");
      _tutors = data.map((e) => TutorModel.fromJson(e)).toList();
      _filteredTutors = List.from(_tutors);
    } catch (e) {
      debugPrint('Fetch Tutors Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters(List<String> filters) {
    if (filters.isEmpty) {
      _filteredTutors = List.from(_tutors);
      notifyListeners();
      return;
    }

    _filteredTutors = _tutors.where((tutor) {
      bool matches = true;

      for (String filter in filters) {
        final normalizedFilter = filter.toLowerCase().trim();

        // 🎯 Subject filter
        if (availableSubjects
            .map((s) => s.toLowerCase().trim())
            .contains(normalizedFilter)) {
          matches = matches &&
              tutor.subjects
                  .any((s) => s.toLowerCase().trim() == normalizedFilter);
        }
        /////////////// Grades /////////////////
        if (availableGrades
            .map((e) => e.toLowerCase())
            .contains(normalizedFilter)) {
          matches = matches &&
              tutor.grades
                  .any((g) => g.toLowerCase().trim() == normalizedFilter);
        }

        // 🎯 CURRICULUM
        if (availableCurriculums
            .map((e) => e.toLowerCase())
            .contains(normalizedFilter)) {
          matches = matches &&
              tutor.curriculums
                  .any((c) => c.toLowerCase().trim() == normalizedFilter);
        }

        // 🎯 Rating filter
        if (normalizedFilter == "high") {
          matches = matches && tutor.rating >= 4.0;
        } else if (normalizedFilter == "medium") {
          matches = matches && tutor.rating >= 2.5 && tutor.rating < 4.0;
        } else if (normalizedFilter == "low") {
          matches = matches && tutor.rating < 2.5;
        }

        // 🎯 Experience filter
        if (normalizedFilter == "> 5 years") {
          matches = matches && tutor.experience > 5;
        } else if (normalizedFilter == "> 10 years") {
          matches = matches && tutor.experience > 10;
        }
        if (normalizedFilter == "male") {
          matches = matches && tutor.gender == "male";
        } else if (normalizedFilter == "female") {
          matches = matches && tutor.gender == "female";
        }
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  void resetFilters() {
    _filteredTutors = List.from(_tutors);
    notifyListeners();
  }

  void searchByName(String query) {
    if (query.isEmpty) {
      _filteredTutors = List.from(_tutors);
    } else {
      _filteredTutors = _tutors
          .where((tutor) =>
              tutor.firstName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void clear() {
    _tutors.clear();
    _filteredTutors.clear();
    _isLoading = false;
    notifyListeners();
  }
}
