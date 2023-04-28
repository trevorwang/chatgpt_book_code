import 'package:chatgpt/data/database.dart';
import 'package:chatgpt/services/chatgpt.dart';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

final chatgpt = ChatGPTService();

final logger = Logger(level: kDebugMode ? Level.verbose : Level.info);

const uuid = Uuid();

late AppDatabase db;

initDatabase() async {
  db =
      await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations([
    Migration(1, 2, (database) async {
      await database.execute(
          'CREATE TABLE IF NOT EXISTS `Session` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL)');
      await database
          .execute('ALTER TABLE Message ADD COLUMN session_id INTEGER');
      await database
          .execute("insert into Session (id, title) values (1, 'Default')");
      await database.execute("UPDATE Message SET session_id = 1 WHERE 1=1");
    }),
    Migration(2, 3, (database) async {
      await database.execute('ALTER TABLE Session ADD COLUMN model TEXT');
      await database.execute("UPDATE Session SET model = 'gpt-3.5-turbo'");
    })
  ]).build();
}
