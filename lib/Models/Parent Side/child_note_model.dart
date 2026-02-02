class ChildNote {
  final String id;
  final String headline;
  final String description;
  final String? createdAt;
  final String? tutorName;

  ChildNote({
    required this.id,
    required this.headline,
    required this.description,
    required this.tutorName,
    this.createdAt,
  });

  factory ChildNote.fromJson(Map<String, dynamic> json) {
    return ChildNote(
      id: json['id'],
      headline: json['headline'],
      description: json['description'],
      createdAt: json['createdAt'],
      tutorName: "${json["User"]["firstName"]} ${json["User"]["lastName"]}",
    );
  }
}
