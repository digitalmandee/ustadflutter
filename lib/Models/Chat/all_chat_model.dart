class AllChatsModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int? unreadCount;

  final String type;

  final String msgType;

  final String? lastMsg;

  final String? duration;

  final String status;
  final String participantId;
  final bool isPrivate;
  final int maxParticipants;
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMsgTime;

  AllChatsModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.unreadCount,
    required this.type,
    required this.msgType,
    this.lastMsg,
    this.duration,
    required this.status,
    required this.participantId,
    required this.isPrivate,
    required this.maxParticipants,
    required this.participantCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastMsgTime,
  });

  factory AllChatsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? lastMessage = json['lastMessage'];
    final String? messageType = lastMessage?['type'];

    return AllChatsModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['participantImage'],
      unreadCount: json['unreadCount'],
      type: json['type'],
      status: json['status'],
      isPrivate: json['isPrivate'],
      maxParticipants: json['maxParticipants'] ?? 0,
      participantCount: json['participantCount'],
      participantId: json['participantId'],
      msgType: messageType ?? "",
      lastMsg: lastMessage?['content'],
      duration: messageType == 'AUDIO'
          ? lastMessage?['metadata']?['duration']?.toString()
          : null,
      lastMsgTime: lastMessage?['createdAt'] != null
          ? DateTime.tryParse(lastMessage!['createdAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
