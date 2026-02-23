import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/Screens/Drawer/drawer.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class SessionCheckOut extends StatefulWidget {
  final String ruuningId;
  final String sessionId;
  final String parentId;
  final String tutorId;
  const SessionCheckOut(
      {super.key,
      required this.sessionId,
      required this.parentId,
      required this.tutorId,
      required this.ruuningId});

  @override
  State<SessionCheckOut> createState() => _SessionCheckOutState();
}

class _SessionCheckOutState extends State<SessionCheckOut> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _headlineController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool isLoading = false;

  late AppDio dio;
  final AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TutorDashBoardProvider>();
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: SideMenuDrawer(
        crossOnTap: () => _scaffoldKey.currentState?.closeEndDrawer(),
        isTutor: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset("assets/images/Background.png", fit: BoxFit.fill),
          ),
          Column(
            children: [
              CustomAppBar(taskSummary: provider.tasks),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: ScreenSize(context).width,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.description_outlined,
                                    size: 25,
                                  ),
                                  const SizedBox(width: 8),
                                  AppText.appText(
                                    "Post Session Notes",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              customLableField(
                                  lable: "Heading",
                                  controller: _headlineController,
                                  height: 50.0),
                              const SizedBox(height: 20),
                              customLableField(
                                  lable: "Description",
                                  textType: TextInputType.multiline,
                                  controller: _notesController,
                                  height: 210.0,
                                  maxLines: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        AppButton.appButton(
                          "Check Out",
                          context: context,
                          onTap: () {
                            postNotes(context);
                          },
                          height: 60,
                          fontSize: 20,
                          imgHeight: 20,
                          textColor: AppTheme.white,
                          border: false,
                          image: "assets/images/clock.png",
                          imgColor: AppTheme.white,
                          backgroundColor: AppTheme.appColor,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void checkOut(context) async {
    final provider =
        Provider.of<TutorDashBoardProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> params = {
        "id": widget.ruuningId,
        "tutorId": widget.tutorId,
        "parentId": widget.parentId,
        "sessionId": widget.sessionId,
        "status": "COMPLETED",
      };
      Response response =
          await dio.put(path: AppUrls.updateSubSession, data: params);
      var responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLoading = false;
        });

        provider.runningSessions.clear();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (context.mounted) Navigator.pop(context);
          if (mounted) {
            AppToast.success(
                context: context, msg: "Checked Out Successfully!");
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Something went wrong: $e");
      }
      AppToast.error(context: context, msg: "Something went wrong$e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void postNotes(context) async {
    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> params = {
        "sessionId": widget.ruuningId,
        "headline": _headlineController.text,
        "description": _notesController.text,
      };
      Response response = await dio.post(path: AppUrls.addNotes, data: params);
      var responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        checkOut(context);
      } else {
        setState(() {
          isLoading = false;
        });
        AppToast.error(
            context: context, msg: "${responseData["errors"][0]["message"]}");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Something went wrong: $e");
      }
      AppToast.error(context: context, msg: "Something went wrong$e");
      setState(() {
        isLoading = false;
      });
    }
  }
}
