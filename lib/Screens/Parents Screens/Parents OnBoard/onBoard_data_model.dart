// import 'dart:io';

class ParentOnboardData {
  String? selectedBank;
  String? accountNumber;

  // File? idFrontFile;
  // File? idBackFile;

  ParentOnboardData({
    this.selectedBank,
    this.accountNumber,
    // this.idFrontFile,
    // this.idBackFile,
  });

  Map<String, dynamic> toJson() {
    return {
      "bank_name": selectedBank,
      "account_number": accountNumber,
    };
  }
}
