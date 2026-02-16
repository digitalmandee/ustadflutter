import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Parent%20Side/add_child_model.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class ParentChildProfile extends StatefulWidget {
  final Function()? onTap;
  const ParentChildProfile({
    super.key,
    this.onTap,
  });

  @override
  State<ParentChildProfile> createState() => _ParentChildProfileState();
}

class _ParentChildProfileState extends State<ParentChildProfile> {
  final List<ChildProfileModel> childList = [ChildProfileModel()];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  late AppDio dio;
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
  final List<String> allGrades = [
    "Pre-KG",
    "KG-1",
    "KG-2",
    "Grade 1",
    "Grade 2",
    "Grade 3",
    "Grade 4",
    "Grade 5",
    "Grade 6",
    "Grade 7",
    "Grade 8",
    "Matriculation",
    "Intermediate",
    "O Level",
    "A Level"
  ];
  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentChild = childList.last;

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
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/images/arrowBack.png",
                  height: 28,
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'To Continue.. Just ',
                style: TextStyle(
                  fontSize: 44,
                  color: AppTheme.black,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Add',
                    style: TextStyle(
                      color: AppTheme.appColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 44,
                    ),
                  ),
                  TextSpan(text: ' Your '),
                  TextSpan(
                    text: "Child's Profile",
                    style: TextStyle(
                      color: AppTheme.appColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 44,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            ...List.generate(childList.length, (i) {
              final child = childList[i];
              final title = child.firstName.text.isNotEmpty
                  ? child.firstName.text
                  : "Add details of your child";

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    AppText.appText(
                      "Child ${i + 1}: ",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    AppText.appText(
                      title,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),
            // Form for last child
            buildChildForm(currentChild, childList.length),
            const SizedBox(height: 20),

            isLoading
                ? const GifLoader()
                : Column(
                    children: [
                      AppButton.appButton("Add Another Child",
                          context: context,
                          onTap: () =>
                              addSingleChild(currentChild, context, false),
                          textColor: AppTheme.black,
                          border: true,
                          height: 44,
                          borderColor: const Color(0xffD4D8E2),
                          backgroundColor: Colors.transparent),
                      const SizedBox(height: 12),
                      AppButton.appButton("Proceed",
                          context: context,
                          onTap: () => submitLastChildAndProceed(currentChild),
                          textColor: AppTheme.white,
                          border: false,
                          height: 44,
                          backgroundColor: AppTheme.primaryCOlor),
                      const SizedBox(height: 20),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildChildForm(ChildProfileModel child, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage: child.selectedImage != null
                  ? FileImage(child.selectedImage!)
                  : const AssetImage("assets/images/parentProfile.jpeg")
                      as ImageProvider,
            ),
            Column(
              children: [
                AppButton.appButton("Upload New",
                    context: context,
                    width: 200,
                    onTap: () => _pickImage(index - 1),
                    backgroundColor: const Color(0xffF1FCF9),
                    border: false,
                    textColor: AppTheme.appColor),
                SizedBox(
                  height: 10,
                ),
                AppButton.appButton("Delete Image",
                    context: context,
                    width: 200,
                    onTap: () => _deleteImage(index - 1),
                    backgroundColor: const Color(0xffFEECEC),
                    border: false,
                    textColor: Colors.red),
              ],
            )
          ],
        ),
        const SizedBox(height: 20),
        customLableField(
            lable: "Child First Name", controller: child.firstName),
        const SizedBox(height: 20),
        customLableField(lable: "Child Last Name", controller: child.lastname),
        const SizedBox(height: 20),
        AppText.appText(
          "Curriculum",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          textColor: AppTheme.lableText,
        ),
        const SizedBox(height: 8),
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
                value: child.selectedCurriculum,
                onChanged: (value) {
                  setState(() {
                    child.selectedCurriculum = value;
                    if (value != "Others") {
                      child.otherCurriculum.clear();
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
                  offset: const Offset(0, -5), // 👈 container ke neeche
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ))),
        if (child.selectedCurriculum == "Others")
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CustomAppTextField(
              width: double.infinity,
              texthint: "Enter Curriculum Name",
              controller: child.otherCurriculum,
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
            _genderTile("Male", child),
            _genderTile("Female", child),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText(
                    "Grade",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppTheme.lableText,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Grade',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.hintColor,
                            ),
                          ),
                          items: allGrades
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
                          value: child.selectedGrade,
                          onChanged: (value) {
                            setState(() {
                              child.selectedGrade = value;
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
                            offset:
                                const Offset(0, -5), // 👈 container ke neeche
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ))),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: customLableField(
                  lable: "Age",
                  textType: TextInputType.numberWithOptions(),
                  width: ScreenSize(context).width * 0.4,
                  controller: child.age),
            ),
          ],
        ),
        const SizedBox(height: 20),
        customLableField(lable: "School Name", controller: child.schoolName),
      ],
    );
  }

