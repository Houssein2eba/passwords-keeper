import 'package:flutter/services.dart';
import 'dart:async';

class ClipboardHelper {
  static Timer? _clearTimer;

  /// Copy text to clipboard and auto-clear after 30 seconds
  static Future<void> copyToClipboard(String text, {String? label}) async {
    // Cancel any existing timer
    _clearTimer?.cancel();

    // Copy to clipboard
    await Clipboard.setData(ClipboardData(text: text));

    // Start 30-second timer to clear clipboard
    _clearTimer = Timer(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
  }

  /// Clear clipboard immediately
  static Future<void> clearClipboard() async {
    _clearTimer?.cancel();
    await Clipboard.setData(const ClipboardData(text: ''));
  }

  /// Cancel auto-clear timer
  static void cancelAutoClear() {
    _clearTimer?.cancel();
  }
}
