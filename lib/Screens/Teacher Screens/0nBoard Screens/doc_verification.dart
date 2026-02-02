import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_veirfy_provider.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/data_model.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/submission_screen.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class TutorDocVerificationScreen extends StatefulWidget {
  final TutorOnboardData onboardData;
  final VoidCallback onBackTap;

  const TutorDocVerificationScreen(
      {super.key, required this.onboardData, required this.onBackTap});

  @override
  State<TutorDocVerificationScreen> createState() =>
      _TutorDocVerificationScreenState();
}

class _TutorDocVerificationScreenState
    extends State<TutorDocVerificationScreen> {
  bool isLoading = false;
  late AppDio dio;
  AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  widget.onBackTap.call();
                },
                child: Image.asset(
                  "assets/images/arrowBack.png",
                  height: 28,
                ),
              ),
            ),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildUploadSection(fileProvider),
            const SizedBox(height: 20),
            isLoading ? const GifLoader() : _buildProceedButton(fileProvider),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ---------------- Header ----------------
  Widget _buildHeader() {
    return Text.rich(
      TextSpan(
        text: 'Upload Your ',
        style: TextStyle(
          fontSize: 44,
          color: AppTheme.black,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: 'Documents',
            style: TextStyle(
              color: AppTheme.appColor,
              fontWeight: FontWeight.w600,
              fontSize: 44,
            ),
          ),
          TextSpan(text: ' For Your '),
          TextSpan(
            text: 'Verifications',
            style: TextStyle(
              color: AppTheme.appColor,
              fontWeight: FontWeight.w600,
              fontSize: 44,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }

  /// ---------------- Upload Section ----------------
  Widget _buildUploadSection(FileProvider fileProvider) {
    return Container(
      width: ScreenSize(context).width,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderCOlor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/docVerify.png', height: 70),
          AppText.appText(
            "Tap To Upload Documents",
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 20),

          // Resume
          _buildFileTile(
            title: "1. Resume",
            hint: "(PDF, Max 2MB)",
            type: "resume",
            fileName: fileProvider.resumeFile?.file.name,
            onTap: () => fileProvider.pickFile("resume"),
            onDelete: () => fileProvider.removeFile("resume"),
          ),
          const SizedBox(height: 20),

          // ID Front
          _buildFileTile(
            title: "2. ID Card Front",
            hint: "(JPG/PNG)",
            type: "idFront",
            fileName: fileProvider.idFrontFile?.file.name,
            onTap: () => fileProvider.pickFile("idFront"),
            onDelete: () => fileProvider.removeFile("idFront"),
          ),
          const SizedBox(height: 20),

          // ID Back
          _buildFileTile(
            title: "3. ID Card Back",
            hint: "(JPG/PNG)",
            type: "idBack",
            fileName: fileProvider.idBackFile?.file.name,
            onTap: () => fileProvider.pickFile("idBack"),
            onDelete: () => fileProvider.removeFile("idBack"),
          ),
        ],
      ),
    );
  }

  /// ---------------- File Upload Tile ----------------
  Widget _buildFileTile({
    required String title,
    required String hint,
    required String type,
    required String? fileName,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final hasFile = fileName != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: ScreenSize(context).width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppTheme.borderCOlor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppTheme.lighttxtColor,
                  ),
                  AppText.appText(
                    hasFile ? "     $fileName" : "     $hint",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textColor: AppTheme.hintColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            /// Delete Icon if file exists
            if (hasFile)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  /// ---------------- Proceed Button ----------------
  Widget _buildProceedButton(FileProvider fileProvider) {
    return AppButton.appButton(
      "Proceed",
      context: context,
      onTap: () {
        if (fileProvider.resumeFile != null &&
            fileProvider.idFrontFile != null &&
            fileProvider.idBackFile != null) {
          widget.onboardData.resumeFile =
              File(fileProvider.resumeFile!.file.path!);
          widget.onboardData.idFrontFile =
              File(fileProvider.idFrontFile!.file.path!);
          widget.onboardData.idBackFile =
              File(fileProvider.idBackFile!.file.path!);

          docVerify(context, widget.onboardData);
        } else {
          AppToast.error(
            context: context,
            msg: "Please upload Resume, ID Front, and ID Back",
          );
        }
      },
      textColor: AppTheme.white,
      border: false,
      height: 52,
      backgroundColor: AppTheme.primaryCOlor,
    );
  }

  /// ---------------- API Call ----------------
  void docVerify(BuildContext context, TutorOnboardData data) async {
    setState(() => isLoading = true);

    try {
      FormData formData = FormData.fromMap({
        "subjects": jsonEncode(data.selectedSubjects),
        "bankName": data.selectedBank,
        "grade": jsonEncode(data.selectedGrades), // <- encode list as JSON
        "curriculum": jsonEncode(data.selectedCurriculums),
        "accountNumber": data.accountNumber?.replaceAll(RegExp(r'\D'), ''),
        if (data.resumeFile != null)
          "resume": await MultipartFile.fromFile(data.resumeFile!.path,
              filename: 'resume.pdf'),
        if (data.idFrontFile != null)
          "idFront": await MultipartFile.fromFile(data.idFrontFile!.path,
              filename: 'id_front.pdf'),
        if (data.idBackFile != null)
          "idBack": await MultipartFile.fromFile(data.idBackFile!.path,
              filename: 'id_back.pdf'),
      });

      Response response = await dio.post(
        path: AppUrls.onBoard,
        data: formData,
      );

      var responseData = response.data;

      if (response.statusCode == 201) {
        AppToast.success(
          context: context,
          msg: "${responseData["message"]}",
        );

        setState(() => isLoading = false);

        pushUntil(
          context,
          const SubmissionCompleteScreen(tutor: true),
        );
      } else {
        setState(() => isLoading = false);
        AppToast.error(
          context: context,
          msg: "${responseData["errors"][0]["message"]}",
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      AppToast.error(
        context: context,
        msg: "Something went wrong: $e",
      );
    }
  }
}
