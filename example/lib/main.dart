import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wannatalkcore/wannatalkcore.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _userLoggedIn = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    Wannatalkcore.setMethodCallHandler(onReceivedEvent:(WTEventResponse eventResponse) {

    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    bool loggedIn = await Wannatalkcore.isUserLoggedIn;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    WannatalkConfig.enableAutoTickets(true);
    WannatalkConfig.showGuideButton(false);

    setState(() {
      _userLoggedIn = loggedIn;
    });
  }

  void login(){
    Wannatalkcore.login(onCompletion: (WTResult result) {
      if (result.success) {
        setState(() {
          _userLoggedIn = true;
        });
      }

    });
  }

  void silentLogin(String userIdentifier, Map userInfo) {

    Wannatalkcore.silentLogin(userIdentifier, userInfo, onCompletion: (WTResult result) {
      if (result.success) {
        setState(() {
          _userLoggedIn = true;
        });
      }
    });
  }


  void logout() {
    Wannatalkcore.logout(onCompletion: (WTResult result) {
      if (result.success) {
        setState(() {
          _userLoggedIn = false;
        });
      }
    });
  }


  void presentOrgProfile(bool autoOpenChat) {
    Wannatalkcore.presentOrganizationProfile(autoOpenChat, onCompletion: (WTResult result){
      if (result.success) {

      }
    });
  }

  void presentChats() {
    Wannatalkcore.presentChats(onCompletion: (WTResult result) {
      if (result.success) {

      }
    });
  }

  void presentUsers() {
    Wannatalkcore.presentUsers(onCompletion: (WTResult result) {
      if (result.success) {

      }
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
//      _counter++;
    });

//    Map userInfo = {"displayname":""};
////    new HashMap<String, String>();
////
////    (displayname: "SG1988");
//
//    silentLogin("+919000220455", userInfo);

  }

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
//              new RaisedButton(
//                onPressed: () {},
//                child: new Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  mainAxisSize: MainAxisSize.min,
//                  children: <Widget>[
//                    new Text('Running on: $_platformVersion\n'),
//                    new Text('Button with text and icon!'),
//                    new Icon(Icons.lightbulb_outline),
//                  ],
//                ),
//              ),

              if (!_userLoggedIn) new RaisedButton(
                onPressed: () {
                  login();
                },
                child: new Text('Login'),
              ),
              if (!_userLoggedIn) new RaisedButton(
                onPressed: () {
                  silentLogin("+919000220455", {"displayname":"SG222"});
                },
                child: new Text('Silent Login'),
              ),
              if (_userLoggedIn) new RaisedButton(
                onPressed: () {logout();},
                child: new Text('Logout'),
              ),
              if (_userLoggedIn) new RaisedButton(
                onPressed: () {presentOrgProfile(true);},
                child: new Text('Org Profile'),
              ),
              if (_userLoggedIn) new RaisedButton(
                onPressed: () {presentChats();},
                child: new Text('Chats'),
              ),
              if (_userLoggedIn) new RaisedButton(
                onPressed: () {presentUsers();},
                child: new Text('Users'),
              )
            ],
          ),
        ),
//        body: Center(
//          child: Text('Running on: $_platformVersion\n'),
//        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

}