import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_education_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';

class AddEducationBottomSheet extends StatefulWidget {
  final Education? education;
  const AddEducationBottomSheet({super.key, this.education});

  @override
  State<AddEducationBottomSheet> createState() =>
      _AddEducationBottomSheetState();
}

class _AddEducationBottomSheetState extends State<AddEducationBottomSheet> {
  final TextEditingController _institute = TextEditingController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _degree = TextEditingController();
  DateTime? _startDateRaw;
  DateTime? _endDateRaw;
  bool isContinue = false;

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      _institute.text = widget.education!.institute;
      _description.text = widget.education!.description;
      _degree.text = widget.education!.degree;

      _startDateRaw = DateTime.parse(widget.education!.startDate);
      _startDate.text = DateFormat('dd/MM/yyyy').format(_startDateRaw!);

      // ✅ End Date handling
      final endDate = widget.education!.endDate;

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
    final provider = Provider.of<EducationProvider>(context, listen: false);
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Container(
                height: 1,
                width: ScreenSize(context).width,
                color: AppTheme.hintColor),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                children: [
                  customLableField(
                      height: 52.0,
                      lable: "Name of Institute *",
                      controller: _institute,
                      hintText: "University of the Punjab"),
                  const SizedBox(height: 12),
                  customLableField(
                      height: 52.0,
                      lable: "Degree *",
                      controller: _degree,
                      hintText: "BS-IT"),
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
                        "Currently studying here",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _dateField(context, "From Date", _startDate,
                              (date) => _startDateRaw = date)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateField(
                          context,
                          "To Date",
                          _endDate,
                          (date) => _endDateRaw = date,
                          isDisabled: isContinue,
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
                      maxLines: 3),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: widget.education == null
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: [
                      if (widget.education != null)
                        AppButton.appButton(
                          context: context,
                          "Delete",
                          width: 83,
                          backgroundColor: Colors.red,
                          border: false,
                          onTap: () => _deleteEducation(context, provider),
                        ),
                      if (widget.education != null) const SizedBox(width: 10),
                      provider.addEduLoader
                          ? GifLoader()
                          : AppButton.appButton(
                              context: context,
                              widget.education == null ? "Add" : "Update",
                              width: 83,
                              onTap: () => _saveEducation(context, provider),
                            ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isEdit = widget.education != null;
    return Padding(
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
                        image: AssetImage("assets/images/radial.png"))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(isEdit
                      ? "assets/images/editBottom.png"
                      : "assets/images/addPlus.png"),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context); // 👈 only this closes the sheet
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
          AppText.appText(
            isEdit ? "Edit Education" : "Add Education",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 10),
          AppText.appText("Edit Education to your profile",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              textColor: Color(0xff4D5874)),
        ],
      ),
    );
  }

  Widget _dateField(context, String label, TextEditingController controller,
      Function(DateTime) onPicked,
      {bool isDisabled = false}) {
    return GestureDetector(
      onTap: isDisabled
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
                        primary:
                            AppTheme.primaryCOlor, // header + selected date
                        onPrimary: Colors.white, // header text
                        onSurface: Colors.black, // calendar text
                      ),
                      dialogBackgroundColor: Colors.white,
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: Colors.white,

                        /// Selected date
                        dayBackgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return AppTheme.primaryCOlor;
                          }
                          return null;
                        }),
                        dayForegroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return Colors.black;
                        }),

                        /// Today border
                        todayBorder:
                            BorderSide(color: AppTheme.primaryCOlor, width: 1),

                        /// Shape
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        /// Buttons
                        confirmButtonStyle: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryCOlor,
                        ),
                        cancelButtonStyle: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                FocusScope.of(context).unfocus();
                setState(() {
                  onPicked(pickedDate);
                  controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                });
              }
            },
      child: AbsorbPointer(
        child: customLableField(
          height: 52.0,
          lable: label,
          controller: controller,
          hintText: "DD/MM/YYYY",
        ),
      ),
    );
  }

  Future<void> _saveEducation(context, EducationProvider provider) async {
    if (_institute.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter Institute Name");
      return;
    }

    if (_degree.text.trim().isEmpty) {
      AppToast.error(context: context, msg: "Please enter Degree");
      return;
    }

    if (_startDateRaw == null) {
      AppToast.error(context: context, msg: "Please select Start Date");
      return;
    }

    if (!isContinue && _endDateRaw == null) {
      AppToast.error(
        context: context,
        msg: "Please select End Date or mark as Currently Studying",
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
      AppToast.error(context: context, msg: "Please enter Description");
      return;
    }
    if (_description.text.trim().length < 10) {
      AppToast.error(
        context: context,
        msg: "Description must be at least 10 characters",
      );
      return;
    }

    final edu = Education(
      id: widget.education?.id ?? '',
      institute: _institute.text.trim(),
      startDate: _startDateRaw?.toIso8601String() ?? '',
      endDate: isContinue ? 'Present' : _endDateRaw?.toIso8601String() ?? '',
      description: _description.text.trim(),
      degree: _degree.text.trim(),
    );
    bool success;

    if (widget.education == null) {
      success = await provider.addEducation(edu, context);
    } else {
      if (!_hasEducationChanges()) {
        AppToast.error(
          context: context,
          msg: "No changes detected",
        );
        return;
      }

      success = await provider.updateEducation(edu, context);
    }
    if (success) {
      Navigator.pop(context);
      // await Future.delayed(const Duration(milliseconds: 200));
      // if (mounted) {
      AppToast.success(
        context: context,
        msg: widget.education == null
            ? "Education Added successfully"
            : "Education Updated successfully",
      );
      // }
    }
  }

  bool _hasEducationChanges() {
    if (widget.education == null) return true;

    final original = widget.education!;

    final currentStart = _startDateRaw?.toIso8601String() ?? '';
    final currentEnd =
        isContinue ? 'Present' : _endDateRaw?.toIso8601String() ?? '';

    return original.institute != _institute.text.trim() ||
        original.degree != _degree.text.trim() ||
        original.description != _description.text.trim() ||
        original.startDate != currentStart ||
        original.endDate != currentEnd;
  }

  Future<void> _deleteEducation(context, EducationProvider provider) async {
    final confirmed = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Education"),
        content: const Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );
    if (confirmed == true) {
      bool success =
          await provider.deleteEducation(widget.education!.id, context);
      if (success) {
        Navigator.pop(context);
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          AppToast.success(
            context: context,
            msg: "Education Deleted successfully",
          );
        }
      }
    }
  }
}
