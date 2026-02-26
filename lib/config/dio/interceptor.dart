import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/keys/headers.dart';
import 'package:flutterustad/config/keys/pref_keys.dart';
import 'package:flutterustad/config/keys/urls.dart';

class AppDioInterceptor extends Interceptor {
  final AppLogger _logger = AppLogger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = "Something went wrong";

    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      errorMessage = "Check Internet Connection";
    } else if (err.type == DioExceptionType.badResponse) {
      errorMessage = err.response?.data?['message'] ?? "Server error occurred";
    } else if (err.type == DioExceptionType.cancel) {
      errorMessage = "Request cancel ";
    }
    Map<String, dynamic> er = {
      "type": err.type.toString(),
      "message": errorMessage,
      "status_code": err.response?.statusCode,
      "status_message": err.response?.statusMessage,
      "headers": err.response?.headers,
      "data": err.response?.data,
      "response": err.response,
    };
    _logger.e(er);

    if (err.response != null) {
      handler.resolve(err.response!);
    } else {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: errorMessage,
          type: err.type,
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Map<String, dynamic> er = {
      "base_url": response.requestOptions.baseUrl,
      "end_point": response.requestOptions.path,
      "method": response.requestOptions.method,
      "status_code": response.statusCode,
      "status_message": response.statusMessage,
      "headers": response.headers,
      "data": response.data,
      "extra": response.extra,
      "response": response,
    };
    _logger.i(er);
    // if (response.statusCode == 401) {
    //   AppToast.error(
    //       context: context, msg: response.statusMessage ?? "Unauthorized");
    //   pushUntil(context, LogInScreen());
    // }

    handler.next(response);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (AppUrls.baseUrl.isEmpty) {
      throw Exception("Base URL is not set");
    }

    options.baseUrl = AppUrls.baseUrl;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String freshToken = prefs.getString(PrefKey.authorization) ?? "";

    if (freshToken.isNotEmpty) {
      options.headers.addAll({
        RequestHeader.authorization: "Bearer $freshToken",
      });
    }

    Map<String, dynamic> er = {
      "base_url": options.baseUrl,
      "end_point": options.path,
      "method": options.method,
      "headers": options.headers,
      "params": options.queryParameters,
      "data": options.data,
      "extra": options.extra,
    };
    _logger.d(er);

    handler.next(options);
  }
}
