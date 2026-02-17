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
import 'package:ustaad/Models/Tutor%20Side/bank_model.dart';
import 'package:ustaad/Providers/Parent%20Side/parent_profile_provider.dart';
import 'package:ustaad/Screens/Authentication/widgets/auth_widgets.dart';
import 'package:ustaad/Custom%20widgets/app_bar.dart';
import 'package:ustaad/config/dio/app_logger.dart';
import 'package:ustaad/config/dio/dio.dart';
import 'package:ustaad/config/keys/urls.dart';

class ParentRefundingScreen extends StatefulWidget {
  const ParentRefundingScreen({super.key});

  @override
  State<ParentRefundingScreen> createState() => _ParentRefundingScreenState();
}

class _ParentRefundingScreenState extends State<ParentRefundingScreen> {
  bool showUpcoming = true;
  AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    logger.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<ParentProfileProvider>(context, listen: false);
      provider.getPaymentRequests(context);
      final provider1 =
          Provider.of<ParentProfileProvider>(context, listen: false);
      provider1.getParentProfile(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentProfileProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        backArrow: true,
        menuIcon: false,
        taskSummary: provider.tasks,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: const Color(0xffECEEF3),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTab("Refunds", true),
                      _buildTab("Transferred", false),
                    ],
                  ),
                ),
              ),
            ),
            showUpcoming
                ? Expanded(child: _buildBalanceSection(context, provider))
                : Expanded(
                    child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _buildTransferredList(
                        context: context,
                        history: provider.parentTranferredHistory),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isLeft) {
    final isSelected = showUpcoming == isLeft;
    return InkWell(
      onTap: () {
        setState(() {
          showUpcoming = isLeft;
        });
      },
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.appColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: AppText.appText(
              title,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: isSelected ? AppTheme.white : AppTheme.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection(
      BuildContext context, ParentProfileProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          AppText.appText("Your Refunding Ballance",
              fontSize: 16, fontWeight: FontWeight.w400),
          const SizedBox(height: 8),
          AppText.appText("Rs. ${provider.profileBalance}",
              fontSize: 44, fontWeight: FontWeight.w600),
          const SizedBox(height: 8),
          AppText.appText("You can Withdraw",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: const Color(0xff8A8A8A)),
          const SizedBox(height: 30),
          AppButton.appButton("Withdraw", context: context, onTap: () {
            final balance = double.tryParse(provider.profileBalance) ?? 0;

            if (balance > 0) {
              showModalBottomSheet(
                backgroundColor: AppTheme.white,
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const BankSheet(),
              );
            } else {
              AppToast.error(
                context: context,
                msg: "Your balance is 0. You cannot withdraw.",
              );
            }
          },
              backgroundColor: AppTheme.primaryCOlor,
              border: false,
              fontSize: 16,
              fontWeight: FontWeight.w500),
          const SizedBox(height: 20),
          AppText.appText("Recent Transactions",
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textColor: const Color(0xff8A8A8A)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.parentTranferredHistory.length >= 3
                ? 3
                : provider.parentTranferredHistory.length,
            itemBuilder: (context, index) {
              final data = provider.parentTranferredHistory[index];
              return _transferItem(context, data);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransferredList({context, history}) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: history.length,
      itemBuilder: (context, index) {
        var data = history[index];
        return _transferItem(context, data);
      },
    );
  }
}

Widget _transferItem(BuildContext context, dynamic data) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppTheme.primaryCOlor, width: 4),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.appText("Request for Withdraw"),
                const SizedBox(height: 5),
                AppText.appText(
                  data["status"],
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            AppText.appText(
              "Rs. ${data["amount"]}",
              textColor: AppTheme.appColor,
            ),
          ],
        ),
      ),
    ),
  );
}

// ======================= BANK SHEET ============================

class BankSheet extends StatefulWidget {
  const BankSheet({super.key});

  @override
  State<BankSheet> createState() => _BankSheetState();
}

class _BankSheetState extends State<BankSheet> {
  bool isLoading = false;
  final TextEditingController amountController = TextEditingController();

  late AppDio dio;
  AppLogger logger = AppLogger();

  @override
  void initState() {
    super.initState();
    dio = AppDio(context);
    logger.init();
  }

