import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Models/Parent%20Side/child_detail_model.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Profile/add_child_sheet.dart';

class ChildDetails extends StatefulWidget {
  final String userId;
  final bool isTutorSide;

  const ChildDetails(
      {super.key, required this.userId, this.isTutorSide = false});

  @override
  State<ChildDetails> createState() => _ChildDetailsState();
}

class _ChildDetailsState extends State<ChildDetails> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _curriculumController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void clearFields() {
    _ageController.clear();
    _schoolController.clear();
    _genderController.clear();
    _gradeController.clear();
    _curriculumController.clear();
  }

  void populateFields(Child child) {
    _ageController.text = child.age;
    _schoolController.text = capitalizeEachWord(child.school);
    _genderController.text = capitalizeEachWord(child.gender);
    _gradeController.text = child.grade;
    _curriculumController.text = child.curriculum;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParentProfileProvider>(context);

    if (provider.isLoading) {
      return GifLoader();
    }

    final child = provider.selectedChild;

    if (child != null) {
      populateFields(child);
    } else {
      clearFields(); // 👈 ADD THIS
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 170,
                  ),
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffD4D8E2)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<Child>(
                      value: provider.selectedChild,
                      isExpanded: true,
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        offset: const Offset(0, -5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (Child? value) {
                        if (value != null) {
                          provider.selectChild(value);
                        }
                      },
                      items: provider.children.map((child) {
                        return DropdownMenuItem<Child>(
                          value: child,
                          child: Text(
                            "${child.firstName} ${child.lastname}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: child == provider.selectedChild
                                  ? AppTheme.appColor
                                  : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      selectedItemBuilder: (context) {
                        return provider.children.map((child) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AppText.appText(
                              "${child.firstName} ${child.lastname}",
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w400,
                            ),
                          );
                        }).toList();
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        height: 44,
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(Icons.keyboard_arrow_down),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              ),
              widget.isTutorSide == false
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: AppButton.appButton(
                        "Add Child",
                        image: "assets/images/plus.png",
                        context: context,
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: AppTheme.white,
                            context: context,
                            isScrollControlled: true,
                            isDismissible:
                                false, // 👈 disable tap outside to close
                            enableDrag: false, // 👈 disable drag down to close
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) => const AddChildBottomSheet(
                              isEdit: false,
                            ),
                          );
                        },
                        height: 36,
                        width: 100,
                        textColor: AppTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ))
                  : SizedBox.shrink()
            ],
          ),
          const SizedBox(height: 20),
          customLableField(
              lable: "Age", controller: _ageController, readOnly: true),
          const SizedBox(height: 20),
          customLableField(
              lable: "School", controller: _schoolController, readOnly: true),
          const SizedBox(height: 20),
          customLableField(
              lable: "Grade", controller: _gradeController, readOnly: true),
          const SizedBox(height: 20),
          customLableField(
              lable: "Curriculum",
              controller: _curriculumController,
              readOnly: true),
          const SizedBox(height: 20),
          customLableField(
              lable: "Gender", controller: _genderController, readOnly: true),
          const SizedBox(height: 20),
          widget.isTutorSide == false && provider.children.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: AppButton.appButton(
                          "Edit Child",
                          image: "assets/images/edit.png",
                          context: context,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: AppTheme.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) => AddChildBottomSheet(
                                  isEdit: true, child: provider.selectedChild),
                            );
                          },
                          height: 36,
                          width: 100,
                          textColor: AppTheme.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
                    Align(
                        alignment: Alignment.centerRight,
                        child: AppButton.appButton(
                          "Delete Child",
                          image: "assets/images/del.png",
                          context: context,
                          onTap: () async {
                            final confirm = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.white,
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                    "Are you sure you want to delete this child?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: AppText.appText("Cancel",
                                          textColor: AppTheme.grey)),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: AppText.appText("Delete",
                                          textColor: Colors.red)),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await provider.deleteChild(
                                  provider.selectedChild!.id, context);
                            }
                          },
                          height: 36,
                          width: 120,
                          backgroundColor: Colors.red,
                          textColor: AppTheme.white,
                          borderColor: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                )
              : SizedBox.shrink(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
