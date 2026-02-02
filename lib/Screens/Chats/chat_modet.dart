class ChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String? fileText;
  final bool isPending;
  final int? audioDuration;
  final String type;
  final DateTime createdAt;
  final String? filePath;
  final Map<String, dynamic>? offer;

  ChatMessage({
    required this.id,
    required this.text,
    this.fileText,
    required this.time,
    required this.createdAt,
    required this.isMe,
    required this.type,
    this.audioDuration,
    this.isPending = false,
    this.filePath,
    this.offer,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    String? time,
    String? fileText,
    bool? isMe,
    bool? isPending,
    int? audioDuration,
    String? type,
    // DateTime? createdAt,
    String? filePath,
    Map<String, dynamic>? offer,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      audioDuration: audioDuration ?? this.audioDuration,
      createdAt: createdAt,
      fileText: fileText ?? this.fileText,
      isPending: isPending ?? this.isPending,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      offer: offer ?? this.offer,
    );
  }
}
