// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.firebase_auth;

import android.support.annotation.NonNull;

import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserInfo;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.FlutterMethodChannel.MethodCallHandler;
import io.flutter.plugin.common.FlutterMethodChannel.Response;
import io.flutter.plugin.common.MethodCall;

import java.util.Map;

/**
 * Flutter plugin for Firebase Auth.
 */
public class FirebaseAuthPlugin implements MethodCallHandler {
  private final FlutterActivity activity;
  private final FirebaseAuth firebaseAuth;

  private static final String ERROR_REASON_EXCEPTION = "exception";

  public static FirebaseAuthPlugin register(FlutterActivity activity) {
    return new FirebaseAuthPlugin(activity);
  }

  private FirebaseAuthPlugin(FlutterActivity activity) {
    this.activity = activity;
    FirebaseApp.initializeApp(activity);
    this.firebaseAuth = FirebaseAuth.getInstance();
    new FlutterMethodChannel(activity.getFlutterView(), "firebase_auth").setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Response response) {
    switch (call.method) {
      case "signInAnonymously":
        handleSignInAnonymously(call, response);
        break;
      default:
        response.notImplemented();
        break;
    }
  }

  private void handleSignInAnonymously(MethodCall call, final Response response) {
    firebaseAuth
      .signInAnonymously()
      .addOnCompleteListener(activity, new SignInCompleteListener(response));
  }

  private class SignInCompleteListener implements OnCompleteListener<AuthResult> {
    private final Response response;

    SignInCompleteListener(Response response) {
      this.response = response;
    }

    @Override
    public void onComplete(@NonNull Task<AuthResult> task) {
      if (!task.isSuccessful()) {
        Exception e = task.getException();
        response.error(ERROR_REASON_EXCEPTION, e.getMessage(), null);
      } else {
        AuthResult result = task.getResult();
        FirebaseUser user = result.getUser();
        if (user != null) {
          ImmutableList.Builder<ImmutableMap<String, String>> providerDataBuilder =
              ImmutableList.<ImmutableMap<String, String>>builder();
          for (UserInfo userInfo : user.getProviderData()) {
            ImmutableMap.Builder<String, String> userInfoBuilder =
                ImmutableMap.<String, String>builder()
                    .put("providerId", userInfo.getProviderId());
            if (userInfo.getDisplayName() != null) {
              userInfoBuilder.put("displayName", userInfo.getDisplayName());
            }
            if (userInfo.getPhotoUrl() != null) {
              userInfoBuilder.put("photoUrl", userInfo.getPhotoUrl().toString());
            }
            if (userInfo.getEmail() != null) {
              userInfoBuilder.put("email", userInfo.getEmail());
            }
            providerDataBuilder.add(userInfoBuilder.build());
          }
          ImmutableMap<String, Object> userMap =
              ImmutableMap.<String, Object>builder()
                  .put("isAnonymous", user.isAnonymous())
                  .put("isEmailVerified", user.isEmailVerified())
                  .put("providerData", providerDataBuilder.build())
                  .build();
          response.success(userMap);
        } else {
          response.success(null);
        }
      }
    }
  }
}
