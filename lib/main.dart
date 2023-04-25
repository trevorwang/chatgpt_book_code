import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'data/database.dart';
import 'injection.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    })
  ]).build();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: router,
    );
  }
}
