import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../injection.dart';
import '../models/message.dart';
import '../models/session.dart';

part 'session_state.g.dart';
part 'session_state.freezed.dart';

@freezed
class SessionState with _$SessionState {
  const factory SessionState({
    @Default(<Session>[]) List<Session> sessions,
    int? active,
    @Default(<Message>[]) List<Message> messages,
  }) = _SessionState;
}

@Riverpod(keepAlive: true)
class SessionWithMessage extends _$SessionWithMessage {
  FutureOr<List<Session>> _featchData() async {
    final sessions = await db.sessionDao.findAllSessions();
    return sessions;
  }

  @override
  FutureOr<SessionState> build() async {
    return SessionState(sessions: await _featchData());
  }

  Future<Session> insertSession(Session session) async {
    var session0 = session;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final id = await db.sessionDao.upsertSession(session);
      session0 = session.copyWith(id: id);
      return SessionState(active: id, sessions: await _featchData());
    });
    return session0;
  }

  Future<void> active(int? sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Future.value(state.value?.copyWith(active: sessionId));
    });
  }
}

@riverpod
Future<int?> activeSession(ActiveSessionRef ref) async {
  return await ref.watch(sessionWithMessageProvider.selectAsync((value) {
    logger.d("activeSession: ${value.active}");
    return value.active;
  }));
}

@riverpod
Future<List<Session>> allSessions(AllSessionsRef ref) async {
  return await ref
      .watch(sessionWithMessageProvider.selectAsync((value) => value.sessions));
}