  Future<void> withdrawAmount() async {
    if (amountController.text.isEmpty) {
      AppToast.error(context: context, msg: "Please enter an amount");
      return;
    }

    setState(() => isLoading = true);

    Map<String, dynamic> params = {
      "amount": amountController.text,
    };

    try {
      final response =
          await dio.post(path: AppUrls.parentWithdrawAmount, data: params);
      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final provider =
            Provider.of<ParentProfileProvider>(context, listen: false);
        await provider.getParentProfile(context);
        final provider1 =
            Provider.of<ParentProfileProvider>(context, listen: false);
        provider1.getPaymentRequests(context);
        setState(() => isLoading = false);

        Future.delayed(const Duration(milliseconds: 400), () {
          if (context.mounted) Navigator.pop(context);
          if (mounted) {
            AppToast.success(
              context: context,
              msg: "Withdraw request Submitted successfully",
            );
          }
        });
      } else {
        AppToast.error(
            context: context, msg: "${data["errors"][0]["message"]}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      AppToast.error(context: context, msg: "Something went wrong: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentProfileProvider>();
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==== Header ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ),
                AppText.appText("Withdraw Your Amount",
                    fontSize: 18, fontWeight: FontWeight.w600),
                const SizedBox(height: 10),
                AppText.appText(
                  "Don't panic. You can also customise this permission by going to Settings.",
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w400,
                  textColor: const Color(0xff4D5874),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ==== Content ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customLableField(
                    height: 52.0,
                    lable: "Amount*",
                    hintText: "Rs. 1000",
                    controller: amountController,
                    textType: TextInputType.number),
                const SizedBox(height: 12),
                AppText.appText("Your Bank Account",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppTheme.lableText),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffE7E7E7)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance,
                          size: 30, color: AppTheme.primaryCOlor),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.appText(
                            provider.bankName,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AppText.appText(
                            provider.accountNumber,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppButton.appButton(
                      "Add New Bank",
                      context: context,
                      width: ScreenSize(context).width * 0.42,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: AppTheme.white,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20))),
                          builder: (context) => const AddBankBottomSheet(),
                        );
                      },
                      backgroundColor: const Color(0xffECEEF3),
                      border: false,
                      textColor: AppTheme.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    AppButton.appButton(
                      isLoading ? "Processing..." : "Withdraw",
                      context: context,
                      width: ScreenSize(context).width * 0.42,
                      onTap: isLoading ? null : () => withdrawAmount(),
                      backgroundColor: AppTheme.primaryCOlor,
                      border: false,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddBankBottomSheet extends StatefulWidget {
  const AddBankBottomSheet({super.key});

  @override
  State<AddBankBottomSheet> createState() => _AddBankBottomSheetState();
}

class _AddBankBottomSheetState extends State<AddBankBottomSheet> {
  List<BankModel> banks = [];
  BankModel? selectedBank;
  final TextEditingController accountController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadBanks();
  }

  Future<void> loadBanks() async {
    final String response = await rootBundle.loadString('assets/banks.json');
    final List data = json.decode(response);
    setState(() {
      banks = data.map((e) => BankModel.fromJson(e)).toList();
      if (banks.isNotEmpty) selectedBank = banks.first;
    });
  }

  Future<void> saveBank() async {
    if (selectedBank == null) {
      AppToast.error(context: context, msg: "Please select a bank");
      return;
    }
    final accountNumber = accountController.text.trim();
    final cleanedAccountNumber = accountNumber.replaceAll(' ', '');
    if (accountNumber.isEmpty) {
      AppToast.error(context: context, msg: "Please enter account number");
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(accountNumber)) {
      AppToast.error(
          context: context, msg: "Account number must contain only digits");
      return;
    }

    setState(() => isLoading = true);
    final provider = Provider.of<ParentProfileProvider>(context, listen: false);

    bool success = await provider.updateBankDetails(
        context, selectedBank!.name, cleanedAccountNumber);

    setState(() => isLoading = false);

    if (success && context.mounted) {
      Navigator.pop(context);
      if (mounted) {
        AppToast.success(context: context, msg: "Bank Updated Succesfully");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ),
            AppText.appText("Add New Bank",
                fontSize: 18, fontWeight: FontWeight.w600),
            const SizedBox(height: 20),
            AppText.appText("Select Your Bank",
                fontSize: 16, fontWeight: FontWeight.w500),
            const SizedBox(height: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton2<BankModel>(
                isExpanded: true,
                value: selectedBank,

                onChanged: (value) {
                  setState(() {
                    selectedBank = value;
                  });
                },

                items: banks.map((bank) {
                  return DropdownMenuItem<BankModel>(
                    value: bank,
                    child: Row(
                      children: [
                        Image.asset(bank.logo, height: 25),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText.appText(
                            bank.name,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                buttonStyleData: ButtonStyleData(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderCOlor),
                  ),
                ),

                // 🔽 Dropdown (Opened)
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 150,
                  offset: const Offset(0, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppText.appText("Account Number",
                fontSize: 16, fontWeight: FontWeight.w500),
            const SizedBox(height: 8),
            CustomAppTextField(
              controller: accountController,
              texthint: "Account or IBAN Number",
              txtType: TextInputType.number,
            ),
            const SizedBox(height: 30),
            AppButton.appButton(
              isLoading ? "Processing..." : "Proceed",
              context: context,
              onTap: isLoading ? null : saveBank,
              backgroundColor: AppTheme.primaryCOlor,
              border: false,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }
}
