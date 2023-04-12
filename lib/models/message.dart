import 'package:floor/floor.dart';

@entity
class Message {
  @primaryKey
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  @ForeignKey(
    childColumns: ["session_id"],
    parentColumns: ['id'],
    entity: Message,
  )
  final int sessionId;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.sessionId,
  });

  @override
  String toString() {
    return "Message(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp, sessionId: $sessionId)";
  }

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode =>
      id.hashCode ^ content.hashCode ^ isUser.hashCode ^ timestamp.hashCode;
}

extension MessageExtension on Message {
  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    int? sessionId,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
