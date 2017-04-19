import 'dart:async';

import 'package:flutter/services.dart';

class FirebaseAuth {
  static const PlatformMethodChannel _channel =
      const PlatformMethodChannel('firebase_auth');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
