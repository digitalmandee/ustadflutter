import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ustaad/Custom widgets/app_bar.dart';
import 'package:ustaad/Custom widgets/app_button.dart';
import 'package:ustaad/Custom widgets/app_text.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/capitalize.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Providers/Contracts/contract_provider.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Providers/Tutor Side/tutor_dashboard_provider.dart';
import 'package:ustaad/config/keys/global.dart';

class ContractScreen extends StatefulWidget {
  final bool isParentSide;
  const ContractScreen({super.key, required this.isParentSide});

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  bool showRunning = true;
  bool showCompleted = false;
  bool showCancelled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<ContractProvider>(context, listen: false)
            .getContracts(context, widget.isParentSide);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tutorProvider = context.watch<TutorDashBoardProvider>();
    final parentProvider = context.watch<ParentProfileProvider>();
    final contractProv = context.watch<ContractProvider>();

    List currentList = showCompleted
        ? contractProv.getCompleted()
        : showCancelled
            ? contractProv.getCancelled()
            : contractProv.getRunning();

    return Scaffold(
      appBar: CustomAppBar(
        taskSummary: globalUserRole == "TUTOR"
            ? tutorProvider.tasks
            : parentProvider.tasks,
        backArrow: true,
        menuIcon: false,
      ),
      body: Column(
        children: [
          _buildToggleTabs(),
          Expanded(
            child: contractProv.isLoading
                ? GifLoader()
                : currentList.isEmpty
                    ? Center(
                        child: AppText.appText(
                          showRunning
                              ? "No Running Contracts Yet"
                              : showCompleted
                                  ? "No Completed Contracts Yet"
                                  : "No Cancelled Contracts Yet",
                          fontSize: 16,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          final data = currentList[index];
                          final childName = data["Offer"]["childName"]
                              .toString()
                              .capitalize();

                          bool showButtons = data["status"] == "ACTIVE";

                          return InkWell(
                            onTap: () {
                              showContractDetailsPopup(data);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Card(
                                elevation: 2,
                                color: AppTheme.white,
                                margin: EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(
                                        width: 5,
                                        color: AppTheme.primaryCOlor,
                                      )),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: AppText.appText(
                                              widget.isParentSide
                                                  ? "Contract with ${capitalizeEachWord(data["tutor"]["firstName"])} for ${capitalizeEachWord(childName)}"
                                                  : "Contract with ${capitalizeEachWord(data["parent"]["firstName"])} for ${capitalizeEachWord(childName)}",
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              maxlines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          widget.isParentSide == true
                                              ? data["tutorReview"] != null
                                                  ? Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 25,
                                                        ),
                                                        SizedBox(width: 5),
                                                        AppText.appText(
                                                            "${data["tutorReview"]["rating"]}",
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w500)
                                                      ],
                                                    )
                                                  : SizedBox.shrink()
                                              : SizedBox.shrink(),
                                          widget.isParentSide == false
                                              ? data["parentReview"] != null
                                                  ? Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 5),
                                                        AppText.appText(
                                                            "${data["parentReview"]["rating"]}",
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w500)
                                                      ],
                                                    )
                                                  : SizedBox.shrink()
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText.appText("Budget:"),
                                          AppText.appText(
                                            "Rs. ${data["Offer"]["amountMonthly"]}",
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AppText.appText("Start Date:"),
                                          AppText.appText(
                                              data["Offer"]["startDate"]),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AppText.appText("Status:"),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: data["status"] ==
                                                        "ACTIVE"
                                                    ? AppTheme.primaryCOlor
                                                    : data["status"] ==
                                                            "CANCELLED"
                                                        ? Colors.red
                                                        : data["status"] ==
                                                                "EXPIRED"
                                                            ? Colors.red
                                                            : data["status"] ==
                                                                    "DISPUTE"
                                                                ? Colors.orange
                                                                : data["status"] ==
                                                                        "COMPLETED"
                                                                    ? AppTheme
                                                                        .appColor
                                                                    : AppTheme
                                                                        .borderCOlor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: AppText.appText(
                                                data["status"],
                                                textColor: AppTheme.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                      if (showButtons)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              AppButton.appButton(
                                                "Terminate",
                                                onTap: () => openTerminatePopup(
                                                    data["id"], context),
                                                height: 35,
                                                width: 90,
                                                backgroundColor: Colors.red,
                                                fontSize: 12,
                                                context: context,
                                              ),
                                              SizedBox(width: 10),
                                              AppButton.appButton(
                                                "Complete",
                                                context: context,
                                                onTap: () => completeContract(
                                                    data["id"], context),
                                                height: 35,
                                                width: 90,
                                                backgroundColor:
                                                    AppTheme.appColor,
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (widget.isParentSide == false &&
                                          data["hasTutorReview"] == false &&
                                          data["status"] ==
                                              "PENDING_COMPLETION")
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: AppButton.appButton(
                                              "Give Review",
                                              context: context, onTap: () {
                                            showRatingPopup(data["id"]);
                                          }),
                                        ),
                                      if (widget.isParentSide == true &&
                                          data["hasParentReview"] == false &&
                                          data["status"] ==
                                              "PENDING_COMPLETION")
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: AppButton.appButton(
                                              "Give Review",
                                              context: context, onTap: () {
                                            showRatingPopup(data["id"]);
                                          }),
                                        ),
                                      // if (widget.isParentSide == false &&
                                      //     data["hasParentReview"] == false &&
                                      //     data["hasTutorReview"] == true &&
                                      //     data["status"] ==
                                      //         "PENDING_COMPLETION")
                                      //   Padding(
                                      //     padding:
                                      //         const EdgeInsets.only(top: 10.0),
                                      //     child: AppButton.appButton(
                                      //         "Waiting for Parent review",
                                      //         context: context,
                                      //         onTap: () {}),
                                      //   ),
                                      // if (widget.isParentSide == false &&
                                      //     data["hasParentReview"] == true &&
                                      //     data["hasTutorReview"] == false &&
                                      //     data["status"] ==
                                      //         "PENDING_COMPLETION")
                                      //   Padding(
                                      //     padding:
                                      //         const EdgeInsets.only(top: 10.0),
                                      //     child: AppButton.appButton(
                                      //         "Waiting for Tutor review",
                                      //         context: context,
                                      //         onTap: () {}),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }

  // ---------------------------
  // TABS UI
  // ---------------------------
  Widget _buildToggleTabs() {
    return Container(
      height: 40,
      margin: EdgeInsets.all(20),
      constraints: BoxConstraints(minWidth: 300, maxWidth: 350),
      decoration: BoxDecoration(
          color: Color(0xffECEEF3), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
        child: Row(
          children: [
            _buildToggleButton("Running", isSelected: showRunning, onTap: () {
              setState(() {
                showRunning = true;
                showCompleted = false;
                showCancelled = false;
              });
            }),
            _buildToggleButton("Completed", isSelected: showCompleted,
                onTap: () {
              setState(() {
                showRunning = false;
                showCompleted = true;
                showCancelled = false;
              });
            }),
            _buildToggleButton("Cancelled", isSelected: showCancelled,
                onTap: () {
              setState(() {
                showRunning = false;
                showCompleted = false;
                showCancelled = true;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text,
      {required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? AppTheme.appColor : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: AppText.appText(
              text,
              fontWeight: FontWeight.w500,
              textColor: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // TERMINATE POPUP
  // ------------------------------------------------------------------
  void openTerminatePopup(String contractId, BuildContext context) {
    final TextEditingController reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppTheme.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔴 Title
                Text(
                  "Terminate Contract",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryCOlor,
                  ),
                ),

                const SizedBox(height: 12),

                /// 📝 Subtitle
                Text(
                  "Please provide a reason for terminating this contract.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                /// ✏️ Reason Field
                ///
                ///
                CustomAppTextField(
                  controller: reasonCtrl,
                  texthint: "Enter reason...",
                  maxLines: 3,
                  height: 100.0,
                ),

                const SizedBox(height: 20),

                /// 🔘 Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryCOlor,
                          side: BorderSide(
                              color: AppTheme.primaryCOlor, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (reasonCtrl.text.trim().isEmpty) return;

                          Navigator.pop(ctx);

                          final prov = Provider.of<ContractProvider>(
                            context,
                            listen: false,
                          );

                          bool ok = await prov.terminateContract(
                            context,
                            contractId,
                            reasonCtrl.text.trim(),
                            widget.isParentSide,
                          );

                          if (ok) {
                            prov.getContracts(context, widget.isParentSide);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryCOlor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // COMPLETE CONTRACT + SHOW RATING
  // ------------------------------------------------------------------
  void completeContract(String contractId, context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GifLoader());

    final prov = Provider.of<ContractProvider>(context, listen: false);
    bool ok =
        await prov.completeContract(context, contractId, widget.isParentSide);

    Navigator.pop(context); // close loader

    if (!ok) return;

    prov.getContracts(context, widget.isParentSide);

    showRatingPopup(contractId);
  }

///////////////////////  Detail Cointract /////////////////

  void showContractDetailsPopup(Map contractData) {
    showDialog(
      context: context,
      builder: (ctx) {
        final childName =
            contractData["Offer"]["childName"].toString().capitalize();
        final name = widget.isParentSide
            ? "${contractData["tutor"]["firstName"]} ${contractData["tutor"]["lastName"]}"
            : "${contractData["parent"]["firstName"]} ${contractData["parent"]["lastName"]}";
        final status = contractData["status"];
        final amount = contractData["Offer"]["amountMonthly"];
        final startDate = contractData["Offer"]["startDate"];
        final endDate = contractData["Offer"]["endDate"];
        final subjects =
            List<String>.from(contractData["Offer"]["subject"] ?? []);
        final days =
            List<String>.from(contractData["Offer"]["daysOfWeek"] ?? []);
        final description = contractData["Offer"]["description"] ?? "";
        final completedSessions = contractData["completedSessions"] ?? 0;
        final totalSessions = contractData["totalSessions"] ?? 0;

        return Dialog(
          backgroundColor: AppTheme.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.appText("Contract Details",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        textColor: AppTheme.primaryCOlor),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close, size: 25),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                _buildSectionContainer(
                  child: Column(
                    children: [
                      _buildInfoRow(
                          widget.isParentSide ? "Tutor Name:" : "Parent Name:",
                          capitalizeEachWord(name)),
                      SizedBox(height: 8),
                      _buildInfoRow(
                          "Child Name:", capitalizeEachWord(childName)),
                    ],
                  ),
                ),
                SizedBox(height: 15),

                _buildSectionContainer(
                  child: Column(
                    children: [
                      _buildInfoRow("Budget:", "Rs. $amount"),
                      SizedBox(height: 8),
                      _buildInfoRow("Start Date:", startDate),
                      if (endDate != null) ...[
                        SizedBox(height: 8),
                        _buildInfoRow("End Date:", endDate),
                      ],
                      SizedBox(height: 8),
                      _buildInfoRow("Sessions:",
                          "$completedSessions / $totalSessions completed"),
                    ],
                  ),
                ),
                SizedBox(height: 15),

                // ===== Subjects & Days =====
                _buildSectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subjects.isNotEmpty)
                        _buildInfoRow("Subjects:",
                            capitalizeEachWord(subjects.join(", "))),
                      if (days.isNotEmpty) ...[
                        SizedBox(height: 8),
                        _buildInfoRow(
                            "Days:", capitalizeEachWord(days.join(", "))),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 15),

                // ===== Description =====
                if (description.isNotEmpty)
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.appText("Description:",
                            fontWeight: FontWeight.w600, fontSize: 16),
                        SizedBox(height: 6),
                        AppText.appText(description, fontSize: 15),
                      ],
                    ),
                  ),
                SizedBox(height: 15),

                // ===== Status =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == "ACTIVE"
                            ? AppTheme.primaryCOlor
                            : status == "CANCELLED"
                                ? Colors.red
                                : status == "EXPIRED"
                                    ? Colors.red
                                    : status == "DISPUTE"
                                        ? Colors.orange
                                        : status == "COMPLETED"
                                            ? AppTheme.appColor
                                            : AppTheme.borderCOlor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AppText.appText(status, textColor: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // ===== Optional Action Buttons =====
                // if (status == "ACTIVE")
                //   Row(
                //     children: [
                //       Expanded(
                //         child: AppButton.appButton(
                //           "Terminate",
                //           context: context,
                //           height: 40,
                //           onTap: () {
                //             Navigator.pop(ctx);
                //             openTerminatePopup(contractData["id"], context);
                //           },
                //           backgroundColor: Colors.red,
                //         ),
                //       ),
                //       SizedBox(width: 10),
                //       Expanded(
                //         child: AppButton.appButton(
                //           "Complete",
                //           context: context,
                //           height: 40,
                //           onTap: () {
                //             Navigator.pop(ctx);
                //             completeContract(contractData["id"], context);
                //           },
                //           backgroundColor: AppTheme.appColor,
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper: Section container with padding & rounded bg
  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  /// Helper: Label & Value row
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // 🔥 IMPORTANT
      children: [
        SizedBox(
          width: 110, // 🔥 fixed width = perfect alignment
          child: AppText.appText(
            label,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: AppText.appText(
            value,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // SIMPLE RATING POPUP (you can replace with your UI)
  void showRatingPopup(String contractId) {
    final TextEditingController reviewController = TextEditingController();
    double rating = 0;

    bool ratingError = false;
    bool reviewError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom, // KEYBOARD SPACE
              ),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),

                /// ⭐ SCROLLABLE CONTENT
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Close Button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade300,
                            ),
                            child: Icon(Icons.close, size: 20),
                          ),
                        ),
                      ),

                      SizedBox(height: 5),

                      /// Title
                      Text(
                        "Rate This Contract",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 15),

                      /// ⭐ Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rating = index + 1.0;
                                ratingError = false;
                              });
                            },
                            child: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: ratingError ? Colors.red : Colors.amber,
                              size: 36,
                            ),
                          );
                        }),
                      ),

                      if (ratingError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            "Please select a rating",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),

                      SizedBox(height: 20),

                      /// Review TextField
                      TextField(
                        controller: reviewController,
                        maxLines: 4,
                        onChanged: (v) {
                          if (v.trim().isNotEmpty) {
                            setState(() => reviewError = false);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Write your review...",
                          filled: true,
                          fillColor: Colors.green.shade50,
                          labelStyle: TextStyle(
                              color: reviewError
                                  ? Colors.red
                                  : AppTheme.lableText),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  reviewError ? Colors.red : AppTheme.appColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  reviewError ? Colors.red : AppTheme.appColor,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                      ),

                      if (reviewError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Please write a review",
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ),

                      SizedBox(height: 20),
                      AppButton.appButton(
                        context: context,
                        onTap: () async {
                          if (rating == 0) {
                            setState(() => ratingError = true);
                            return;
                          }

                          if (reviewController.text.trim().isEmpty) {
                            setState(() => reviewError = true);
                            return;
                          }

                          final prov = Provider.of<ContractProvider>(context,
                              listen: false);

                          // 🚀 SHOW LOADER
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => GifLoader());

                          bool ok = await prov.submitRating(
                            context,
                            widget.isParentSide,
                            contractId,
                            rating,
                            reviewController.text.trim(),
                          );

                          // Navigator.pop(context); // close loader

                          // if (ok) Navigator.pop(ctx);

                          Navigator.pop(context);

                          if (!ok) return;

                          Navigator.pop(ctx);

                          await Future.delayed(
                              const Duration(milliseconds: 200));

                          if (mounted) {
                            AppToast.success(
                              context: context,
                              msg: "Rating submitted successfully",
                            );

                            Provider.of<ContractProvider>(context,
                                    listen: false)
                                .getContracts(context, widget.isParentSide);
                          }
                        },
                        "Submit",
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
