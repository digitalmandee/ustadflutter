import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Screens/Chats/payfast.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';
import 'package:flutterustad/config/keys/global.dart';
import 'package:flutterustad/config/keys/urls.dart';

class ParentCardScreen extends StatefulWidget {
  final String? offerId;

  const ParentCardScreen({super.key, this.offerId});

  @override
  State<ParentCardScreen> createState() => _ParentCardScreenState();
}

class _ParentCardScreenState extends State<ParentCardScreen> {
  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();
  List cardData = [];

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    getParentCards(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar1(
        title: Staticdata.isActive ? "Accept Offer" : "Payment Methods",
        backArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Staticdata.showPayment
                    ? paymentIntentDummy(context)
                    : paymentIntent(context);
              },
              child: Staticdata.isActive
                  ? Container(
                      height: 60,
                      color: Colors.green,
                      width: double.infinity,
                      child: Center(
                        child: AppText.appText(
                          "Tap to accept",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.white,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: AppTheme.appColor),
                          SizedBox(width: 12),
                          AppText.appText(
                            "Add New Card",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          Spacer(),
                          Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.appColor,
                          ),
                        ],
                      ),
                    ),
            ),
            SizedBox(height: 20),
            AppText.appText(
              Staticdata.isActive ? "Accept Offer" : "Payment Methods",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              textColor: AppTheme.lableText,
            ),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? GifLoader()
                  : ListView.builder(
                      itemCount: cardData.length,
                      itemBuilder: (context, index) {
                        final card = cardData[index];
                        return GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: AppTheme.appColor,
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText.appText(
                                        "Card Number",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(height: 5),
                                      AppText.appText(
                                        "${card["cardNumber"]}",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> paymentIntent(context) async {
    try {
      final requestData = {"offerId": widget.offerId};
      final response = await dio.post(
        path: AppUrls.paymentIntent,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final payfastUrl = response.data["data"]["payfastUrl"];
        final Map<String, String> formFields = Map<String, dynamic>.from(
          response.data["data"]["formFields"],
        ).map((key, value) => MapEntry(key, value.toString()));

        logger.i({
          "event": "opening_payfast_webview_from_parent_card",
          "paymentIntentPath": AppUrls.paymentIntent,
          "requestData": requestData,
          "payfastUrl": payfastUrl,
          "formFields": formFields,
          "responseData": response.data["data"],
        });

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PayFastWebView(payfastUrl: payfastUrl, formFields: formFields),
          ),
        );

        switch (result) {
          case "success":
            AppToast.success(context: context, msg: "Payment Successful ✅");
            break;
          case "failure":
            AppToast.error(context: context, msg: "Payment Failed ❌");
            break;
          case "cancelled":
            AppToast.error(context: context, msg: "Payment Cancelled ⚠️");
            break;
          case "timeout":
            AppToast.error(context: context, msg: "Payment Timeout ⚠️");
            break;
          default:
            AppToast.error(context: context, msg: "Payment Error ❌");
        }
      } else if (response.statusCode == 401 &&
          response.data["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      debugPrint("Error initiating payment: $e");
    }
  }

  Future<void> paymentIntentDummy(context) async {
    try {
      final response = await dio.post(
        path: AppUrls.paymentIntentDummy,
        data: {"offerId": widget.offerId},
      );

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "Payment Successful ✅");
      } else if (response.statusCode == 401 &&
          response.data["errors"][0]["message"] == "TokenExpired") {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
        handleTokenExpiration();
      } else {
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      debugPrint("Error initiating payment: $e");
    }
  }

  void getParentCards(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      Response response = await dio.get(path: AppUrls.getParentCards);

      if (response.statusCode == 200) {
        AppToast.success(context: context, msg: "${response.data["message"]}");

        setState(() {
          cardData = response.data["data"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        AppToast.error(
          context: context,
          msg: "${response.data["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      if (kDebugMode) print("Something went wrong: $e");
      AppToast.error(context: context, msg: "Something went wrong $e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
