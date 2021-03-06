// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

/// Represents user data returned from an identity provider.
class UserInfo {
  final Map<String, dynamic> _data;
  UserInfo._(this._data);

  /// The provider identifier.
  String get providerId => _data['providerId'];

  /// The provider’s user ID for the user.
  String get uid => _data['uid'];

  /// The name of the user.
  String get displayName => _data['displayName'];

  /// The URL of the user’s profile photo.
  String get photoUrl => _data['photoUrl'];

  /// The user’s email address.
  String get email => _data['email'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}

/// Represents a user.
class FirebaseUser extends UserInfo {
  final Map<String, dynamic> _data;
  final List<UserInfo> providerData;
  FirebaseUser._(this._data)
    : providerData = (_data['providerData'] as List<Map<String, dynamic>>)
        .map((Map<String, dynamic> info) => new UserInfo._(info)).toList(),
      super._(_data);

  // Returns true if the user is anonymous; that is, the user account was
  // created with signInAnonymously() and has not been linked to another
  // account.
  bool get isAnonymous => _data['isAnonymous'];

  /// Returns true if the user's email is verified.
  bool get isEmailVerified => _data['isEmailVerified'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}

class FirebaseAuth {
  final MethodChannel _channel;

  /// Provides an instance of this class corresponding to the default app.
  ///
  /// TODO(jackson): Support for non-default apps.
  static FirebaseAuth instance = new FirebaseAuth.private(
    const MethodChannel('firebase_auth'),
  );

  /// We don't want people to extend this class, but implementing its interface,
  /// e.g. in tests, is OK.
  @visibleForTesting
  FirebaseAuth.private(this._channel);

  /// Asynchronously creates and becomes an anonymous user.
  ///
  /// If there is already an anonymous user signed in, that user will be
  /// returned instead. If there is any other existing user signed in, that
  /// user will be signed out.
  ///
  /// Will throw a PlatformException if
  /// FIRAuthErrorCodeOperationNotAllowed - Indicates that anonymous accounts are not enabled. Enable them in the Auth section of the Firebase console.
  /// See FIRAuthErrors for a list of error codes that are common to all API methods.
  Future<FirebaseUser> signInAnonymously() async {
    Map<String, dynamic> data = await _channel.invokeMethod('signInAnonymously');
    _currentUser = new FirebaseUser._(data);
    return _currentUser;
  }

  Future<FirebaseUser> signInWithGoogle({
    @required String idToken,
    @required String accessToken,
  }) async {
    assert(idToken != null);
    assert(accessToken != null);
    Map<String, dynamic> data = await _channel.invokeMethod(
      'signInWithGoogle',
      <String, String>{
        'idToken': idToken,
        'accessToken': accessToken,
      },
    );
    _currentUser = new FirebaseUser._(data);
    return _currentUser;
  }

  FirebaseUser _currentUser;

  /// Synchronously gets the cached current user, or `null` if there is none.
  FirebaseUser get currentUser => _currentUser;
}