  Widget _genderTile(String gender, ChildProfileModel child) {
    return GestureDetector(
      onTap: () => setState(() => child.selectedGender = gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 44,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          border: Border.all(
            color: child.selectedGender == gender
                ? AppTheme.appColor
                : const Color(0xffD4D8E2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: gender,
              groupValue: child.selectedGender,
              activeColor: AppTheme.appColor,
              onChanged: (value) =>
                  setState(() => child.selectedGender = value),
            ),
            Text(gender),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => childList[index].selectedImage = File(pickedFile.path));
    }
  }

  void _deleteImage(int index) {
    setState(() => childList[index].selectedImage = null);
  }

  Future<void> addSingleChild(
      ChildProfileModel child, context, bool isLast) async {
    if (!validateFields(child)) return;

    setState(() => isLoading = true);

    final Map<String, dynamic> body = {
      "firstName": child.firstName.text.trim(),
      "lastName": child.lastname.text.trim(),
      "gender": child.selectedGender!.toLowerCase(),
      "curriculum": child.selectedCurriculum == "Others"
          ? child.otherCurriculum.text.trim()
          : child.selectedCurriculum,
      "grade": child.selectedGrade,
      "age": child.age.text.trim(),
      "schoolName": child.schoolName.text.trim(),
      "image": child.selectedImage != null
          ? "data:image/jpeg;base64,${base64Encode(child.selectedImage!.readAsBytesSync())}"
          : "",
    };

    try {
      final response = await dio.post(path: AppUrls.addChild, data: body);
      final data = response.data;

      if (response.statusCode == 201) {
        AppToast.success(context: context, msg: "${data["message"]}");
        setState(() => childList.add(ChildProfileModel()));
        if (isLast == true) {
          widget.onTap!();
        }
      } else {
        AppToast.error(context: context, msg: data["error"][0]["message"]);
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitLastChildAndProceed(ChildProfileModel child) async {
    final isAllEmpty = child.firstName.text.isEmpty &&
        child.selectedGrade == null &&
        child.age.text.isEmpty &&
        child.schoolName.text.isEmpty &&
        child.selectedGender == null &&
        child.selectedImage == null;
    print("nfelfmlfm $isAllEmpty and ${childList.length}");
    if (isAllEmpty && childList.length == 1) {
      AppToast.error(
          context: context,
          msg: "Please add at least one child before proceeding.");
      return;
    }

    if (!isAllEmpty) {
      await addSingleChild(child, context, true);
    }
    if (widget.onTap != null && childList.length > 1 && isAllEmpty) {
      widget.onTap!();
    }
  }

  bool validateFields(ChildProfileModel child) {
    // 🔹 Profile Image
    if (child.selectedImage == null) {
      _showError("Please upload profile image");
      return false;
    }
    // 🔹 Full Name
    if (child.firstName.text.trim().isEmpty) {
      _showError("Please enter child's first name");
      return false;
    }
    if (child.lastname.text.trim().isEmpty) {
      _showError("Please enter child's Last name");
      return false;
    }
    if (child.selectedCurriculum == null) {
      _showError("Please select a curriculum");
      return false;
    }

    if (child.selectedCurriculum == "Others" &&
        child.otherCurriculum.text.trim().isEmpty) {
      _showError("Please enter curriculum name");
      return false;
    }
    // 🔹 Age
    if (child.age.text.trim().isEmpty) {
      _showError("Please enter age");
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(child.age.text.trim())) {
      AppToast.error(context: context, msg: "Age must contain only digits");
      return false;
    }
    final age = int.tryParse(child.age.text.trim());
    if (age == null || age <= 0 || age > 25) {
      _showError("Please enter a valid age");
      return false;
    }

    // 🔹 Grade
    if (child.selectedGrade == null) {
      _showError("Please Select Grade");
      return false;
    }

    // 🔹 School Name
    if (child.schoolName.text.trim().isEmpty) {
      _showError("Please enter school name");
      return false;
    }

    // 🔹 Gender
    if (child.selectedGender == null) {
      _showError("Please select gender");
      return false;
    }

    return true;
  }

  void _showError(String message) {
    AppToast.error(
      context: context,
      msg: message,
    );
  }
}
