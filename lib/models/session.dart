import 'package:floor/floor.dart';

@entity
class Session {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String title;
  final String model; //TODO custom enum value support issue

  Session({this.id, required this.title, this.model = "gpt-3.5-turbo"});

  Session copyWith({
    int? id,
    String? title,
    String? model,
  }) {
    return Session(
      id: id ?? this.id,
      title: title ?? this.title,
      model: model ?? this.model,
    );
  }
}
