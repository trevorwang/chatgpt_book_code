import 'package:chatgpt/services/chatgpt.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

final chatgpt = ChatGPTService();

final logger = Logger(level: kDebugMode ? Level.verbose : Level.info);

const uuid = Uuid();
