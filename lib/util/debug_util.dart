import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';

class Log {
  static initialize() {
    if (!kReleaseMode) {
      Fimber.plantTree(DebugTree());
    }
  }

  static d(String tag, String message, {dynamic ex}) {
    if (!kReleaseMode) {
      Fimber.log("D", message, tag: tag, ex: ex);
    }
  }

  static w(String tag, String message, {dynamic ex}) {
    if (!kReleaseMode) {
      Fimber.log("W", message, tag: tag, ex: ex);
    }
  }

  static e(String tag, String message, {dynamic ex}) {
    if (!kReleaseMode) {
      Fimber.log("E", message, tag: tag, ex: ex);
    }
  }
}
