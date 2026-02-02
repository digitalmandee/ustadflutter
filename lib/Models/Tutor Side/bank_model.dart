class BankModel {
  final String name;
  final String logo;

  BankModel({required this.name, required this.logo});

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      name: json['name'],
      logo: json['logo'],
    );
  }
}
