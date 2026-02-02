import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/experience_model.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_about_provider.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class ExperienceProvider with ChangeNotifier {
  final List<Experience> _experiences = [];
  List<Experience> get experiences => _experiences;

  final AppDio dio;

  ExperienceProvider(BuildContext context) : dio = AppDio(context);

  Future<void> fetchExperiences(context) async {
    try {
      final response = await dio.get(path: AppUrls.getTutorExp);
      if (response.statusCode == 201) {
        _experiences.clear();
        for (var item in response.data['data']) {
          _experiences.add(Experience.fromJson(item));
        }
        notifyListeners();
      } else {
        AppToast.error(
            context: context, msg: "${response.data["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) print("Fetch error: $e");
    }
  }

  Future<bool> addExperience(Experience experience, context) async {
    Map<String, dynamic> params = {
      "company": experience.company,
      "startDate": experience.startDate,
      "endDate": experience.endDate,
      "description": experience.description,
      "designation": experience.designation,
    };
    try {
      Response response =
          await dio.post(path: AppUrls.addTutorExp, data: params);

      if (response.statusCode == 201) {
        final newExp = Experience(
            id: response.data['data']['id'].toString(),
            company: experience.company,
            startDate: experience.startDate,
            endDate: experience.endDate,
            description: experience.description,
            designation: experience.designation);
        _experiences.add(newExp);

        AppToast.success(context: context, msg: "${response.data["message"]}");
        notifyListeners();
        _fetchAboutInBackground(context);

        return true;
      } else {
        AppToast.error(
            context: context, msg: "${response.data["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) print("Add error: $e");
    }
    return false;
  }

  Future<bool> updateExperience(Experience experience, context) async {
    Map<String, dynamic> params = {
      "company": experience.company,
      "startDate": experience.startDate,
      "endDate": experience.endDate,
      "description": experience.description,
      "designation": experience.designation,
    };
    try {
      Response response = await dio.post(
        path: "${AppUrls.editTutorExp}${experience.id}",
        data: params,
      );

      if (response.statusCode == 200) {
        final index = _experiences.indexWhere((e) => e.id == experience.id);
        if (index != -1) {
          _experiences[index] = experience;
        }
        AppToast.success(context: context, msg: "${response.data["message"]}");
        notifyListeners();
        _fetchAboutInBackground(context);

        return true;
      } else {
        AppToast.error(
            context: context, msg: "${response.data["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) print("Update error: $e");
    }
    return false;
  }

  Future<bool> deleteExperience(String id, context) async {
    try {
      Response response = await dio.get(path: "${AppUrls.deleteTutorExp}$id");

      if (response.statusCode == 200) {
        _experiences.removeWhere((e) => e.id == id);
        AppToast.success(context: context, msg: "${response.data["message"]}");
        notifyListeners();
        _fetchAboutInBackground(context);
        return true;
      } else {
        AppToast.error(
            context: context, msg: "${response.data["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) print("Delete error: $e");
    }
    return false;
  }

  void _fetchAboutInBackground(context) {
    Future.microtask(() async {
      try {
        final aboutProvider =
            Provider.of<AboutProvider>(context, listen: false);
        await aboutProvider.fetchAboutData(context);
        if (kDebugMode) print("About data fetched successfully in background");
      } catch (e) {
        if (kDebugMode) print("Background about fetch error: $e");
      }
    });
  }

  void clear() {
    _experiences.clear();
    notifyListeners();
  }
}
