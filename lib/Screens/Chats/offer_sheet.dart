import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/capitalize.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Models/Tutor%20Side/subject_cost_model.dart';
import 'package:flutterustad/Providers/Tutor%20Side/subject_cost_provider.dart';
import 'package:flutterustad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:flutterustad/Screens/Chats/chat_modet.dart';
import 'package:flutterustad/config/dio/app_logger.dart';
import 'package:flutterustad/config/dio/dio.dart';

class CustomOfferSheet extends StatefulWidget {
  final String conversationId;
  final String userId;
  final String recieverId;
  final dynamic socketService;
  final List childrens;
  final Function(ChatMessage)? onMessageCreated;

  const CustomOfferSheet({
    super.key,
    required this.conversationId,
    required this.userId,
    required this.recieverId,
    required this.socketService,
    this.onMessageCreated,
    required this.childrens, // new param
  });

  @override
  State<CustomOfferSheet> createState() => _CustomOfferSheetState();

  static void show(
    BuildContext context,
    String conversationId,
    List childrens,
    String userId,
    String recieverId,
    dynamic socket,
    Function(ChatMessage) onMessageCreated,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CustomOfferSheet(
        conversationId: conversationId,
        userId: userId,
        childrens: childrens,
        recieverId: recieverId,
        socketService: socket,
        onMessageCreated: onMessageCreated,
      ),
    );
  }
}

