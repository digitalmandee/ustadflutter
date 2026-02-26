import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/urls.dart';

class ContractProvider extends ChangeNotifier {
  final AppDio dio;
  bool isLoading = false;

  List allContracts = [];

  ContractProvider(BuildContext context) : dio = AppDio(context);

  // ---------------------------
  // GET CONTRACTS API
  // ---------------------------
  Future<void> getContracts(context, bool isParentSide) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await dio.get(
        path: isParentSide
            ? AppUrls.getParentContracts
            : AppUrls.getTutorContracts,
      );

      if (response.statusCode == 200) {
        allContracts = response.data["data"]["contracts"];
      } else {
        AppToast.error(
          context: context,
          msg: response.data["message"] ?? "Something went wrong",
        );
      }
    } catch (e) {
      String message = "Something went wrong";

      if (e is DioException) {
        message = e.error?.toString() ?? "Check Internet Connection";
      } else {
        message = e.toString();
      }

      AppToast.error(context: context, msg: message);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------
  // TERMINATE CONTRACT → DISPUTE
  // ---------------------------
  Future<bool> terminateContract(
    BuildContext context,
    String contractId,
    String reason,
    bool isParentSide,
  ) async {
    try {
      final response = await dio.post(
        path: isParentSide
            ? "${AppUrls.cancelParentContract}/$contractId"
            : "${AppUrls.cancelTutorContract}/$contractId",
        data: {"status": "DISPUTE", "reason": reason},
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
      return false;
    }
  }

  // ---------------------------
  // COMPLETE CONTRACT → rating pop later
  // ---------------------------
  Future<bool> completeContract(
    BuildContext context,
    String contractId,
    bool isParentSide,
  ) async {
    try {
      final response = await dio.post(
        path: isParentSide
            ? "${AppUrls.cancelParentContract}/$contractId"
            : "${AppUrls.cancelTutorContract}/$contractId",
        data: {"status": "PENDING_COMPLETION"},
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
      return false;
    }
  }

  // ---------------------------
  // SUBMIT RATING API
  // ---------------------------
  Future<bool> submitRating(
    context,
    bool isParentSide,
    String contractId,
    double rating,
    String review,
  ) async {
    try {
      final response = await dio.post(
        path: isParentSide
            ? "parent/contracts/$contractId/rating"
            : "tutor/contracts/$contractId/rating",
        data: {"rating": rating.toInt(), "review": review},
      );

      if (response.statusCode == 200) {
        // getContracts(context, isParentSide);
        return true;
      } else {
        AppToast.error(
          context: context,
          msg: response.data["message"] ?? "Something went wrong",
        );
        return false;
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
      return false;
    }
  }

  // ---------------------------
  // FILTERS
  // ---------------------------

  List getRunning() {
    return allContracts.where((e) {
      return [
        "ACTIVE",
        "CREATED",
        "DISPUTE",
        "PENDING_COMPLETION",
      ].contains(e["status"]);
    }).toList();
  }

  List getCompleted() {
    return allContracts.where((e) {
      return e["status"] == "COMPLETED";
    }).toList();
  }

  List getCancelled() {
    return allContracts.where((e) {
      return ["CANCELLED", "EXPIRED"].contains(e["status"]);
    }).toList();
  }

  void clear() {
    allContracts = [];
    isLoading = false;
    notifyListeners();
  }
}
