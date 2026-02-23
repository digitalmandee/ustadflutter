import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/experience_model.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_exp_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';

class AddExperienceBottomSheet extends StatefulWidget {
  final Experience? experience; // null = add, not null = edit
  const AddExperienceBottomSheet({super.key, this.experience});

  @override
  State<AddExperienceBottomSheet> createState() =>
      _AddExperienceBottomSheetState();
}

class _AddExperienceBottomSheetState extends State<AddExperienceBottomSheet> {
  final TextEditingController _company = TextEditingController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _designation = TextEditingController();
  DateTime? _startDateRaw;
  DateTime? _endDateRaw;
  bool isContinue = false;

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      _company.text = widget.experience!.company;
      _startDateRaw = DateTime.tryParse(widget.experience!.startDate);
      if (_startDateRaw != null) {
        _startDate.text = DateFormat('dd/MM/yyyy').format(_startDateRaw!);
      }

      _description.text = widget.experience!.description;
      _designation.text = widget.experience!.designation;

      final endDate = widget.experience!.endDate;

      if (endDate.toLowerCase() == "present") {
        isContinue = true;
        _endDate.clear();
        _endDateRaw = null;
      } else if (endDate.isNotEmpty) {
        _endDateRaw = DateTime.parse(endDate);
        _endDate.text = DateFormat('dd/MM/yyyy').format(_endDateRaw!);
        isContinue = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.experience != null;
    final provider = Provider.of<ExperienceProvider>(context, listen: false);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/radial.png"))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(isEdit
                                ? "assets/images/editBottom.png"
                                : "assets/images/addPlus.png"),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // 👈 only this closes the sheet
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    AppText.appText(
                      isEdit ? "Edit Experience" : "Add Experience",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 10),
                    AppText.appText("Edit experience to your profile",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        textColor: Color(0xff4D5874)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                width: ScreenSize(context).width,
                color: AppTheme.hintColor,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    customLableField(
                      height: 52.0,
                      lable: "Name of Company *",
                      controller: _company,
                      hintText: "Company name",
                    ),
                    const SizedBox(height: 12),
                    customLableField(
                      height: 52.0,
                      lable: "Designation *",
                      controller: _designation,
                      hintText: "Designation",
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          child: Checkbox(
                            activeColor: AppTheme.appColor,
                            value: isContinue,
                            onChanged: (value) {
                              setState(() {
                                isContinue = value ?? false;
                                if (isContinue) {
                                  _endDate.clear();
                                  _endDateRaw = null;
                                }
                              });
                            },
                          ),
                        ),
                        AppText.appText(
                          "Currently Working here",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1980),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: AppTheme
                                            .primaryCOlor, // selected date bg
                                        onPrimary:
                                            Colors.white, // selected date text
                                        onSurface: Colors.black, // normal text
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              AppTheme.primaryCOlor,
                                        ),
                                      ),
                                      dialogTheme: DialogThemeData(
                                          backgroundColor: Colors.white),
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              if (pickedDate != null) {
                                setState(() {
                                  _startDateRaw = pickedDate;
                                  _startDate.text = DateFormat('dd/MM/yyyy')
                                      .format(pickedDate);
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: customLableField(
                                height: 52.0,
                                lable: "From Date",
                                controller: _startDate,
                                hintText: "DD/MM/YYYY",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: isContinue
                                ? null
                                : () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1980),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: AppTheme.primaryCOlor,
                                              onPrimary: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                            textButtonTheme:
                                                TextButtonThemeData(
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    AppTheme.primaryCOlor,
                                              ),
                                            ),
                                            dialogTheme: DialogThemeData(
                                                backgroundColor: Colors.white),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (pickedDate != null) {
                                      setState(() {
                                        _endDateRaw = pickedDate;
                                        _endDate.text = DateFormat('dd/MM/yyyy')
                                            .format(pickedDate);
                                      });
                                    }
                                  },
                            child: AbsorbPointer(
                              child: customLableField(
                                height: 52.0,
                                lable: "To Date",
                                controller: _endDate,
                                hintText: "DD/MM/YYYY",
                                readOnly: isContinue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    customLableField(
                      height: 100.0,
                      lable: "Description",
                      controller: _description,
                      hintText: "Enter Description",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: widget.experience == null
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.center,
                      children: [
                        if (widget.experience != null)
                          AppButton.appButton(
                            context: context,
                            "Delete",
                            width: 83,
                            border: false,
                            backgroundColor: Colors.red,
                            onTap: () => _deleteExperience(context, provider),
                          ),
                        SizedBox(
                          width: 10,
                        ),
                        AppButton.appButton(
                          context: context,
                          isEdit ? "Update" : "Add",
                          width: 83,
                          onTap: () async {
                            if (_company.text.trim().isEmpty) {
                              AppToast.error(
                                  context: context,
                                  msg: "Please enter Company Name");
                              return;
                            }

                            if (_designation.text.trim().isEmpty) {
                              AppToast.error(
                                  context: context,
                                  msg: "Please enter Designation");
                              return;
                            }

                            if (_startDateRaw == null) {
                              AppToast.error(
                                  context: context,
                                  msg: "Please select Start Date");
                              return;
                            }

                            if (!isContinue && _endDateRaw == null) {
                              AppToast.error(
                                context: context,
                                msg:
                                    "Please select End Date or mark as Currently Studying",
                              );
                              return;
                            }

                            if (!isContinue &&
                                _endDateRaw != null &&
                                _endDateRaw!.isBefore(_startDateRaw!)) {
                              AppToast.error(
                                context: context,
                                msg: "End Date cannot be before Start Date",
                              );
                              return;
                            }
                            if (_description.text.isEmpty) {
                              AppToast.error(
                                  context: context,
                                  msg: "Please enter Description");
                              return;
                            }
                            if (_description.text.trim().length < 10) {
                              AppToast.error(
                                context: context,
                                msg:
                                    "Description must be at least 10 characters",
                              );
                              return;
                            }

                            final provider = Provider.of<ExperienceProvider>(
                                context,
                                listen: false);
                            final exp = Experience(
                              id: widget.experience?.id ?? '',
                              company: _company.text.trim(),
                              startDate: _startDateRaw?.toIso8601String() ?? '',
                              endDate: isContinue
                                  ? "Present"
                                  : _endDateRaw?.toIso8601String() ?? '',
                              description: _description.text.trim(),
                              designation: _designation.text.trim(),
                            );
                            bool success = false;
                            if (isEdit) {
                              if (!_hasChanges()) {
                                AppToast.error(
                                  context: context,
                                  msg: "No changes detected",
                                );
                                return;
                              }

                              success =
                                  await provider.updateExperience(exp, context);
                            } else {
                              if (provider.addExpLoader == false) {
                                success =
                                    await provider.addExperience(exp, context);
                              }
                            }

                            if (success) {
                              Navigator.pop(context);
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                              if (mounted) {
                                AppToast.success(
                                  context: context,
                                  msg: isEdit
                                      ? "Experience Updated successfully"
                                      : "Experience Added successfully",
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasChanges() {
    if (widget.experience == null) return true;

    final original = widget.experience!;

    final currentStart = _startDateRaw?.toIso8601String() ?? '';
    final currentEnd =
        isContinue ? "Present" : _endDateRaw?.toIso8601String() ?? '';

    return original.company != _company.text.trim() ||
        original.designation != _designation.text.trim() ||
        original.description != _description.text.trim() ||
        original.startDate != currentStart ||
        original.endDate != currentEnd;
  }

  Future<void> _deleteExperience(context, ExperienceProvider provider) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 204, 227, 234),
        title: const Text("Delete Experience"),
        content: const Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  AppText.appText("Cancel", textColor: AppTheme.primaryCOlor)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  AppText.appText("Delete", textColor: AppTheme.primaryCOlor)),
        ],
      ),
    );
    if (confirmed == true) {
      bool success =
          await provider.deleteExperience(widget.experience!.id, context);

      if (success) {
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          AppToast.success(
            context: context,
            msg: "Experience Deleted successfully",
          );
        }
      }
    }
  }
}
