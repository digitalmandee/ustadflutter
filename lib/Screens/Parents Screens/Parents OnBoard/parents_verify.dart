import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_veirfy_provider.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parents%20OnBoard/onBoard_data_model.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/submission_screen.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class ParentsVerificationScreen extends StatefulWidget {
  final VoidCallback onBackTap;
  final ParentOnboardData parentOnboardData;
  const ParentsVerificationScreen({
    super.key,
    required this.onBackTap,
    required this.parentOnboardData,
  });

  @override
  State<ParentsVerificationScreen> createState() =>
      _ParentsVerificationScreenState();
}

class _ParentsVerificationScreenState extends State<ParentsVerificationScreen> {
  bool isLoading = false;
  late AppDio dio;

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        child: Column(
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

            // ID Front
            _buildUploadSection(fileProvider),

            const SizedBox(height: 30),

            isLoading ? const GifLoader() : _buildProceedButton(fileProvider),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

          _buildFileTile(
            title: "1. ID Card Front",
            hint: "(JPG/PNG)",
            type: "idFront",
            fileName: fileProvider.idFrontFile?.file.name,
            onTap: () => fileProvider.pickFile("idFront", context),
            onDelete: () => fileProvider.removeFile("idFront"),
          ),
          const SizedBox(height: 20),

          // ID Back
          _buildFileTile(
            title: "2. ID Card Back",
            hint: "(JPG/PNG)",
            type: "idBack",
            fileName: fileProvider.idBackFile?.file.name,
            onTap: () => fileProvider.pickFile("idBack", context),
            onDelete: () => fileProvider.removeFile("idBack"),
          ),
        ],
      ),
    );
  }

  /// ---------------- Header ----------------
  Widget _buildHeader() {
    return Text.rich(
      TextSpan(
        text: 'Upload Your ',
        style: TextStyle(
          fontSize: 36,
          color: AppTheme.black,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: 'Documents',
            style: TextStyle(
              color: AppTheme.appColor,
              fontWeight: FontWeight.w600,
              fontSize: 36,
            ),
          ),
          TextSpan(text: ' For Your '),
          TextSpan(
            text: 'Verification',
            style: TextStyle(
              color: AppTheme.appColor,
              fontWeight: FontWeight.w600,
              fontSize: 36,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.start,
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
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: AppTheme.borderCOlor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
      onTap: () => uploadDocuments(context, fileProvider),
      textColor: AppTheme.white,
      border: false,
      height: 52,
      backgroundColor: AppTheme.primaryCOlor,
    );
  }

  /// ---------------- API Call ----------------
  void uploadDocuments(BuildContext context, FileProvider fileProvider) async {
    if (fileProvider.idFrontFile == null || fileProvider.idBackFile == null) {
      AppToast.error(
        context: context,
        msg: "Please upload both ID Front and Back.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final idFront = fileProvider.idFrontFile!.file;
      final idBack = fileProvider.idBackFile!.file;

      final formData = FormData.fromMap({
        "idFront":
            await MultipartFile.fromFile(idFront.path!, filename: idFront.name),
        "idBack":
            await MultipartFile.fromFile(idBack.path!, filename: idBack.name),
        "accountNumber": widget.parentOnboardData.accountNumber
            ?.replaceAll(RegExp(r'\D'), ''),
        "bankName": widget.parentOnboardData.selectedBank,
      });

      final response =
          await dio.post(path: AppUrls.parentOnBoard, data: formData);
      final data = response.data;

      if (response.statusCode == 201) {
        AppToast.success(
          context: context,
          msg: "${data["message"]}",
        );
        fileProvider.clearAll();
        pushUntil(
          context,
          const SubmissionCompleteScreen(tutor: false),
        );
      } else {
        AppToast.error(
          context: context,
          msg: data["errors"][0]["message"],
        );
      }
    } catch (e) {
      AppToast.error(
        context: context,
        msg: "Upload failed: $e",
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
