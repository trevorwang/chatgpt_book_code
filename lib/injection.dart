import 'package:chatgpt/services/chatgpt.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final chatgpt = ChatGPTService();

final logger = Logger(level: kDebugMode ? Level.verbose : Level.info);
