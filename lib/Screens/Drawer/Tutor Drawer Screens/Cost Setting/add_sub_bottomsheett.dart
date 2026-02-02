import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/subjects_model.dart';
import 'package:ustaad/Providers/Tutor%20Side/subject_cost_provider.dart';
import 'package:ustaad/Models/Tutor%20Side/subject_cost_model.dart';

class AddCostSubjectSheet extends StatefulWidget {
  const AddCostSubjectSheet({super.key});

  @override
  State<AddCostSubjectSheet> createState() => _AddCostSubjectSheetState();
}

class _AddCostSubjectSheetState extends State<AddCostSubjectSheet> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController controller = TextEditingController();
  List<SubjectsModel> subjects = [];
  SubjectsModel? selectedSubject;

  bool button = false;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final response = await rootBundle.loadString('assets/subjects.json');
    final List data = json.decode(response);

    final costProvider =
        Provider.of<CostSettingProvider>(context, listen: false);
    final addedSubjectNames =
        costProvider.subjects.map((e) => e.name.toLowerCase().trim()).toSet();

    setState(() {
      subjects = data
          .map((e) => SubjectsModel.fromJson(e))
          .where((subject) =>
              !addedSubjectNames.contains(subject.name.toLowerCase().trim()))
          .toList();
    });
  }

  void _addSubjectToProvider() {
    final subjectName = _subjectController.text.trim();
    if (subjectName.isEmpty) {
      AppToast.error(context: context, msg: "Please enter a subject name.");

      return;
    }
    final cost = controller.text.trim();

    if (cost.isEmpty) {
      AppToast.error(context: context, msg: "Please enter a subject cost.");

      return;
    }
    final newSubject = SubjectModel(
      name: subjectName,
      active: button.toString(),
      cost: cost,
    );

    final provider = Provider.of<CostSettingProvider>(context, listen: false);
    provider.addSubject(newSubject, context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/radial.png"),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset("assets/images/addPlus.png"),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  AppText.appText(
                    "Add Subject",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 10),
                  AppText.appText(
                    "Add relevant subject to your profile",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    textColor: const Color(0xff4D5874),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              width: ScreenSize(context).width,
              color: const Color(0xffE0E3EB),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.appText(
                    "Subject",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    textColor: AppTheme.lableText,
                  ),
                  const SizedBox(height: 8),
                  _buildSubjectDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.appText("Toggle",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppTheme.lableText),
                  Transform.scale(
                    scale: 0.60,
                    child: Switch(
                      activeTrackColor: AppTheme.primaryCOlor,
                      activeThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xffE0E3EB),
                      inactiveThumbColor: const Color(0xffC8CDDA),
                      value: button,
                      onChanged: (val) {
                        setState(() {
                          button = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.appText("Cost:",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppTheme.lableText),
                  CustomAppTextField(
                    controller: controller,
                    width: 130,
                    texthint: "Rs. 1000",
                    txtType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 1,
              width: ScreenSize(context).width,
              color: const Color(0xffE0E3EB),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: AppButton.appButton(
                  "Add",
                  context: context,
                  width: 85,
                  height: 52,
                  onTap: _addSubjectToProvider,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffD4D8E2)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<SubjectsModel>(
          isExpanded: true,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("Select Subject"),
          ),
          value: selectedSubject,
          items: subjects.map((subject) {
            return DropdownMenuItem<SubjectsModel>(
              value: subject,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  subject.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedSubject = value;
              _subjectController.text = value?.name ?? "";
            });
          },
          dropdownStyleData: DropdownStyleData(
            offset: const Offset(0, -10),
            maxHeight: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
