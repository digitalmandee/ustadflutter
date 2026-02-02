import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom widgets/app_text.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Parent Side/child_note_model.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Providers/Tutor%20Side/tutor_dashboard_provider.dart';
import 'package:ustaad/config/keys/global.dart';

const Color lightGreenColor = Color(0xffC2FEB3);

class ChildNoteDetailScreen extends StatelessWidget {
  final ChildNote note;

  const ChildNoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final tutorProvider = context.watch<TutorDashBoardProvider>();
    final parentProvider = context.watch<ParentProfileProvider>();
    DateTime? createdDate;
    if (note.createdAt != null && note.createdAt!.isNotEmpty) {
      createdDate = DateTime.tryParse(note.createdAt!);
    }

    return Scaffold(
      appBar: CustomAppBar(
        taskSummary: globalUserRole == "TUTOR"
            ? tutorProvider.tasks
            : parentProvider.tasks,
        backArrow: true,
        menuIcon: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.appColor,
                  width: 2.0,
                )),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Heading ----------

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.appText(
                        "By ${note.tutorName!}",
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        textColor: Color.fromARGB(255, 93, 92, 92),
                      ),
                      Image.asset(
                        "assets/images/notes.png",
                        height: 15,
                        color: Color.fromARGB(255, 88, 86, 86),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AppText.appText(
                          capitalizeEachWord(note.headline),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          textColor: Colors.black87,
                        ),
                      ),
                      AppText.appText(
                        createdDate != null
                            ? DateFormat('yyyy-MM-dd').format(createdDate)
                            : "N/A",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        textColor: Colors.black87,
                      ),
                    ],
                  ),

                  SizedBox(height: 5),

                  // ---------- Full Description ----------
                  Expanded(
                    child: Container(
                      width: ScreenSize(context).width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppTheme.white,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.appText(
                                note.description,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                textColor: Colors.black87,
                                maxlines: 1000, // no limit
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