class _CustomOfferSheetState extends State<CustomOfferSheet> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController sessionNumbers = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final List<ChatMessage> messages = [];
  Map<String, dynamic>? selectedChild;

  int subjectCount = 1;
  DateTime? startDate;

  List<String> selectedDays = [];
  DateTime? selectedStartDate;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  late AppDio dio;
  final AppLogger logger = AppLogger();
  List<SubjectModel> selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
    startDate = DateTime.now();
    if (mounted) {
      Provider.of<CostSettingProvider>(
        context,
        listen: false,
      ).fetchCostSettings(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 40,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Send Custom Offer",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /// Child Name
              AppText.appText(
                "Child Name *",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: AppTheme.lableText,
              ),
              const SizedBox(height: 6),

              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderCOlor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<Map<String, dynamic>>(
                    isExpanded: true,
                    value: selectedChild,
                    hint: AppText.appText(
                      "Select Child",
                      textColor: AppTheme.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    items: widget.childrens.map((child) {
                      final isSelected = child == selectedChild;
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: child,
                        child: Text(
                          capitalizeEachWord(
                            "${child["firstName"]} ${child["lastName"]}",
                          ),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.appColor
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                    selectedItemBuilder: (context) {
                      return widget.childrens.map((child) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            capitalizeEachWord(
                              "${child["firstName"]} ${child["lastName"]}",
                            ),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black, // field me black
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    onChanged: (value) {
                      setState(() => selectedChild = value);
                    },
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 150,
                      offset: const Offset(0, -5), // 👈 container ke neeche
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Amount
              customLableField(
                lable: "Total Amount*",
                controller: amountController,
                textType: TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 12),
              customLableField(
                lable: "Session Numbers",
                controller: sessionNumbers,
              ),

              const SizedBox(height: 12),

              /// Subject & Start Date
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.appText(
                          "Subject",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          textColor: AppTheme.lableText,
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderCOlor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: Consumer<CostSettingProvider>(
                              builder: (context, provider, _) {
                                return DropdownButton2<SubjectModel>(
                                  isExpanded: true,
                                  hint: AppText.appText(
                                    "Select Subject(s)",
                                    textColor: AppTheme.hintColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  items: provider.subjects.map((subject) {
                                    final isSelected = selectedSubjects
                                        .contains(subject);
                                    return DropdownMenuItem<SubjectModel>(
                                      value: subject,
                                      child: Text(
                                        capitalizeEachWord(subject.name),
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppTheme.appColor
                                              : Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null &&
                                        !selectedSubjects.contains(value)) {
                                      setState(() {
                                        selectedSubjects.add(value);
                                      });
                                    }
                                  },
                                  dropdownStyleData: DropdownStyleData(
                                    maxHeight: 150,
                                    offset: const Offset(0, -5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickDate(context),
                      child: AbsorbPointer(
                        child: customLableField(
                          height: 40.0,
                          lable: "Start Date *",
                          controller: _startDateController,
                          hintText: "MM/YYYY",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /// Start Time & End Time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _pickTime(context, startTimeController, true),
                      child: AbsorbPointer(
                        child: customLableField(
                          lable: "Start Time *",
                          controller: startTimeController,
                          hintText: "HH:MM",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickTime(context, endTimeController, false),
                      child: AbsorbPointer(
                        child: customLableField(
                          lable: "End Time *",
                          controller: endTimeController,
                          hintText: "HH:MM",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppText.appText(
                "Selected Subjects",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: AppTheme.lableText,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: selectedSubjects.map((subject) {
                  return Chip(
                    label: Text(capitalizeEachWord(subject.name)),
                    backgroundColor: AppTheme.appColor,
                    labelStyle: TextStyle(color: Colors.white),
                    deleteIcon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    side: BorderSide.none,
                    onDeleted: () {
                      setState(() {
                        selectedSubjects.remove(subject);
                      });
                    },
                  );
                }).toList(),
              ),
              AppText.appText(
                "Days of Week *",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: AppTheme.lableText,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ["mon", "tue", "wed", "thu", "fri", "sat", "sun"].map(
                  (day) {
                    final isSelected = selectedDays.contains(day);
                    return ChoiceChip(
                      label: Text(day.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(day);
                          } else {
                            selectedDays.remove(day);
                          }
                        });
                      },
                      backgroundColor: AppTheme.white,
                      disabledColor: AppTheme.white,
                      selectedColor: AppTheme.appColor,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lighttxtColor,
                      ),
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 12),

              /// Description
              customLableField(
                lable: "Enter Details of Subjects and Engagement",
                controller: descriptionController,
                hintText: "Enter a description...",
                maxLines: 3,
                height: 100.0,
              ),
              const SizedBox(height: 16),

              /// Send Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Send", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryCOlor, // selected date
              onPrimary: Colors.white, // text color on selected date
              onSurface: Colors.black, // default text color
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Colors.white,
            ), // background color
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      FocusScope.of(context).unfocus();
      setState(() {
        selectedStartDate = date;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  void _pickTime(
    BuildContext context,
    TextEditingController controller,
    bool isStart,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryCOlor, // buttons like OK/Cancel
              onPrimary: Colors.white, // text on OK/Cancel
              onSurface: Colors.black, // unselected text
            ),
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Colors.white, // background of the dial
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white; // selected hour/minute text
                }
                return Colors.black; // unselected hour/minute
              }),
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryCOlor; // selected container
                }
                return Colors.grey.shade200; // unselected container
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white; // AM/PM selected text
                }
                return Colors.black; // AM/PM unselected text
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.primaryCOlor; // AM/PM selected container
                }
                return Colors.grey.shade200; // AM/PM unselected container
              }),
              dialHandColor: AppTheme.primaryCOlor, // hand color
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      FocusScope.of(context).unfocus();
      setState(() {
        if (isStart) {
          selectedStartTime = time;
        } else {
          selectedEndTime = time;
        }
        controller.text = time.format(context);
      });
    }
  }

  void _sendOffer() {
    if (selectedChild == null) {
      _showError("Please Select Child");
      return;
    }
    if (amountController.text.isEmpty) {
      _showError("Please Enter Amount");
      return;
    }
    if (selectedSubjects.isEmpty) {
      _showError("Please Select Subject");
      return;
    }
    if (selectedStartDate == null) {
      _showError("Please select a start date.");
      return;
    }
    if (selectedStartTime == null) {
      _showError("Please select a start time.");
      return;
    }
    if (selectedEndTime == null) {
      _showError("Please select an end time.");
      return;
    }
    if (selectedDays.isEmpty) {
      _showError("Please select days.");
      return;
    }
    if (descriptionController.text.isEmpty) {
      _showError("Please Enter description");
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedStartDate!);
    String formattedStartTime = _formatTimeOfDay(selectedStartTime!);
    String formattedEndTime = _formatTimeOfDay(selectedEndTime!);

    final offerData = {
      "receiverId": widget.recieverId,
      "childName":
          "${selectedChild!["firstName"]} ${selectedChild!["lastName"]}",
      "amountMonthly": amountController.text,
      "sessions": int.tryParse(sessionNumbers.text),
      "subject": selectedSubjects.map((s) => s.name).toList(),
      "startDate": formattedDate,
      "startTime": formattedStartTime,
      "endTime": formattedEndTime,
      "description": descriptionController.text,
      "daysOfWeek": selectedDays,
    };

    // hitAPi(offerData);

    sendMessage(
      "Offer for ${offerData["childName"]}: "
      "${offerData["subject"]}",
      offerData,
    );
  }

  // Helper to convert TimeOfDay → HH:mm
  String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return DateFormat('HH:mm').format(dt);
  }

  void _showError(String message) {
    Fluttertoast.showToast(msg: message);
  }

  void sendMessage(String text, offerData) async {
    final message = {
      "conversationId": widget.conversationId,
      "content": "Offer for ${offerData["childName"]}: ${offerData["subject"]}",
      "type": "OFFER",
      "offer": offerData,
    };

    // Socket par bhej do
    widget.socketService.sendMessage(message);

    final tempId = "temp-${DateTime.now().millisecondsSinceEpoch}";
    final newMessage = ChatMessage(
      id: tempId,
      text: "Offer for ${offerData["childName"]}: ${offerData["subject"]}",
      time: _formatTime(DateTime.now().toIso8601String()),
      isMe: true,
      isPending: true,
      createdAt: DateTime.now(),
      type: "OFFER",
      offer: offerData,
    );
    widget.onMessageCreated!(newMessage);
    Navigator.pop(context);
  }

  String _formatTime(String iso) {
    try {
      final dateTime = DateTime.parse(iso).toLocal();
      int hour = dateTime.hour % 12;
      hour = hour == 0 ? 12 : hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return "$hour:$minute $period";
    } catch (e) {
      return '';
    }
  }

  Future<bool> hitAPi(offerData) async {
    try {
      final params = {
        "conversationId": widget.conversationId,
        "content":
            "Offer for ${offerData["childName"]}: ${offerData["subject"]}",
        "type": "OFFER",
        "offer": offerData,
      };
      final response = await dio.post(
        path: "http://15.235.204.49:5000/chat/messages",
        data: params,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
      return false;
    }
  }
}
