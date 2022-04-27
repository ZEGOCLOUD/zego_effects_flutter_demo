import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'zego_config.dart';
import 'zego_effects_init_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZegoEffectsExample',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    ZegoConfig.instance.init();
  }

  void onEnterEffectsPageBtnPressed() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return EffectsInitPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ZegoEffectsExample'),
      ),
      body: SafeArea(
        child: Center(
          child: CupertinoButton(
            color: Color(0xff0e88eb),
            child: Text('Effects Camera'),
            onPressed: onEnterEffectsPageBtnPressed,
          ),
        ),
      ),
    );
  }
}
