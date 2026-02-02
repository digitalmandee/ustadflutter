import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/base_image.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Parent%20Side/child_detail_model.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';

class AddChildBottomSheet extends StatefulWidget {
  final Child? child;
  final bool isEdit;

  const AddChildBottomSheet({super.key, this.child, required this.isEdit});

  @override
  State<AddChildBottomSheet> createState() => _AddChildBottomSheetState();
}

class _AddChildBottomSheetState extends State<AddChildBottomSheet> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController grade = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController schoolName = TextEditingController();
  final TextEditingController otherCurriculum = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<String> allCurriculums = [
    "Cambridge",
    "FBISE",
    "American",
    "IB",
    "Punjab Board",
    "Sindh Board",
    "Local",
    "Others"
  ];
  String? selectedGender;
  String? selectedCurriculum;
  XFile? selectedImage;
  bool isSubmitting = false;
  String? profilePic;
  @override
  void initState() {
    super.initState();
    if (widget.child != null) {
      firstNameController.text = widget.child!.firstName;
      lastNameController.text = widget.child!.lastname;
      grade.text = widget.child!.grade;
      age.text = widget.child!.age;
      schoolName.text = widget.child!.school;
      if (allCurriculums.contains(widget.child!.curriculum)) {
        selectedCurriculum = widget.child!.curriculum;
      } else {
        selectedCurriculum = "Others";
        otherCurriculum.text = widget.child!.curriculum;
      }

      selectedGender = widget.child!.gender.capitalize();
      profilePic = widget.child!.pic;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParentProfileProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: ScreenSize(context).height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context); // 👈 only this closes the sheet
                      },
                      icon: Icon(Icons.close),
                    ),
                  ),
                  AppText.appText(
                    widget.isEdit == true ? "Edit Child" : "Add Child",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: ScreenSize(context).width,
              color: AppTheme.hintColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildChildForm(),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!validateChildForm(context)) return;

                                      setState(() => isSubmitting = true);
                                      if (widget.child != null) {
                                        try {
                                          await provider.updateChild(
                                            id: widget.child!.id,
                                            firstName: firstNameController.text,
                                            lastName: lastNameController.text,
                                            grade: grade.text,
                                            curriculum: selectedCurriculum ==
                                                    "Others"
                                                ? otherCurriculum.text.trim()
                                                : selectedCurriculum!,
                                            age: age.text,
                                            schoolName: schoolName.text,
                                            gender:
                                                selectedGender!.toLowerCase(),
                                            imageFile: selectedImage,
                                          );
                                          Navigator.pop(context);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Error adding child.")),
                                          );
                                        } finally {
                                          setState(() => isSubmitting = false);
                                        }
                                      } else {
                                        try {
                                          await provider.addChild(
                                            firstName: firstNameController.text,
                                            lastName: lastNameController.text,
                                            curriculum: selectedCurriculum ==
                                                    "Others"
                                                ? otherCurriculum.text.trim()
                                                : selectedCurriculum!,
                                            grade: grade.text,
                                            age: age.text,
                                            schoolName: schoolName.text,
                                            gender:
                                                selectedGender!.toLowerCase(),
                                            imageFile: selectedImage,
                                          );
                                          pop(context);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Error adding child.")),
                                          );
                                        } finally {
                                          setState(() => isSubmitting = false);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryCOlor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                widget.isEdit == true ? "Update" : "Add",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validateChildForm(BuildContext context) {
    if (!isImageValid()) {
      AppToast.error(context: context, msg: "Please select a valid image");
      return false;
    }

    if (firstNameController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "First name is required");
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Last name is required");
      return false;
    }

    if (selectedCurriculum == null) {
      AppToast.error(context: context, msg: "Please select a curriculum");
      return false;
    }

    if (selectedCurriculum == "Others" && otherCurriculum.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter other curriculum");
      return false;
    }

    if (grade.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Grade is required");
      return false;
    }

    if (age.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Age is required");
      return false;
    }

    if (schoolName.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "School name is required");
      return false;
    }

    if (selectedGender == null) {
      AppToast.error(context: context, msg: "Please select gender");
      return false;
    }

    return true;
  }

  bool isImageValid() {
    if (widget.isEdit) {
      return selectedImage != null ||
          (profilePic != null && profilePic!.isNotEmpty);
    } else {
      return selectedImage != null;
    }
  }

  Widget _buildProfileImage() {
    // EDIT MODE + SERVER IMAGE (base64)
    if (widget.child != null && profilePic != null && profilePic!.isNotEmpty) {
      return Base64ImageWidget(
        base64String: profilePic!,
      );
    }

    // NEW IMAGE PICKED
    if (selectedImage != null) {
      return Image.file(
        File(selectedImage!.path),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    // DEFAULT IMAGE
    return Image.asset(
      "assets/images/user.png",
      width: 90,
      height: 90,
      fit: BoxFit.cover,
    );
  }

  Widget buildChildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.appColor, width: 1)),
                child: ClipOval(child: _buildProfileImage()),
              ),
              // CircleAvatar(
              //   radius: 45,
              //   backgroundColor: Colors.grey.shade200,
              //   child: ClipOval(
              //     child: _buildProfileImage(),
              //   ),
              // ),
              Column(
                children: [
                  AppButton.appButton("Upload New",
                      context: context,
                      width: 200,
                      onTap: () => _pickImage(),
                      backgroundColor: const Color(0xffF1FCF9),
                      border: false,
                      textColor: AppTheme.appColor),
                  SizedBox(
                    height: 10,
                  ),
                  selectedImage != null
                      ? AppButton.appButton("Delete Image",
                          context: context,
                          width: 200,
                          onTap: () => _deleteImage(),
                          backgroundColor: const Color(0xffFEECEC),
                          border: false,
                          textColor: Colors.red)
                      : SizedBox.shrink(),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          customLableField(
              lable: "First Name", controller: firstNameController),
          const SizedBox(height: 20),
          customLableField(lable: "Last Name", controller: lastNameController),
          const SizedBox(height: 20),
          AppText.appText("Curriculum",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textColor: AppTheme.lableText),
          const SizedBox(height: 10),
          DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Curriculum',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.hintColor,
                    ),
                  ),
                  items: allCurriculums
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  value: selectedCurriculum,
                  onChanged: (value) {
                    setState(() {
                      selectedCurriculum = value;
                      if (value != "Others") {
                        otherCurriculum.clear();
                      }
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderCOlor),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 150,
                    offset: const Offset(0, -5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ))),
          if (selectedCurriculum == "Others")
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomAppTextField(
                width: double.infinity,
                texthint: "Enter Curriculum Name",
                controller: otherCurriculum,
              ),
            ),
          const SizedBox(height: 20),
          AppText.appText("Gender",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              textColor: AppTheme.lableText),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _genderTile(
                "Male",
              ),
              _genderTile("Female"),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customLableField(
                  lable: "Grade",
                  width: ScreenSize(context).width * 0.4,
                  controller: grade),
              customLableField(
                  lable: "Age",
                  width: ScreenSize(context).width * 0.4,
                  controller: age),
            ],
          ),
          const SizedBox(height: 20),
          customLableField(lable: "School Name", controller: schoolName),
        ],
      ),
    );
  }

  Widget _genderTile(
    String gender,
  ) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 44,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedGender == gender
                ? AppTheme.appColor
                : const Color(0xffD4D8E2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: selectedGender,
              activeColor: AppTheme.appColor,
              onChanged: (value) => setState(() => selectedGender = value),
            ),
            AppText.appText(gender),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  void _deleteImage() {
    setState(() {
      selectedImage = null;
    });
  }
}
