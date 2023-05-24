import 'dart:io';

import 'package:flutter/cupertino.dart';
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
  Widget ? _previewViewWidget;
  ZegoCanvas ? _previewCanvas;
  bool isFillter = true;

  @override
  void initState() {
    super.initState();

    // ZegoEffectsPlugin.instance.initEnv(Size(widget.screenWidthPx.toDouble(), widget.screenHeightPx.toDouble()));

    /**
     * initEnv api， need be called in render thread.
     */
    // ZegoEffectsPlugin.instance.initEnv(Size(720, 1280));

    useBasicBeauty();
    useBodyShapeBeauty();
    useFilter();
    useMakeUp();
    useStyleMakeup();


    ZegoEffectsPlugin.instance.startWithCustomCaptureSource(true);
    ZegoCustomVideoCaptureConfig captureConfig = ZegoCustomVideoCaptureConfig(ZegoVideoBufferType.GLTexture2D);
    if (Platform.isIOS) {
      captureConfig =
          ZegoCustomVideoCaptureConfig(ZegoVideoBufferType.CVPixelBuffer);
    } else if (Platform.isAndroid) {
      captureConfig =
          ZegoCustomVideoCaptureConfig(ZegoVideoBufferType.GLTexture2D);
    }
    ZegoExpressEngine.instance
        .enableCustomVideoCapture(true, config: captureConfig);

    ZegoExpressEngine.instance.createCanvasView((viewID) {
      _previewId = viewID;
      startPreview(_previewId);
    }).then((widget) {
      setState(() {
        _previewViewWidget = widget!;
      });
    });

    // if (Platform.isAndroid) {
    //   ZegoExpressEngine.instance
    //       .createTextureRenderer(widget.screenWidthPx, widget.screenHeightPx)
    //       .then((textureId) {
    //     _previewId = textureId;
    //     setState(() {
    //       _previewViewWidget = Texture(textureId: textureId);
    //     });
    //     startPreview(textureId);
    //   });
    // } else if (Platform.isIOS) {
    //   // base on some compatibility reason, iOS cannot use texture way to render the data
    //   setState(() {
    //     _previewViewWidget =
    //         ZegoExpressEngine.instance.createPlatformView((viewID) {
    //       _previewId = viewID;
    //       startPreview(viewID);
    //     });
    //   });
    // }

  }

  void useBasicBeauty() {

    // Enable the skin tone enhancement feature.
    ZegoEffectsPlugin.instance.enableWhiten(true);
    // Set the whitening intensity. The value range is [0, 100], and the default value is 50.
    ZegoEffectsWhitenParam whitenParam = new ZegoEffectsWhitenParam();
    whitenParam.intensity = 100;
    ZegoEffectsPlugin.instance.setWhitenParam(whitenParam);

    // Enable the skin smoothing feature
    ZegoEffectsPlugin.instance.enableSmooth(true);
    // Set the intensity of skin smoothing. The value range is [0, 100], and the default value is 50.
    ZegoEffectsSmoothParam smoothParam = new ZegoEffectsSmoothParam();
    smoothParam.intensity = 100;
    ZegoEffectsPlugin.instance.setSmoothParam(smoothParam);


    // Enable the cheek blusher feature
    ZegoEffectsPlugin.instance.enableRosy(true);
    // Set the blusher intensity. The value range is [0, 100], and the default value is 50.
    ZegoEffectsRosyParam rosyParam = new ZegoEffectsRosyParam();
    rosyParam.intensity = 100;
    ZegoEffectsPlugin.instance.setRosyParam(rosyParam);

    // Enable the image sharpening feature
    ZegoEffectsPlugin.instance.enableSharpen(true);
    // Set the sharpening intensity. The value range is [0, 100], and the default value is 50.
    ZegoEffectsSharpenParam sharpenParam = new ZegoEffectsSharpenParam();
    sharpenParam.intensity = 100;
    ZegoEffectsPlugin.instance.setSharpenParam(sharpenParam);

    // Enable the nasolabial folds removing feature.
    ZegoEffectsPlugin.instance.enableWrinklesRemoving(true);
    // Set the intensity, the value range is [0, 100], and the default value is 50.
    ZegoEffectsWrinklesRemovingParam wrinklesRemovingParam =
        new ZegoEffectsWrinklesRemovingParam();
    wrinklesRemovingParam.intensity = 100;
    ZegoEffectsPlugin.instance.setWrinklesRemovingParam(wrinklesRemovingParam);

    // Enable the dark circles removing feature.
    ZegoEffectsPlugin.instance.enableDarkCirclesRemoving(true);
    // Set the intensity, the value range is [0, 100], and the default value is 50.
    ZegoEffectsDarkCirclesRemovingParam darkCirclesRemovingParam =
        new ZegoEffectsDarkCirclesRemovingParam();
    darkCirclesRemovingParam.intensity = 100;
    ZegoEffectsPlugin.instance.setDarkCirclesRemovingParam(darkCirclesRemovingParam);

  }

  void useBodyShapeBeauty() {

    // Enable the eyes enlarging feature.
    ZegoEffectsPlugin.instance.enableBigEyes(true);
    // Set the extent of eyes enlarging. The value range is [0, 100], and the default value is 50.
    ZegoEffectsBigEyesParam bigEyesParam = new ZegoEffectsBigEyesParam();
    bigEyesParam.intensity = 100;
    ZegoEffectsPlugin.instance.setBigEyesParam(bigEyesParam);

    // Enable the face slimming feature.
    ZegoEffectsPlugin.instance.enableFaceLifting(true);
    // Set the extent of face slimming. The value range is [0, 100], and the default value is 50.
    ZegoEffectsFaceLiftingParam faceLiftingParam = new ZegoEffectsFaceLiftingParam();
    faceLiftingParam.intensity = 40;
    ZegoEffectsPlugin.instance.setFaceLiftingParam(faceLiftingParam);


    // Enable the eyes brightening feature.
    ZegoEffectsPlugin.instance.enableEyesBrightening(true);
    // Set the extent of eyes brightening. The value range is [0, 100], and the default value is 50.
    ZegoEffectsEyesBrighteningParam eyesBrighteningParam = new ZegoEffectsEyesBrighteningParam();
    eyesBrighteningParam.intensity = 100;
    ZegoEffectsPlugin.instance.setEyesBrighteningParam(eyesBrighteningParam);


    // Enable the nose slimming feature.
    ZegoEffectsPlugin.instance.enableNoseNarrowing(true);
    // Set the extent of nose slimming, The value range is [0, 100], and the default value is 50.
    ZegoEffectsNoseNarrowingParam noseNarrowingParam = new ZegoEffectsNoseNarrowingParam();
    noseNarrowingParam.intensity = 100;
    ZegoEffectsPlugin.instance.setNoseNarrowingParam(noseNarrowingParam);



    // Enable the teeth whitening feature.
    ZegoEffectsPlugin.instance.enableTeethWhitening(true);
    // Set extent of teeth whitening. The value range is [0, 100], and the default value is 50.
    ZegoEffectsTeethWhiteningParam teethWhiteningParam = new ZegoEffectsTeethWhiteningParam();
    teethWhiteningParam.intensity = 100;
    ZegoEffectsPlugin.instance.setTeethWhiteningParam(teethWhiteningParam);


    // Enable the chin slimming feature.
    ZegoEffectsPlugin.instance.enableLongChin(true);
    // Set the extent of chin slimming. The value range is [0, 100], and the default value is 50.
    ZegoEffectsLongChinParam longChinParam = new ZegoEffectsLongChinParam();
    longChinParam.intensity = 100;
    ZegoEffectsPlugin.instance.setLongChinParam(longChinParam);


    // Enable the small mouth feature.
    ZegoEffectsPlugin.instance.enableSmallMouth(true);
    // Set the extent of small mouth. The value range is [0, 100], and the default value is 50.
    ZegoEffectsSmallMouthParam smallMouthParam = new ZegoEffectsSmallMouthParam();
    smallMouthParam.intensity = 100;
    ZegoEffectsPlugin.instance.setSmallMouthParam(smallMouthParam);


    // Enable the forehead shortening feature.
    ZegoEffectsPlugin.instance.enableForeheadShortening(true);
    // Set the intensity, the value range is [-100, 100], and the default value is 50.
    ZegoEffectsForeheadShorteningParam foreheadShorteningParam = new ZegoEffectsForeheadShorteningParam();
    foreheadShorteningParam.intensity = 100;
    ZegoEffectsPlugin.instance.setForeheadShorteningParam(foreheadShorteningParam);


    // enable the mandible slimming feature.
    ZegoEffectsPlugin.instance.enableMandibleSlimming(true);
    // Set the intensity, the value range is [0, 100], and the default value is 50.
    ZegoEffectsMandibleSlimmingParam mandibleSlimmingParam = new ZegoEffectsMandibleSlimmingParam();
    mandibleSlimmingParam.intensity = 100;
    ZegoEffectsPlugin.instance.setMandibleSlimmingParam(mandibleSlimmingParam);


    // Enable the cheekbone sliming feature.
    ZegoEffectsPlugin.instance.enableCheekboneSlimming(true);
    // Set the intensity, the value range is [0, 100], and the default value is 50.
    ZegoEffectsCheekboneSlimmingParam cheekboneSlimmingParam = new ZegoEffectsCheekboneSlimmingParam();
    cheekboneSlimmingParam.intensity = 100;
    ZegoEffectsPlugin.instance.setCheekboneSlimmingParam(cheekboneSlimmingParam);


    // Enable the face shortening feature.
    ZegoEffectsPlugin.instance.enableFaceShortening(true);
    // Set the intensity, the value range is [0, 100], and the default value is 50.
    ZegoEffectsFaceShorteningParam faceShorteningParam = new ZegoEffectsFaceShorteningParam();
    faceShorteningParam.intensity = 100;
    ZegoEffectsPlugin.instance.setFaceShorteningParam(faceShorteningParam);


    // Enable the nose lengthening feature.
    ZegoEffectsPlugin.instance.enableNoseLengthening(true);
    // Set the intensity, the value range is [-100, 100], and the default value is 50.
    ZegoEffectsNoseLengtheningParam noseLengtheningParam = new ZegoEffectsNoseLengtheningParam();
    noseLengtheningParam.intensity = 100;
    ZegoEffectsPlugin.instance.setNoseLengtheningParam(noseLengtheningParam);
  }

  void useMakeUp() {

    // enable eyeliner feature and set eyeliner name
    //eyelinerdir_natural、eyelinerdir_pretty、eyelinerdir_scheming、eyelinerdir_temperament、eyelinerdir_wildcat
    ZegoEffectsPlugin.instance.setEyeliner("eyelinerdir_wildcat");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsEyelinerParam eyelinerParam = new ZegoEffectsEyelinerParam();
    eyelinerParam.intensity = 100;
    ZegoEffectsPlugin.instance.setEyelinerParam(eyelinerParam);

    // enable eyeshadow feature and set eyeshadow name
    //eyeshadowdir_mist_pink、eyeshadowdir_mocha_brown、eyeshadowdir_shimmer_pink、eyeshadowdir_vitality_orange、eyeshadowdir_tea_brown
    ZegoEffectsPlugin.instance.setEyeshadow("eyeshadowdir_mist_pink");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsEyeshadowParam eyeshadowParam = new ZegoEffectsEyeshadowParam();
    eyeshadowParam.intensity = 100;
    ZegoEffectsPlugin.instance.setEyeshadowParam(eyeshadowParam);

    // enable eyelashes feature and set eyelashes name
    //eyelashesdir_bushy、eyelashesdir_curl、eyelashesdir_natural、eyelashesdir_slender、eyelashesdir_tender
    ZegoEffectsPlugin.instance.setEyelashes("eyelashesdir_bushy");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsEyelashesParam eyelashesParam = new ZegoEffectsEyelashesParam();
    eyelashesParam.intensity = 100;
    ZegoEffectsPlugin.instance.setEyelashesParam(eyelashesParam);

    // enable blusher feature and set blusher name
    //blusherdir_apricot_pink、blusherdir_milk_orange、blusherdir_peach、blusherdir_slightly_drunk、blusherdir_sweet_orange
    ZegoEffectsPlugin.instance.setBlusher("blusherdir_sweet_orange");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsBlusherParam blusherParam = new ZegoEffectsBlusherParam();
    blusherParam.intensity = 100;
    ZegoEffectsPlugin.instance.setBlusherParam(blusherParam);

    // enable lipstick feature and set lipstick name
    //lipstickdir_bean_paste_pink、lipstickdir_coral、lipstickdir_rust_red、lipstickdir_sweet_orange、lipstickdir_velvet_red
    ZegoEffectsPlugin.instance.setLipstick("lipstickdir_velvet_red");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsLipstickParam lipstickParam = new ZegoEffectsLipstickParam();
    lipstickParam.intensity = 100;
    ZegoEffectsPlugin.instance.setLipstickParam(lipstickParam);

    // enable cosmetic contact lenses feature and set cosmetic contact lenses name
    //coloredcontactsdir_chocolate_brown、coloredcontactsdir_darknight_black、coloredcontactsdir_mystery_brown_green、coloredcontactsdir_polar_lights_brown、coloredcontactsdir_starry_blue
    ZegoEffectsPlugin.instance.setColoredcontacts("coloredcontactsdir_starry_blue");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsColoredcontactsParam coloredcontactsParam = new ZegoEffectsColoredcontactsParam();
    coloredcontactsParam.intensity = 100;
    ZegoEffectsPlugin.instance.setColoredcontactsParam(coloredcontactsParam);

  }

  void useStyleMakeup(){
    // Enable style makeup, which cannot be used in combination with the basic makeup function above.
    //makeupdir_cutie_and_cool、makeupdir_flawless、makeupdir_milky_eyes、makeupdir_pure_and_sexy、makeupdir_vulnerable_and_innocenteyes
    ZegoEffectsPlugin.instance.setMakeup("makeupdir_cutie_and_cool");
    // Set the intensity, the value range is [0, 100]
    ZegoEffectsMakeupParam makeupParam = new ZegoEffectsMakeupParam();
    makeupParam.intensity = 100;
    ZegoEffectsPlugin.instance.setMakeupParam(makeupParam);
  }


  void useFilter(){
    //Autumn、Brighten、Cool、Cozily、Creamy、Film-like、Fresh、Night、Sunset、Sweet
    ZegoEffectsPlugin.instance.setFilter("Brighten");
    ZegoEffectsFilterParam filterParam = ZegoEffectsFilterParam();
    filterParam.intensity = 100;
    ZegoEffectsPlugin.instance.setFilterParam(filterParam);
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
    ZegoExpressEngine.instance.destroyCanvasView(_previewId);
    // ZegoExpressEngine.instance.destroyTextureRenderer(_previewId);
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
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Switch(
                  value: isFillter,
                  onChanged: (val) {
                    setState(() {
                      isFillter = val;
                    });
                    print('isFillter = $isFillter');
                    // ZegoEffectsPlugin.instance.enableWhiten(isFillter);
                    // ZegoEffectsPlugin.instance.enableSmooth(isFillter);
                    // ZegoEffectsPlugin.instance.enableRosy(isFillter);
                    // ZegoEffectsPlugin.instance.enableSharpen(isFillter);
                    // ZegoEffectsPlugin.instance.enableWrinklesRemoving(isFillter);
                    // ZegoEffectsPlugin.instance.enableDarkCirclesRemoving(isFillter);
                    // ZegoEffectsPlugin.instance.enableBigEyes(isFillter);
                    // ZegoEffectsPlugin.instance.enableFaceLifting(isFillter);
                    // ZegoEffectsPlugin.instance.enableEyesBrightening(isFillter);
                    // ZegoEffectsPlugin.instance.enableNoseNarrowing(isFillter);
                    // ZegoEffectsPlugin.instance.enableTeethWhitening(isFillter);
                    // ZegoEffectsPlugin.instance.enableLongChin(isFillter);
                    // ZegoEffectsPlugin.instance.enableSmallMouth(isFillter);
                    // ZegoEffectsPlugin.instance.enableForeheadShortening(isFillter);
                    // ZegoEffectsPlugin.instance.enableMandibleSlimming(isFillter);
                    // ZegoEffectsPlugin.instance.enableCheekboneSlimming(isFillter);
                    // ZegoEffectsPlugin.instance.enableFaceShortening(isFillter);
                    // ZegoEffectsPlugin.instance.enableNoseLengthening(isFillter);
                    // ZegoEffectsPlugin.instance.setEyeliner(null);
                    // ZegoEffectsPlugin.instance.setEyeshadow(null);
                    // ZegoEffectsPlugin.instance.setEyelashes(null);
                    // ZegoEffectsPlugin.instance.setBlusher(null);
                    // ZegoEffectsPlugin.instance.setLipstick(null);
                    // ZegoEffectsPlugin.instance.setColoredcontacts(null);
                    //ZegoEffectsPlugin.instance.setFilter(null);
                    ZegoEffectsPlugin.instance.setMakeup("");
                  })),
        ],
      ),
    );
  }
}
