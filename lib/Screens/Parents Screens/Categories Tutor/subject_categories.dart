import 'package:flutter/material.dart';
import 'package:flutterustad/Custom widgets/app_bar.dart';
import 'package:flutterustad/Custom widgets/app_text.dart';
import 'package:flutterustad/Custom%20widgets/app_field.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Models/Tutor Side/subjects_model.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Categories%20Tutor/category_tutor.dart';

class SubjectCategoriesScreen extends StatefulWidget {
  final List<SubjectsModel> data;
  const SubjectCategoriesScreen({super.key, required this.data});

  @override
  State<SubjectCategoriesScreen> createState() =>
      _SubjectCategoriesScreenState();
}

class _SubjectCategoriesScreenState extends State<SubjectCategoriesScreen> {
  TextEditingController searchController = TextEditingController();
  List<SubjectsModel> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = widget.data; // initially show all subjects
  }

  void _filterSubjects(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredList = widget.data; // 🔥 show all subjects again
      });
    } else {
      setState(() {
        filteredList = widget.data
            .where(
              (subject) =>
                  subject.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar1(title: "Subject Categories"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10),
        child: Column(
          children: [
            // 🔍 Search Bar
            const SizedBox(height: 12),

            parentHomeSearchField(
              context,
              searchController,
              hintText: "Search Subject",
              onChanged: _filterSubjects,
            ),

            Expanded(
              child: GridView.builder(
                itemCount: filteredList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final subject = filteredList[index];
                  return InkWell(
                    onTap: () => push(
                      context,
                      TutorCategoriesScreen(categoryName: subject.name),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryCOlor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(subject.logo),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: AppText.appText(
                              subject.name,
                              textAlign: TextAlign.center,
                              maxlines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              textColor: AppTheme.grey,
                            ),
                          ),
                          check(index, filteredList.length),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  check(i, l) {
    if (i == l - 1 || i == l - 2) {
      return const SizedBox(height: 10);
    } else {
      return const SizedBox.shrink();
    }
  }
}
