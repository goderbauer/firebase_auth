// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('$FirebaseAuth', () {
    FirebaseAuth auth;

    setUp(() {
      MockPlatformChannel mockChannel = new MockPlatformChannel();

      when(mockChannel.invokeMethod('signInAnonymously')).thenAnswer((Invocation invocation) {
        return <String, dynamic>{
          'isAnonymous': true,
          'isEmailVerified': false,
          'providerData': <Map<String, String>>[],
        };
      });

      auth = new FirebaseAuth.private(mockChannel);
    });

    test('signInAnonymously', () async {
      FirebaseUser user = await auth.signInAnonymously();
      expect(user, isNotNull);
      expect(user, auth.currentUser);
      expect(user.isAnonymous, isTrue);
      expect(user.isEmailVerified, isFalse);
      expect(user.providerData, isEmpty);
    });
  });
}

class MockPlatformChannel extends Mock implements PlatformMethodChannel { }
