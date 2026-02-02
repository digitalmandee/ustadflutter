import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/subject_cost_model.dart';
import 'package:ustaad/Providers/Tutor%20Side/subject_cost_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/Screens/Drawer/Tutor%20Drawer%20Screens/Cost%20Setting/add_sub_bottomsheett.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';

class CostSetting extends StatefulWidget {
  const CostSetting({super.key});

  @override
  State<CostSetting> createState() => _CostSettingState();
}

class _CostSettingState extends State<CostSetting> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<CostSettingProvider>(context, listen: false)
            .fetchCostSettings(context, false);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TutorDashBoardProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        taskSummary: provider.tasks,
        backArrow: true,
        menuIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<CostSettingProvider>(
                  builder: (context, provider, _) => _counterTile(
                    "Minimum Subjects",
                    provider.minSubjects,
                    () {
                      if (provider.minSubjects > 1) {
                        provider.updateMinSubjects(provider.minSubjects - 1);
                      }
                    },
                    () {
                      provider.updateMinSubjects(provider.minSubjects + 1);
                    },
                  ),
                ),
                Consumer<CostSettingProvider>(
                  builder: (context, provider, _) => _counterTile(
                    "Max Students Daily",
                    provider.maxStudents,
                    () {
                      if (provider.maxStudents > 1) {
                        provider.updateMaxStudents(provider.maxStudents - 1);
                      }
                    },
                    () {
                      provider.updateMaxStudents(provider.maxStudents + 1);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            AppText.appText("Cost Settings (Monthly)",
                fontWeight: FontWeight.w600, fontSize: 16),
            SizedBox(height: 10),
            Expanded(
              child: Consumer<CostSettingProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return GifLoader();
                  }

                  if (provider.subjects.isEmpty) {
                    return const Center(child: Text("No subjects added yet."));
                  }

                  return ListView.builder(
                    itemCount: provider.subjects.length,
                    itemBuilder: (context, index) {
                      final subject = provider.subjects[index];
                      if (!_controllers.containsKey(index)) {
                        _controllers[index] =
                            TextEditingController(text: subject.cost);
                      } else {
                        if (_controllers[index]!.text != subject.cost) {
                          _controllers[index]!.text = subject.cost;
                        }
                      }

                      final controller = _controllers[index]!;

                      return Column(
                        children: [
                          Row(
                            children: [
                              AppText.appText(capitalizeEachWord(subject.name),
                                  fontSize: 14, fontWeight: FontWeight.w500),
                              const Spacer(),
                              Transform.scale(
                                scale: 0.60,
                                child: Switch(
                                  activeTrackColor: AppTheme.primaryCOlor,
                                  activeColor: Colors.white,
                                  inactiveTrackColor: const Color(0xffE0E3EB),
                                  inactiveThumbColor: const Color(0xffC8CDDA),
                                  value: subject.active.toLowerCase() == "true"
                                      ? true
                                      : false,
                                  onChanged: (val) {
                                    provider.updateSubject(
                                      index,
                                      SubjectModel(
                                        name: subject.name,
                                        active: val.toString(),
                                        cost: subject.cost,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              CustomAppTextField(
                                controller: controller,
                                width: 130,
                                texthint: "Rs. 1000",
                                textDirection: TextDirection.ltr,
                                txtType: TextInputType.number,
                                onChanged: (val) {
                                  provider.updateSubject(
                                    index,
                                    SubjectModel(
                                      name: subject.name,
                                      active: subject.active,
                                      cost: val,
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 1,
                            width: ScreenSize(context).width,
                            color: const Color(0xffE0E3EB),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Align(
                alignment: Alignment.centerLeft,
                child: AppButton.appButton("Add More", onTap: () {
                  showModalBottomSheet(
                    backgroundColor: AppTheme.white,
                    context: context,
                    isScrollControlled: true,
                    isDismissible: false,
                    enableDrag: false,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => AddCostSubjectSheet(),
                  );
                },
                    context: context,
                    height: 28,
                    width: 105,
                    radius: 8.0,
                    fontSize: 14,
                    imgHeight: 9.33,
                    fontWeight: FontWeight.w400,
                    textColor: AppTheme.appColor,
                    borderColor: AppTheme.appColor,
                    border: true,
                    image: "assets/images/add.png",
                    backgroundColor: Color.fromARGB(255, 238, 253, 245))),
            SizedBox(height: 20),
            Consumer<CostSettingProvider>(
              builder: (context, provider, _) {
                if (provider.saveButtonLoader) {
                  return GifLoader();
                }
                return AppButton.appButton(
                  "Save",
                  context: context,
                  textColor: AppTheme.white,
                  backgroundColor: AppTheme.primaryCOlor,
                  onTap: () {
                    Provider.of<CostSettingProvider>(context, listen: false)
                        .saveCostSettings(context);
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _counterTile(String label, int value, VoidCallback onDecrement,
      VoidCallback onIncrement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.appText(label, fontSize: 14, fontWeight: FontWeight.w500),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Container(
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 5),
              width: ScreenSize(context).width * 0.4,
              decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderCOlor),
                  borderRadius: BorderRadius.circular(8)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: onDecrement,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.primaryCOlor),
                        child: Icon(
                          Icons.remove,
                          color: AppTheme.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Text("$value",
                          style: TextStyle(
                              fontSize: 18, color: AppTheme.lighttxtColor))),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: onIncrement,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppTheme.primaryCOlor),
                        child: Icon(
                          Icons.add,
                          color: AppTheme.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
