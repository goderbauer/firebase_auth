// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Firebase Auth Demo',
      home: new MyHomePage(title: 'Firebase Auth Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = '';
  final FirebaseAuth auth = FirebaseAuth.instance;

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  Future<Null> _testSignInAnonymously() async {
    FirebaseUser user = await auth.signInAnonymously();
    assert(user != null);
    assert(user == auth.currentUser);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.length == 0);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }
    setMessage('signInAnonymously succeeded: $user');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new MaterialButton(
            child: const Text('Test signInAnonymously'),
            onPressed: _testSignInAnonymously,
          ),
          new Text(_message, style: const TextStyle(color: const Color.fromARGB(255, 0, 155, 0))),
        ],
      ),
    );
  }
}
