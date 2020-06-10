import 'package:app/pages/auth.dart';
import 'package:app/pages/home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/entry_edit.dart';
import 'package:flutter/material.dart';
import './scoped_models/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  // This widget is the root of your application.
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    // TODO: implement initState
    _model.autoAuth();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });

    final FirebaseMessaging _fcm = FirebaseMessaging();

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: _model,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.yellow,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: {
            '/': (BuildContext context) =>
                !_isAuthenticated ? AuthPage() : HomePage(),
            '/dashboard': (BuildContext context) => HomePage()
          },
        ));
  }
}
