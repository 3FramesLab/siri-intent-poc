import 'package:flutter/services.dart';

class SpeechService {
  static const MethodChannel _channel = MethodChannel('driven_speech_to_text');

  static Future<String?> startListening({String locale = 'en-US'}) async {
    return await _channel.invokeMethod('startListening', {
      'locale': locale,
    });
  }

  static Future<void> stopListening() async {
    await _channel.invokeMethod('stopListening');
  }
}
