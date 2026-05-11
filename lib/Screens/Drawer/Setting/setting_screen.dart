import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/Screens/Authentication/SignIn/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_bar.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_field.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/base_image.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Helpers/loader.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Providers/Profile%20Setting/profile_setting_prov.dart';
import 'package:flutterustad/Screens/Authentication/Forgot%20Pass/forgot_pass.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/Screens/Drawer/Setting/change_email_phone.dart';
import 'package:flutterustad/config/keys/global.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<TutorEditProfileProvider>(
        context,
        listen: false,
      );
      emailController.text = provider.email;
      phoneController.text = provider.phone;
      provider.resetEditStates();
      if (!provider.hasData) {
        if (globalUserRole == "TUTOR") {
          provider
              .getTutorProfile(context)
              .then((_) => _setControllers(provider));
        } else {
          provider
              .getParentProfile(context)
              .then((_) => _setControllers(provider));
        }
      } else {
        _setControllers(provider);
        if (globalUserRole == "TUTOR") {
          provider.getTutorProfile(context, refresh: true);
        } else {
          provider.getParentProfile(context, refresh: true);
        }
      }
    });
  }

  void _setControllers(TutorEditProfileProvider provider) {
    print("here is the user at this time .....>!");
    if (fNameController.text.isEmpty) {
      fNameController.text = provider.fName;
    }
    if (lNameController.text.isEmpty) {
      lNameController.text = provider.lName;
    }
    if (emailController.text.isEmpty) {
      emailController.text = provider.email;
    }
    if (phoneController.text.isEmpty) {
      phoneController.text = provider.phone;
    }
    if (passwordController.text.isEmpty) {
      passwordController.text = provider.password;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<TutorEditProfileProvider>(context);
    bool canDelete =
        profile.hasData &&
        !profile.isLoading &&
        !profile.picLoading &&
        profile.image.isNotEmpty;
    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar1(title: "Settings", backArrow: true),
          backgroundColor: AppTheme.white,
          body: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<TutorEditProfileProvider>(
                    builder: (context, profile, child) {
                      return Container(
                        height: 105,
                        width: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: AppTheme.primaryCOlor,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: profile.picLoading
                                ? GifLoader()
                                : ClipOval(
                                    child: selectedImage != null
                                        ? Image.file(
                                            File(selectedImage!.path),
                                            fit: BoxFit.cover,
                                          )
                                        : profile.image.isNotEmpty
                                        ? profile.image.startsWith("http")
                                              ? Image.network(
                                                  profile.image,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Image.asset(
                                                          globalUserRole ==
                                                                  'TUTOR'
                                                              ? 'assets/images/tutorProfile.jpeg'
                                                              : "assets/images/parentProfile.jpeg",
                                                        );
                                                      },
                                                )
                                              : Base64ImageWidget(
                                                  base64String: profile.image,
                                                )
                                        : ClipOval(
                                            child: Image.asset(
                                              globalUserRole == 'TUTOR'
                                                  ? 'assets/images/tutorProfile.jpeg'
                                                  : "assets/images/parentProfile.jpeg",
                                            ),
                                          ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton.appButton(
                        "Edit",
                        context: context,
                        onTap: () => _pickImage(context),
                        width: 59,
                        height: 30,
                        backgroundColor: AppTheme.primaryCOlor,
                        border: false,
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: canDelete
                            ? () async {
                                bool deleted = await profile.deletePicture(
                                  context,
                                );
                                if (deleted && mounted) {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                }
                              }
                            : null,
                        child: Icon(
                          Icons.delete,
                          color: canDelete ? Colors.red : AppTheme.hintColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(height: 20),
                  customLableField(
                    lable: "First Name",
                    hintText: capitalizeEachWord(fNameController.text),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  customLableField(
                    lable: "Last Name",
                    hintText: capitalizeEachWord(lNameController.text),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  editableField(
                    label: "Email",
                    controller: emailController,
                    onTap: () {
                      push(context, ChangeEmailPhone(isPhone: false));
                    },
                  ),
                  const SizedBox(height: 20),
                  editableField(
                    label: "Contact Number",
                    controller: phoneController,
                    onTap: () {
                      push(context, ChangeEmailPhone(isPhone: true));
                    },
                  ),
                  const SizedBox(height: 20),
                  if (globalGoogleId == '')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.appText(
                          "Password",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          textColor: AppTheme.lableText,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xffD4D8E2)),
                            color: const Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText.appText(
                                  "********** ",
                                  fontSize: 20,
                                  textColor: AppTheme.hintColor,
                                ),
                                InkWell(
                                  onTap: () => push(
                                    context,
                                    ForgotPassScreen(isEditing: true),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 2,
                                        color: AppTheme.borderCOlor,
                                      ),
                                      const SizedBox(width: 10),
                                      AppText.appText(
                                        "Change",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (Staticdata.isActive) const SizedBox(height: 30),
                  if (Staticdata.isActive)
                    AppButton.appButton(
                      onTap: () {
                        showDeleteAccountDialog(context);
                      },
                      textColor: AppTheme.white,
                      border: false,
                      height: 52,
                      backgroundColor: Colors.red,
                      "Delete Account",
                      context: context,
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
        if (profile.hasData == false && profile.isLoading)
          const BlurGifLoader(),
      ],
    );
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> _pickImage(context) async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
      final provider = Provider.of<TutorEditProfileProvider>(
        context,
        listen: false,
      );

      if (globalUserRole == "TUTOR") {
        provider.updateTutorProfileImage(context, pickedFile);
      } else {
        provider.updateParentProfileImage(context, pickedFile);
      }
      globalUserPic = pickedFile.path;
    }
  }

  Widget editableField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    required Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppTheme.lableText,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomAppTextField(
                controller: controller,
                readOnly: true,
                obscureText: isPassword,
                textColor: Color(0xffA6ADBF),
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: onTap,
              child: Image.asset(
                "assets/images/edit.png",
                height: 25,
                color: AppTheme.primaryCOlor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Delete Account",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete your account? "
            "This action is permanent and will remove all your data, "
            "including profile information, images, and settings. "
            "You will not be able to recover your account once deleted.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss dialog first

                // Call your delete account API here
                final provider = Provider.of<TutorEditProfileProvider>(
                  context,
                  listen: false,
                );
                bool success = await provider.deleteAccount(context);

                if (success) {
                  // // Navigate user to login or welcome screen after deletion
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(builder: (_) => LogInScreen()),
                  //   (Route<dynamic> route) => false,
                  // );
                } else {
                  // Show error message

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to delete account. Try again."),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
