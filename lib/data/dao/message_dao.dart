import 'package:floor/floor.dart';

import '../../models/message.dart';

@dao
abstract class MessageDao {
  @Query('SELECT * FROM Message')
  Future<List<Message>> findAllMessages();

  @Query('SELECT * FROM Message WHERE id = :id')
  Future<Message?> findMessageById(String id);

  @insert
  Future<void> insertMessage(Message message);

  @update
  Future<void> updateMessage(Message message);

  @delete
  Future<void> deleteMessage(Message message);
}
