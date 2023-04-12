import 'package:chatgpt/models/message.dart';
import 'package:floor/floor.dart';

@entity
class Session {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String title;

  Session({
    this.id,
    required this.title,
  });

  Session copyWith({
    int? id,
    String? title,
    List<Message>? messages,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
