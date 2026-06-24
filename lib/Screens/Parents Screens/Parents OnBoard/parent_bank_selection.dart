import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterustad/Custom%20widgets/app_button.dart';
import 'package:flutterustad/Custom%20widgets/app_field.dart';
import 'package:flutterustad/Custom%20widgets/app_text.dart';
import 'package:flutterustad/Helpers/app_theme.dart';
import 'package:flutterustad/Helpers/static_data.dart';
import 'package:flutterustad/Helpers/utils.dart';
import 'package:flutterustad/Models/Tutor%20Side/bank_model.dart';
import 'package:flutterustad/Screens/Parents%20Screens/Parents%20OnBoard/onBoard_data_model.dart';

class ParentBankSelectionScreen extends StatefulWidget {
  final VoidCallback onTap;
  final ParentOnboardData parentOnboardData;
  final VoidCallback onBackTap;

  const ParentBankSelectionScreen({
    super.key,
    required this.onTap,
    required this.onBackTap,
    required this.parentOnboardData,
  });

  @override
  State<ParentBankSelectionScreen> createState() =>
      _ParentBankSelectionScreenState();
}

class _ParentBankSelectionScreenState extends State<ParentBankSelectionScreen> {
  List<BankModel> banks = [];
  BankModel? selectedBank;
  final TextEditingController accountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBanks();

    /// 🔥 AUTO SET DEFAULT BANK & ACCOUNT WHEN ACTIVE
    if (Staticdata.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          // Set account number
          accountController.text = "11111";

          // Set bank to "Jazzcash" if it exists in the list after loading
          if (banks.isNotEmpty) {
            final jazzcashBank = banks.firstWhere(
              (bank) => bank.name.toLowerCase() == "jazzcash",
              orElse: () => banks.first,
            );
            selectedBank = jazzcashBank;
          }
        });
      });
    }
  }

  Future<void> loadBanks() async {
    final String response = await rootBundle.loadString('assets/banks.json');
    final List data = json.decode(response);

    setState(() {
      banks = data.map((e) => BankModel.fromJson(e)).toList();
      if (banks.isNotEmpty) selectedBank = banks.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Staticdata.isActive
                    ? Container(
                        height: 500,
                        child: Center(child: Text('tap to next')),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {
                                widget.onBackTap.call();
                              },
                              child: Image.asset(
                                "assets/images/arrowBack.png",
                                height: 28,
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "We'll ",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: "Take Care ",
                                  style: TextStyle(
                                    color: AppTheme.appColor,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: "of Your Valuable ",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: "Spendings",
                                  style: TextStyle(
                                    color: AppTheme.appColor,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          AppText.appText(
                            "Add Your Payout Method",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          SizedBox(height: 30),
                          AppText.appText(
                            "Select Your Bank",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            textColor: AppTheme.black,
                          ),
                          SizedBox(height: 8),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<BankModel>(
                              isExpanded: true,
                              hint: AppText.appText(
                                "Select Bank",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                textColor: AppTheme.lableText,
                              ),
                              value: selectedBank,
                              onChanged: (value) {
                                setState(() {
                                  selectedBank = value;
                                });
                              },
                              items: banks.map((bank) {
                                return DropdownMenuItem(
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
                              dropdownStyleData: DropdownStyleData(
                                direction: DropdownDirection.left,
                                maxHeight: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                              ),
                              buttonStyleData: ButtonStyleData(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppTheme.borderCOlor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          AppText.appText(
                            "Account Number",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            textColor: AppTheme.lableText,
                          ),
                          SizedBox(height: 10),
                          CustomAppTextField(
                            controller: accountController,
                            texthint: "Account or IBAN Number",
                            txtType: TextInputType.number,
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                AppButton.appButton(
                  "Proceed",
                  context: context,
                  onTap: () {
                    if (selectedBank == null || selectedBank!.name.isEmpty) {
                      AppToast.error(
                        context: context,
                        msg: "Please select a Bank",
                      );
                      return;
                    }

                    final cleanedAccount = accountController.text
                        .replaceAll(' ', '')
                        .trim();

                    if (cleanedAccount.isEmpty) {
                      AppToast.error(
                        context: context,
                        msg: "Please enter Account Number",
                      );
                      return;
                    }

                    widget.parentOnboardData.selectedBank = selectedBank!.name;
                    widget.parentOnboardData.accountNumber = cleanedAccount;

                    widget.onTap();
                  },
                  textColor: AppTheme.white,
                  border: false,
                  height: 52,
                  backgroundColor: AppTheme.primaryCOlor,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
