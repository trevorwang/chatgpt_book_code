import 'dart:async';

import 'package:chatgpt/data/dao/session_dao.dart';
import 'package:chatgpt/models/session.dart';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/message.dart';
import 'converter/datetime_converter.dart';
import 'dao/message_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Message, Session])
@TypeConverters([DateTimeConverter])
abstract class AppDatabase extends FloorDatabase {
  MessageDao get messageDao;
  SessionDao get sessionDao;
}
