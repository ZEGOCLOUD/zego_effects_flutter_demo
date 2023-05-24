import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:zego_express_engine/zego_express_engine.dart';
import 'zego_config.dart';
import 'zego_utils.dart';
import 'zego_effects_preview_page.dart';

class ExpressInitPage extends StatefulWidget {
  @override
  _ExpressInitPageState createState() => new _ExpressInitPageState();
}

class _ExpressInitPageState extends State<ExpressInitPage> {
  final TextEditingController _appIDEdController = new TextEditingController();
  final TextEditingController _appSignEdController =
      new TextEditingController();

  String _version = "";

  @override
  void initState() {
    super.initState();

    // if (ZegoConfig.instance.appID>0) {
    _appIDEdController.text = ZegoConfig.instance.appID.toString();
    // }

    // if (ZegoConfig.instance.appSign.isNotEmpty) {
    _appSignEdController.text = ZegoConfig.instance.appSign;
    // }

    ZegoExpressEngine.getVersion().then((version) {
      print('[SDK Version] $version');
      setState(() => _version = version);
    });
  }

  void onCreateEngineButtonPressed() {
    String strAppID = _appIDEdController.text.trim();
    String appSign = _appSignEdController.text.trim();

    if (strAppID.isEmpty || appSign.isEmpty) {
      ZegoUtils.showAlert(context, 'AppID or AppSign cannot be empty');
      return;
    }

    int? appID = int.tryParse(strAppID);
    if (appID == null) {
      ZegoUtils.showAlert(context, 'AppID is invalid, should be int');
      return;
    }

    bool isEnablePlatformView = Platform.isIOS;

    // Step1: Create ZegoExpressEngine
    ZegoExpressEngine.createEngine(appID, appSign, false, ZegoScenario.Live,
        enablePlatformView: isEnablePlatformView);

    ZegoConfig.instance.appID = appID;
    ZegoConfig.instance.appSign = appSign;
    ZegoConfig.instance.saveConfig();

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      int screenWidthPx = MediaQuery.of(context).size.width.toInt() *
          MediaQuery.of(context).devicePixelRatio.toInt();
      int screenHeightPx = (MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  56.0)
              .toInt() *
          MediaQuery.of(context).devicePixelRatio.toInt();
      return EffectsPreviewPage(screenWidthPx, screenHeightPx);
    }));
  }

  // ----- Widgets -----

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('InitExpress'),
      ),
      body: SafeArea(
          child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: <Widget>[
              Padding(padding: const EdgeInsets.only(top: 20.0)),
              // userInfoWidget(),
              // Padding(padding: const EdgeInsets.only(top: 10.0)),
              appIDWidget(),
              appSignWidget(),
              Padding(padding: const EdgeInsets.only(top: 10.0)),
              createEngineButton(),
            ],
          ),
        ),
      )),
    );
  }

  Widget userInfoWidget() {
    return Column(children: [
      Row(
        children: <Widget>[
          Text('Native SDK Version: '),
          Expanded(child: Text('$_version')),
        ],
      ),
      Padding(padding: const EdgeInsets.only(top: 10.0)),
      Row(
        children: <Widget>[
          Text('User ID: '),
          Padding(padding: const EdgeInsets.only(left: 10.0)),
          Text(ZegoConfig.instance.userID ?? 'unknown'),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10.0),
      ),
      Row(
        children: <Widget>[
          Text('User Name: '),
          Padding(padding: const EdgeInsets.only(top: 10.0)),
          Text(ZegoConfig.instance.userName ?? 'unknown'),
        ],
      ),
    ]);
  }

  Widget appIDWidget() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.only(top: 10.0)),
        Row(
          children: <Widget>[
            Text('AppID:'),
          ],
        ),
        TextField(
          controller: _appIDEdController,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
            hintText: 'Please enter AppID',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Colors.grey,
            )),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Color(0xff0e88eb),
            )),
          ),
        ),
      ],
    );
  }

  Widget appSignWidget() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.only(top: 10.0)),
        Row(
          children: <Widget>[
            Text('AppSign:'),
          ],
        ),
        TextField(
          controller: _appSignEdController,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
            hintText: 'Please enter AppSign',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Colors.grey,
            )),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Color(0xff0e88eb),
            )),
          ),
        ),
      ],
    );
  }

  Widget selectEnvironmentWidget() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.only(top: 10.0)),
        Row(
          children: <Widget>[
            Text('SDK Environment  '),
            Expanded(
              child: Text(
                '(Please select the environment corresponding to AppID)',
                style: TextStyle(fontSize: 10.0),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: ZegoConfig.instance.isTestEnv,
              onChanged: (value) {
                setState(() {
                  ZegoConfig.instance.isTestEnv = value!;
                  ZegoConfig.instance.saveConfig();
                });
              },
            ),
            Text('Test'),
            Checkbox(
              value: !ZegoConfig.instance.isTestEnv,
              onChanged: (value) {
                setState(() {
                  ZegoConfig.instance.isTestEnv = !(value!);
                  ZegoConfig.instance.saveConfig();
                });
              },
            ),
            Text('Formal'),
          ],
        ),
      ],
    );
  }

  Widget selectRendererWidget() {
    return Column(children: [
      Padding(padding: const EdgeInsets.only(top: 10.0)),
      Row(
        children: <Widget>[
          Text('Rendering options  '),
          Expanded(
            child: Text(
              '(Ways to render video frames)',
              style: TextStyle(fontSize: 10.0),
            ),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Checkbox(
            value: !ZegoConfig.instance.enablePlatformView,
            onChanged: (value) {
              setState(() {
                ZegoConfig.instance.enablePlatformView = !(value!);
                ZegoConfig.instance.saveConfig();
              });
            },
          ),
          Text('TextureRenderer'),
          Checkbox(
            value: ZegoConfig.instance.enablePlatformView,
            onChanged: (value) {
              setState(() {
                ZegoConfig.instance.enablePlatformView = value!;
                ZegoConfig.instance.saveConfig();
              });
            },
          ),
          Text('PlatformView'),
        ],
      ),
    ]);
  }

  Widget createEngineButton() {
    return Container(
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Color(0xff0e88eb),
      ),
      width: 240.0,
      height: 60.0,
      child: CupertinoButton(
        child: Text(
          'Create Engine',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: onCreateEngineButtonPressed,
      ),
    );
  }
}
