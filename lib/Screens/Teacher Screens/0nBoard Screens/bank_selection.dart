import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ustaad/Custom%20widgets/app_button.dart';
import 'package:ustaad/Custom%20widgets/app_field.dart';
import 'package:ustaad/Custom%20widgets/app_text.dart';
import 'package:ustaad/Helpers/app_theme.dart';
import 'package:ustaad/Helpers/utils.dart';
import 'package:ustaad/Models/Tutor%20Side/bank_model.dart';
import 'package:ustaad/Screens/Teacher%20Screens/0nBoard%20Screens/data_model.dart';

class BankSelectionScreen extends StatefulWidget {
  final VoidCallback onTap;
  final TutorOnboardData onboardData;
  final VoidCallback onBackTap;

  const BankSelectionScreen(
      {super.key,
      required this.onTap,
      required this.onboardData,
      required this.onBackTap});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  List<BankModel> banks = [];
  BankModel? selectedBank;
  final TextEditingController accountController = TextEditingController();

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
                        color: Colors.black),
                    children: [
                      TextSpan(
                          text: "We'll ",
                          style: TextStyle(
                              fontSize: 42, fontWeight: FontWeight.w400)),
                      TextSpan(
                          text: "Take Care ",
                          style: TextStyle(
                              color: AppTheme.appColor,
                              fontSize: 42,
                              fontWeight: FontWeight.w600)),
                      TextSpan(
                        text: "of Your Valuable ",
                        style: TextStyle(
                            fontSize: 42, fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                          text: "Earnings",
                          style: TextStyle(
                              color: AppTheme.appColor,
                              fontSize: 42,
                              fontWeight: FontWeight.w600)),
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
                AppText.appText("Select Your Bank",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppTheme.black),
                SizedBox(height: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<BankModel>(
                    isExpanded: true,
                    hint: AppText.appText("Select Bank",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        textColor: AppTheme.lableText),
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
                        border: Border.all(color: AppTheme.borderCOlor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                AppText.appText("Account Number",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppTheme.lableText),
                SizedBox(
                  height: 10,
                ),
                CustomAppTextField(
                  controller: accountController,
                  texthint: "Account or Iban Number",
                  txtType: TextInputType.number,
                ),
                SizedBox(
                  height: 40,
                ),
                AppButton.appButton("Proceed", context: context, onTap: () {
                  if (selectedBank == null || selectedBank!.name.isEmpty) {
                    AppToast.error(context: context,msg: "Please select a bank");
                    return;
                  }

                  final cleanedAccount =
                      accountController.text.replaceAll(' ', '').trim();

                  if (cleanedAccount.isEmpty) {
                    AppToast.error(context: context,msg: "Please enter account number");
                    return;
                  }

                  widget.onboardData.selectedBank = selectedBank!.name;
                  widget.onboardData.accountNumber = cleanedAccount;

                  widget.onTap();
                },
                    textColor: AppTheme.white,
                    border: false,
                    height: 52,
                    backgroundColor: AppTheme.primaryCOlor),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
