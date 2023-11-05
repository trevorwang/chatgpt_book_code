import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

@entity
class Session {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String title;
  final String model;
  final SessionType type;

  Session({
    this.id,
    required this.title,
    required this.model,
    this.type = SessionType.chat,
  });

  Session copyWith({int? id, String? title, String? model, SessionType? type}) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      model: model ?? this.model,
      type: type ?? this.type,
    );
  }
}

@JsonEnum()
enum SessionType {
  chat,
  image,
}
