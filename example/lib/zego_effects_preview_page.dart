import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zego_effects_plugin/zego_effects_defines.dart';
import 'package:zego_effects_plugin/zego_effects_plugin.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class EffectsPreviewPage extends StatefulWidget {
  final int screenWidthPx;
  final int screenHeightPx;

  EffectsPreviewPage(this.screenWidthPx, this.screenHeightPx);

  @override
  _EffectsPreviewPageState createState() => new _EffectsPreviewPageState();
}

class _EffectsPreviewPageState extends State<EffectsPreviewPage> {
  int _previewId = -1;
  Widget _previewViewWidget;
  ZegoCanvas _previewCanvas;

  @override
  void initState() {
    super.initState();

    // ZegoEffectsPlugin.instance.initEnv(Size(widget.screenWidthPx.toDouble(), widget.screenHeightPx.toDouble()));
    ZegoEffectsPlugin.instance.initEnv(Size(720, 1280));

    //whiten
    ZegoEffectsPlugin.instance.enableWhiten(true);
    ZegoEffectsWhitenParam param = ZegoEffectsWhitenParam();
    param.intensity = 50;
    ZegoEffectsPlugin.instance.setWhitenParam(param);

    //Sharpen
    ZegoEffectsPlugin.instance.enableSharpen(true);
    ZegoEffectsSharpenParam sharpenParam = ZegoEffectsSharpenParam();
    sharpenParam.intensity = 50;
    ZegoEffectsPlugin.instance.setSharpenParam(sharpenParam);

    //Rosy
    ZegoEffectsPlugin.instance.enableRosy(true);
    ZegoEffectsRosyParam rosyParam = ZegoEffectsRosyParam();
    rosyParam.intensity = 50;
    ZegoEffectsPlugin.instance.setRosyParam(rosyParam);

    //Filter effects
    //Autumn、Brighten、Cool、Cozily、Creamy、Film-like、Fresh、Night、Sunset、Sweet
    ZegoEffectsPlugin.instance.setFilter("Autumn");
    ZegoEffectsFilterParam filterParam = ZegoEffectsFilterParam();
    filterParam.intensity = 50;
    ZegoEffectsPlugin.instance.setFilterParam(filterParam);

    ZegoEffectsPlugin.instance.startWithCustomCaptureSource(true);
    ZegoCustomVideoCaptureConfig captureConfig;
    if (Platform.isIOS) {
      captureConfig =
          ZegoCustomVideoCaptureConfig(ZegoVideoBufferType.CVPixelBuffer);
    } else if (Platform.isAndroid) {
      captureConfig =
          ZegoCustomVideoCaptureConfig(ZegoVideoBufferType.GLTexture2D);
    }
    ZegoExpressEngine.instance
        .enableCustomVideoCapture(true, config: captureConfig);

    if (Platform.isAndroid) {
      ZegoExpressEngine.instance
          .createTextureRenderer(widget.screenWidthPx, widget.screenHeightPx)
          .then((textureId) {
        _previewId = textureId;
        setState(() {
          _previewViewWidget = Texture(textureId: textureId);
        });
        startPreview(textureId);
      });
    } else if (Platform.isIOS) {
      // base on some compatibility reason, iOS cannot use texture way to render the data
      setState(() {
        _previewViewWidget =
            ZegoExpressEngine.instance.createPlatformView((viewID) {
          _previewId = viewID;
          startPreview(viewID);
        });
      });
    }
  }

  void startPreview(int viewID) {
    _previewCanvas = ZegoCanvas.view(viewID);

    ZegoExpressEngine.instance.startPreview(canvas: _previewCanvas);
  }

  void startPublish(int streamID) {
    ZegoUser user = ZegoUser("zef-u-001", "zef-u-001");
    ZegoExpressEngine.instance.loginRoom("zef-001", user).then((value) {
      ZegoExpressEngine.instance.startPublishingStream("zef-s-001");
    });
  }

  @override
  void dispose() {
    super.dispose();

    ZegoEffectsPlugin.instance.stopEffects();
    ZegoEffectsPlugin.instance.uninitEnv();
    ZegoEffectsPlugin.instance.destroy();

    ZegoExpressEngine.instance.stopPreview();
    ZegoExpressEngine.instance.destroyTextureRenderer(_previewId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Effects-Preview'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: _previewViewWidget,
          )
        ],
      ),
    );
  }
}
