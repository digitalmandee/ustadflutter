import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/subject_cost_model.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/global.dart';
import 'package:ustaad/config/keys/urls.dart';

class CostSettingProvider with ChangeNotifier {
  int minSubjects = 0;
  int maxStudents = 0;
  bool isFirstTime = true;
  bool isLoading = false;
  bool saveButtonLoader = false;
  SubjectModel? selectedSubject;
  List<SubjectModel> subjects = [];

  final AppDio dio;
  CostSettingProvider(BuildContext context) : dio = AppDio(context);

  Future<void> fetchCostSettings(context, bool isfromOfferSide) async {
    isLoading = true;
    if (isfromOfferSide != true) {
      notifyListeners();
    }

    try {
      final response = await dio.get(path: AppUrls.getcostsetting);
      final responseData = response.data;

      if (response.statusCode == 200) {
        final data = response.data["data"];
        minSubjects = data['minSubjects'];
        maxStudents = data['maxStudentsDaily'];
        final subjectCostsMap = data['subjectCosts'] as Map<String, dynamic>;
        subjects = subjectCostsMap.entries.map((entry) {
          return SubjectModel.fromJson({
            'name': entry.key,
            'active':
                entry.value['active'] == true || entry.value['active'] == "true"
                    ? "true"
                    : "false",
            'cost': entry.value['cost']?.toString() ?? '0',
          });
        }).toList();

        isFirstTime = false;
      } else if (response.statusCode == 401 &&
          responseData["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");

        handleTokenExpiration();
      }
    } catch (e) {
      isFirstTime = true;
      debugPrint('Fetch error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedSubject(SubjectModel subject) {
    selectedSubject = subject;
    notifyListeners();
  }

  Future<void> saveCostSettings(context) async {
    saveButtonLoader = true;
    notifyListeners();

    try {
      Map<String, dynamic> subjectCostsMap = {};
      for (var subject in subjects) {
        subjectCostsMap[subject.name] = {
          'cost': subject.cost,
          'active': subject.active,
        };
      }
      final Map<String, dynamic> body = {
        'minSubjects': minSubjects,
        'maxStudentsDaily': maxStudents,
        'subjectCosts': subjectCostsMap,
      };

      Response response;
      response = await dio.put(path: AppUrls.editcostsetting, data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success(
            context: context, msg: "Cost settings saved successfully!");
      } else {
        AppToast.error(context: context, msg: "Failed to save cost settings");
      }
    } catch (e) {
      debugPrint('Save error: $e');
    } finally {
      saveButtonLoader = false;
      notifyListeners();
    }
  }

  Future<void> saveNewSubject(context) async {
    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> subjectCostsMap = {};
      for (var subject in subjects) {
        subjectCostsMap[subject.name] = {
          'cost': subject.cost,
          'active': subject.active,
        };
      }
      final Map<String, dynamic> body = {
        'minSubjects': minSubjects,
        'maxStudentsDaily': maxStudents,
        'subjectCosts': subjectCostsMap,
      };

      Response response;
      response = await dio.put(path: AppUrls.editcostsetting, data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppToast.success(
            context: context, msg: "Cost settings saved successfully!");
      } else {
        AppToast.error(context: context, msg: "Failed to save cost settings");
      }
    } catch (e) {
      debugPrint('Save error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSubject(int index, SubjectModel updated) {
    subjects[index] = updated;
    notifyListeners();
  }

  void addSubject(SubjectModel subject, context) {
    subjects.add(subject);
    saveNewSubject(context);
    notifyListeners();
  }

  void updateMinSubjects(int value) {
    minSubjects = value;
    notifyListeners();
  }

  void updateMaxStudents(int value) {
    maxStudents = value;
    notifyListeners();
  }

  void clear() {
    minSubjects = 0;
    maxStudents = 0;
    isFirstTime = true;
    isLoading = false;
    saveButtonLoader = false;
    selectedSubject = null;
    subjects.clear();
    notifyListeners();
  }
}
