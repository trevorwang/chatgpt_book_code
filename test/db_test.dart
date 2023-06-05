import 'package:chatgpt/data/dao/session_dao.dart';
import 'package:chatgpt/data/database.dart';
import 'package:chatgpt/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openai_api/openai_api.dart';

void main() {
  late AppDatabase db;
  late SessionDao sessionDao;

  setUp(() async {
    db = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    sessionDao = db.sessionDao;
  });
  test("create session", () async {
    final session = Session(title: "hello", model: Model.gpt3_5Turbo.value);
    final r = await sessionDao.upsertSession(session);
    expect(1, r);
    final s = await sessionDao.findSessionById(r);
    expect(
      s,
      isA<Session>()
          .having((p0) => p0.id, "id 不正确", equals(1))
          .having((p0) => p0.title, "tiitle 不正确", session.title),
    );
  });

  test("delete session", () async {
    final session = Session(title: "hello", model: Model.gpt3_5Turbo.value);
    final r = await sessionDao.upsertSession(session);
    expect(1, r);
    await sessionDao.deleteSession(session.copyWith(id: r));

    final s = await sessionDao.findSessionById(r);
    expect(s, isNull);
  });
}
