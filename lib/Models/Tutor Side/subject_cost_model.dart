class SubjectModel {
  String name;
  String active;
  String cost;

  SubjectModel({required this.name, required this.active, required this.cost});

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      name: json['name'],
      active: json['active'] ?? "false",
      cost: json['cost']?.toString() ?? '0', // Convert to string
    );
  }

 Map<String, dynamic> toJson() {
  return {
    'name': name,
    'active': active,
    'cost': double.tryParse(cost) ?? 0.0, // Convert back to number if needed
  };
}
}
