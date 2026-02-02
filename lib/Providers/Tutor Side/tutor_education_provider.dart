import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class Education {
  final String id;
  final String institute;
  final String startDate;
  final String endDate;
  final String description;
  final String degree;

  Education({
    required this.id,
    required this.institute,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.degree,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['_id'] ?? '',
      institute: json['institute'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      description: json['description'] ?? '',
      degree: json['degree'] ?? '',
    );
  }
}

class EducationProvider with ChangeNotifier {
  final List<Education> _education = [];
  List<Education> get education => _education;

  final AppDio dio;
  bool addEduLoader = false;
  EducationProvider(BuildContext context) : dio = AppDio(context);

  Future<void> fetchEducation(context) async {
    try {
      final response = await dio.get(path: AppUrls.getTutorEdu);
      if (response.statusCode == 200) {
        education.clear();
        for (var item in response.data['data']) {
          _education.add(Education(
            id: item['id'].toString(),
            institute: item['institute'] ?? '',
            startDate: item['startDate'] ?? '',
            endDate: item['endDate'] ?? '',
            description: item['description'] ?? '',
            degree: item['degree'] ?? '',
          ));
        }
        notifyListeners();
      } else {
        AppToast.error(
            context: context, msg: "${response.data["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Fetch error: $e");
      }
    }
  }

  Future<bool> addEducation(Education education, context) async {
    addEduLoader = true;
    notifyListeners();

    Map<String, dynamic> params = {
      "institute": education.institute,
      "startDate": education.startDate,
      "endDate": education.endDate,
      "description": education.description,
      "degree": education.degree,
    };

    try {
      Response response =
          await dio.post(path: AppUrls.addTutorEdu, data: params);

      if (response.statusCode == 201) {
        // ✅ Get the actual ID from the backend
        String newId = response.data["data"]["id"].toString();

        Education newEdu = Education(
          id: newId,
          institute: education.institute,
          startDate: education.startDate,
          endDate: education.endDate,
          description: education.description,
          degree: education.degree,
        );

        // ✅ Add updated object to the list
        _education.add(newEdu);

        AppToast.success(
          context: context,
          msg: "${response.data["message"]}",
        );

        addEduLoader = false;
        notifyListeners();
        return true;
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
        addEduLoader = false;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Add error: $e");
      }
      addEduLoader = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> updateEducation(Education education, context) async {
    try {
      final response = await dio.post(
        path: "${AppUrls.updateTutorEdu}/${education.id}",
        data: {
          "institute": education.institute,
          "startDate": education.startDate,
          "endDate": education.endDate,
          "description": education.description,
          "degree": education.degree,
        },
      );

      if (response.statusCode == 200) {
        final index = _education.indexWhere((e) => e.id == education.id);
        if (index != -1) {
          _education[index] = education;
        }
        notifyListeners();
        AppToast.success(context: context, msg: "${response.data["message"]}");
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("Update error: $e");
    }
    return false;
  }

  Future<bool> deleteEducation(String id, context) async {
    try {
      final response = await dio.get(path: "${AppUrls.deleteTutorEdu}$id");

      if (response.statusCode == 200) {
        _education.removeWhere((e) => e.id == id);
        notifyListeners();
        AppToast.success(context: context, msg: "${response.data["message"]}");
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("Delete error: $e");
    }
    return false;
  }

  void clear() {
    _education.clear();
    addEduLoader = false;
    notifyListeners();
  }
}
