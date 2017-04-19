package com.yourcompany.firebase_auth;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.FlutterMethodChannel.MethodCallHandler;
import io.flutter.plugin.common.FlutterMethodChannel.Response;
import io.flutter.plugin.common.MethodCall;

/**
 * FirebaseAuthPlugin
 */
public class FirebaseAuthPlugin implements MethodCallHandler {
  private FlutterActivity activity;

  public static FirebaseAuthPlugin register(FlutterActivity activity) {
    return new FirebaseAuthPlugin(activity);
  }

  private FirebaseAuthPlugin(FlutterActivity activity) {
    this.activity = activity;
    new FlutterMethodChannel(activity.getFlutterView(), "firebase_auth").setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Response response) {
    if (call.method.equals("getPlatformVersion")) {
      response.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      response.notImplemented();
    }
  }
}
