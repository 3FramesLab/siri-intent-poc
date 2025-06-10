import 'package:flutter/services.dart';

class SiriIntentService {
  static const MethodChannel _channel = MethodChannel('siri_shortcuts');

  // Check if Siri is available and authorized
  static Future<Map<String, dynamic>> checkSiriStatus() async {
    try {
      final result = await _channel.invokeMethod('checkSiriStatus');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print("Failed to check Siri status: ${e.message}");
      return {'available': false, 'authorized': false, 'error': e.message};
    }
  }

  // Request Siri authorization
  static Future<bool> requestSiriAuthorization() async {
    try {
      final bool authorized =
          await _channel.invokeMethod('requestSiriAuthorization');
      return authorized;
    } on PlatformException catch (e) {
      print("Failed to request Siri authorization: ${e.message}");
      return false;
    }
  }

  // Open Settings app (iOS 8+)
  static Future<bool> openAppSettings() async {
    try {
      final bool opened = await _channel.invokeMethod('openAppSettings');
      return opened;
    } on PlatformException catch (e) {
      print("Failed to open settings: ${e.message}");
      return false;
    }
  }

  // Present Add to Siri sheet (iOS 12+)
  static Future<bool> presentAddToSiriSheet(String shortcutIdentifier) async {
    try {
      final bool result = await _channel.invokeMethod(
          'presentAddToSiriSheet', {'identifier': shortcutIdentifier});
      return result;
    } on PlatformException catch (e) {
      print("Failed to present Add to Siri sheet: ${e.message}");
      return false;
    }
  }

  // Get existing voice shortcuts
  static Future<List<Map<String, dynamic>>> getVoiceShortcuts() async {
    try {
      final result = await _channel.invokeMethod('getVoiceShortcuts');
      return List<Map<String, dynamic>>.from(result);
    } on PlatformException catch (e) {
      print("Failed to get voice shortcuts: ${e.message}");
      return [];
    }
  }

  // Original methods...
  static Future<void> donateShortcuts() async {
    try {
      await _channel.invokeMethod('donateShortcut', {
        'identifier': 'open_comdata',
        'title': 'Open Comdata',
        'subtitle': 'Open Comdata section in the app',
        'route': '/comdata'
      });

      await _channel.invokeMethod('donateShortcut', {
        'identifier': 'open_notifications',
        'title': 'Open Notifications',
        'subtitle': 'Open notifications in the app',
        'route': '/notifications'
      });
    } on PlatformException catch (e) {
      print("Failed to donate shortcuts: ${e.message}");
    }
  }

  static Future<String?> handleIncomingIntent() async {
    try {
      final String? route = await _channel.invokeMethod('getIntentRoute');
      return route;
    } on PlatformException catch (e) {
      print("Failed to handle intent: ${e.message}");
      return null;
    }
  }
}
