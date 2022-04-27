import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_effects_plugin_example/zego_express_init_page.dart';

import 'zego_config.dart';
import 'zego_utils.dart';
import 'package:zego_effects_plugin/zego_effects_plugin.dart';

import 'package:permission_handler/permission_handler.dart';

class EffectsInitPage extends StatefulWidget {
  @override
  _EffectsInitPageState createState() => new _EffectsInitPageState();
}

class _EffectsInitPageState extends State<EffectsInitPage> {
  final TextEditingController _licenseEditController =
      new TextEditingController(text: '');

  bool _isCameraPermissionGranted = false;
  bool _isMicrophonePermissionGranted = false;
  bool _isGetLicenseButtonDisabled = false;

  @override
  void initState() {
    super.initState();

    Permission.camera.status.then((value) => setState(
        () => _isCameraPermissionGranted = value == PermissionStatus.granted));
    Permission.microphone.status.then((value) => setState(() =>
        _isMicrophonePermissionGranted = value == PermissionStatus.granted));
    if (!_isCameraPermissionGranted) {
      print(_isCameraPermissionGranted);
      requestCameraPermission();
      print(_isCameraPermissionGranted);
    }
    if (!_isMicrophonePermissionGranted) {
      requestMicrophonePermission();
    }
    ZegoEffectsPlugin.instance.getVersion();
  }

  Future<void> requestCameraPermission() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    setState(() => _isCameraPermissionGranted = cameraStatus.isGranted);
  }

  Future<void> requestMicrophonePermission() async {
    PermissionStatus microphoneStatus = await Permission.microphone.request();
    setState(() => _isMicrophonePermissionGranted = microphoneStatus.isGranted);
  }

  void onCreateEngineButtonPressed() {
    String license = _licenseEditController.text.trim();

    if (license.isEmpty) {
      ZegoUtils.showAlert(context, 'License cannot be empty!');
      return;
    }

    ZegoEffectsPlugin.instance.setResources();
    ZegoEffectsPlugin.instance.create(license);

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return ExpressInitPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('InitEffects'),
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
                licenseWidget(),
                Padding(padding: const EdgeInsets.only(top: 10.0)),
                GetLicenseButton(),
                Padding(padding: const EdgeInsets.only(top: 10.0)),
                createEngineButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget GetLicenseButton() {
    return Container(
      padding: const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: _isGetLicenseButtonDisabled
            ? Color.fromARGB(255, 181, 196, 208)
            : Color(0xff0e88eb),
      ),
      width: 240.0,
      height: 60.0,
      child: CupertinoButton(
        child: Text(
          'Get License',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: _isGetLicenseButtonDisabled
            ? null
            : () {
                setState(() => _isGetLicenseButtonDisabled = true);
                ZegoEffectsPlugin.instance
                    .getAuthInfo(ZegoConfig.instance.appSign)
                    .then((AuthInfo) {
                  print('EffectsInitPage Get AuthInfo');
                  HttpGet("https://aieffects-api.zego.im?Action=DescribeEffectsLicense&AppId=${ZegoConfig.instance.appID}&AuthInfo=${AuthInfo}")
                      .then((value) {
                    print('EffectsInitPage Get license ${value['Code']}');
                    print('EffectsInitPage Get license ${value['Message']}');
                    ZegoUtils.showAlert(context, 'License: $value');
                    if (value['Code'] == 0) {
                      setState(() {
                        _licenseEditController.text = value['Data']['License'];
                        _isGetLicenseButtonDisabled = false;
                      });
                    }
                  });
                });
              },
      ),
    );
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

  Widget licenseWidget() {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.only(top: 10.0)),
        Row(
          children: <Widget>[
            Text('License:'),
          ],
        ),
        TextField(
          controller: _licenseEditController,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 10.0, top: 12.0, bottom: 12.0),
            hintText: 'Please click get license first',
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
}
