// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

class UserInfo {
  UserInfo(Map<String, dynamic> data)
    : providerId = data['providerId'],
      displayName = data['displayName'],
      photoUrl = data['photoUrl'],
      email = data['email'];

  final String providerId;
  final String displayName;
  final String photoUrl;
  final String email;

  @override
  String toString() {
    return '$runtimeType($providerId $displayName $email)';
  }
}

class FirebaseUser {
  FirebaseUser(Map<String, dynamic> data)
    : isAnonymous = data['isAnonymous'],
      isEmailVerified = data['isEmailVerified'],
      providerData = (data['providerData'] as List<Map<String, dynamic>>)
        .map((Map<String, dynamic> u) => new UserInfo(u)).toList();

  final bool isAnonymous;
  final bool isEmailVerified;
  final List<UserInfo> providerData;

  @override
  String toString() {
    return '$runtimeType(anonymous:$isAnonymous emailVerified:$isEmailVerified $providerData)';
  }
}

class FirebaseAuth {
  final PlatformMethodChannel _channel;

  /// Provides an instance of this class corresponding to the default app.
  ///
  /// TODO(jackson): Support for non-default apps.
  static FirebaseAuth instance = new FirebaseAuth.private(
    const PlatformMethodChannel('firebase_auth'),
  );

  /// We don't want people to extend this class, but implementing its interface,
  /// e.g. in tests, is OK.
  @visibleForTesting
  FirebaseAuth.private(this._channel);

  ///  Asynchronously creates and becomes an anonymous user.
  ///
  ///  If there is already an anonymous user signed in, that user will be
  ///  returned instead. If there is any other existing user signed in, that
  ///  user will be signed out.
  ///
  ///  Will throw a PlatformException if
  ///  FIRAuthErrorCodeOperationNotAllowed - Indicates that anonymous accounts are not enabled. Enable them in the Auth section of the Firebase console.
  ///  See FIRAuthErrors for a list of error codes that are common to all API methods.
  Future<FirebaseUser> signInAnonymously() async {
    Map<String, dynamic> data = await _channel.invokeMethod('signInAnonymously');
    _currentUser = new FirebaseUser(data);
    return _currentUser;
  }

  FirebaseUser _currentUser;

  /// Synchronously gets the cached current user, or null if there is none.
  FirebaseUser get currentUser => _currentUser;
}
