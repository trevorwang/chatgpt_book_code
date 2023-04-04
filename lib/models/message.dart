class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Message(
      {required this.content, required this.isUser, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'content': content,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        content: json['content'],
        isUser: json['isUser'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
