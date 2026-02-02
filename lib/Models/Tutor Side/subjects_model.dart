class SubjectsModel {
  final String name;
  final String logo;

  SubjectsModel({required this.logo, required this.name});

  factory SubjectsModel.fromJson(Map<String, dynamic> json) {
    return SubjectsModel(
      name: json['name'],
      logo: json['image'],
    );
  }
}
