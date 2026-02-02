class Experience {
  final String id;
  final String company;
  final String startDate;
  final String endDate;
  final String description;
  final String designation;

  Experience({
    required this.id,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.designation,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id']?.toString() ?? '', // adjust if API uses another key
      company: json['company'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      description: json['description'] ?? '',
      designation: json['designation'] ?? '',
    );
  }
}
