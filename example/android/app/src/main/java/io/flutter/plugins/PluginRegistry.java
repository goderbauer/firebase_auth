package io.flutter.plugins;

import io.flutter.app.FlutterActivity;

import com.yourcompany.firebase_auth.FirebaseAuthPlugin;

/**
 * Generated file. Do not edit.
 */

public class PluginRegistry {
    public FirebaseAuthPlugin firebase_auth;

    public void registerAll(FlutterActivity activity) {
        firebase_auth = FirebaseAuthPlugin.register(activity);
    }
}
