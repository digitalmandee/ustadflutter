import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Parent%20Side/child_detail_model.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Profile/child_notes.dart';

class ChildTeacherNotes extends StatefulWidget {
  final bool isTutorSide;

  const ChildTeacherNotes({super.key, this.isTutorSide = false});

  @override
  State<ChildTeacherNotes> createState() => _ChildTeacherNotesState();
}

class _ChildTeacherNotesState extends State<ChildTeacherNotes> {
  @override
  void initState() {
    super.initState();

    // First time load notes
    Future.microtask(() {
      final provider =
          Provider.of<ParentProfileProvider>(context, listen: false);
      provider.fetchChildNotes(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParentProfileProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- CHILD DROPDOWN ----------
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: ScreenSize(context).width - 40,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xffD4D8E2)),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: child == provider.selectedChild
                              ? AppTheme.appColor
                              : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) {
                    return provider.children.map((subject) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AppText.appText(
                          "${subject.firstName} ${subject.lastname}",
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
          ],
        ),
        SizedBox(height: 20),

        // ---------- LOADING ----------
        if (provider.notesLoader) GifLoader(),

        // ---------- EMPTY ----------
        if (!provider.notesLoader && provider.childNotes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Center(
              child: AppText.appText("No Notes Found", fontSize: 16),
            ),
          ),

        // ---------- NOTES LIST ----------
        for (var note in provider.childNotes)
          InkWell(
            onTap: () {
              push(context, ChildNoteDetailScreen(note: note));
            },
            child: Card(
              margin: EdgeInsets.only(bottom: 15),
              child: Container(
                width: ScreenSize(context).width,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: Color(0xffC2FEB3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.appText(
                            "By ${note.tutorName!}",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            textColor: Color(0xff212121),
                          ),
                          Image.asset(
                            "assets/images/notes.png",
                            height: 15,
                            color: Color.fromARGB(255, 88, 86, 86),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AppText.appText(
                              capitalizeEachWord(note.headline),
                              fontSize: 16,
                              maxlines: 1,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                              textColor: Color.fromARGB(255, 88, 86, 86),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          AppText.appText(
                            "${note.createdAt?.substring(0, 10)}",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            textColor: Color(0xff212121),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      AppText.appText(
                        note.description,
                        maxlines: 1,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        textColor: Color(0xff616161),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
