import 'package:chatgpt/data/database.dart';
import 'package:chatgpt/services/chatgpt.dart';
import 'package:chatgpt/services/record.dart';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

final chatgpt = ChatGPTService();

final logger = Logger(level: kDebugMode ? Level.verbose : Level.info);

const uuid = Uuid();

late AppDatabase db;

Future<void> initDatabase() async {
  db =
      await $FloorAppDatabase.databaseBuilder('app_database.db').addMigrations([
    Migration(1, 2, (database) async {
      await database.execute('ALTER TABLE Session ADD COLUMN model TEXT');
      await database
          .execute("""UPDATE "Session" SET model = 'gpt-3.5-turbo'""");
    })
  ]).build();
}

final record = RecordingSeorvice();
