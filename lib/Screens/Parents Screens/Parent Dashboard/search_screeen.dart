import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom widgets/app_bar.dart';
import 'package:ustaad/Custom widgets/app_field.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Providers/Parent Side/get_tutors_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Drawer/tutor_drawer.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Dashboard/filter_bottom_sheet.dart';
import 'package:ustaad/Screens/Parents%20Screens/Parent%20Dashboard/tutor_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> selectedFilters = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      await Provider.of<GetTutorsProvider>(context, listen: false)
          .fetchTutors();
    });
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return FilterBottomSheet(
          selectedFilters: selectedFilters,
          onApply: (filters) {
            setState(() => selectedFilters = filters);
            Provider.of<GetTutorsProvider>(context, listen: false)
                .applyFilters(filters);
          },
        );
      },
    );
  }

  void _searchTutorByName(String query) {
    final provider = Provider.of<GetTutorsProvider>(context, listen: false);
    query.isEmpty ? provider.resetFilters() : provider.searchByName(query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GetTutorsProvider>(context);
    final parentProfileProvider = context.watch<ParentProfileProvider>();

    return Scaffold(
      key: scaffoldKey,
      endDrawer: SideMenuDrawer(
        isTutor: false,
        crossOnTap: () => scaffoldKey.currentState?.closeEndDrawer(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset("assets/images/Background.png", fit: BoxFit.fill),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                onMenuTap: () => scaffoldKey.currentState?.openEndDrawer(),
                taskSummary: parentProfileProvider.tasks,
              ),
              _buildSearchBar(),
              if (selectedFilters.isNotEmpty) _buildSelectedFilters(),
              Expanded(
                child: provider.tutors.isEmpty
                    ? const Center(
                        child: Text("No tutor found",
                            style: TextStyle(fontSize: 16)))
                    : _buildTutorList(provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        children: [
          Expanded(
            child: parentHomeSearchField(
              context,
              searchController,
              hintText: "Explore Tutors",
              onChanged: _searchTutorByName,
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _openFilterBottomSheet,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0x0ff4d8e2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderCOlor),
                image: const DecorationImage(
                  scale: 3,
                  image: AssetImage("assets/images/filter.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: selectedFilters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              backgroundColor: AppTheme.white,
              label: Text(filter),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => selectedFilters.remove(filter));
                Provider.of<GetTutorsProvider>(context, listen: false)
                    .applyFilters(selectedFilters);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTutorList(GetTutorsProvider provider) {
    return ListView.builder(
      itemCount: provider.tutors.length,
      itemBuilder: (context, index) {
        final tutor = provider.tutors[index];
        return TutorCard(tutor: tutor);
      },
    );
  }
}
