import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'zego_effects_defines.dart';

class ZegoEffectsPlugin {
  static const MethodChannel _channel =
      const MethodChannel('zego_effects_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Private constructor
  ZegoEffectsPlugin._internal();

  static final ZegoEffectsPlugin instance = ZegoEffectsPlugin._internal();

  /// get sdk version
  /// @return: version of Zego Effects SDK
  Future<String> getVersion() async {
    return await _channel.invokeMethod('getVersion');
  }

  Future<String> getAuthInfo(String appSign) async {
    return await _channel.invokeMethod('getAuthInfo', {'appSign': appSign});
  }

  /// set custom resources through local path
  /// developer can set multi resources by call this method with a list of path
  /// @note call this method before sdk init
  Future<void> setResources() async {
    return await _channel
        .invokeMethod('setResources');
  }

  /// set custom pendant through local path
  /// developer can set multi pendant by call this method with a list of path
  /// @param path, the pendant local path, sdk with remove pendant when path is null
  /// @note call this method ⚠️after⚠️ sdk init
  Future<void> setPendant(String pendantName) async {
    return await _channel
        .invokeMethod('setPendant', {'pendantName': pendantName});
  }

  /// create Zego Effects SDK with license
  /// developer should get license from Zego first
  /// @return 0, create success, else create failed
  Future<int> create(String license) async {
    return await _channel.invokeMethod('create', {'license': license});
  }

  /// destroy Zego Effects SDK
  Future<void> destroy() async {
    return await _channel.invokeMethod('destroy');
  }

  /// init Zego Effects environment with a resolution you expect
  /// @return 0, init success, else init failed
  Future<int> initEnv(Size resolution) async {
    return await _channel.invokeMethod(
        'initEnv', {'width': resolution.width, 'height': resolution.height});
  }

  /// uninit Zego Effects environment
  Future<void> uninitEnv() async {
    return await _channel.invokeMethod('uninitEnv');
  }

  /// enable zego effects operate camera to capture video
  Future<void> startWithCustomCaptureSource(bool start) async {
    return await _channel
        .invokeMethod('startWithCustomCaptureSource', {'start': start});
  }

  /// stop capture
  Future<void> stopEffects() async {
    return await _channel.invokeMethod('stopEffects');
  }

  /// switch camera
  Future<void> switchCamera(ZegoCameraPosition position) async {
    return await _channel
        .invokeMethod('switchCamera', {'position': position.index});
  }

  /// set camera target framerate
  Future<void> setCameraFrameRate(int fps) async {
    return await _channel.invokeMethod('setCameraFrameRate', {'fps': fps});
  }

  /*Portrait Segmentation*/

  /// enable portrait segmentation
  /// @param enable decide whether enable portrait segmentation function
  Future<void> enablePortraitSegmentation(bool enable) async {
    return await _channel
        .invokeMethod('enablePortraitSegmentation', {'enable': enable});
  }

  /// enable portrait segmentation with mosaic background
  /// @param enable enable decide whether enable portrait segmentation function
  /// with mosaic background
  /// @note enable mosaic background will disable custom background & blur
  /// background
  Future<void> enablePortraitSegmentationBackgroundMosaic(bool enable) async {
    return await _channel.invokeMethod(
        'enablePortraitSegmentationBackgroundMosaic', {'enable': enable});
  }

  /// set param for mosaic background
  /// @param see ZegoEffectsMosaicParam
  Future<void> setPortraitSegmentationBackgroundMosaicParam(
      ZegoEffectsMosaicParam param) async {
    return await _channel.invokeMethod(
        'setPortraitSegmentationBackgroundMosaicParam',
        {'intensity': param.intesity, 'type': param.type.index});
  }

  /// enable portrait segmentation
  /// @note enable portrait segmentation will disable custom background & mosaic
  /// background
  Future<void> enablePortraitSegmentationBackground(bool enable) async {
    return await _channel.invokeMethod(
        'enablePortraitSegmentationBackground', {'enable': enable});
  }

  /// enable portrait segmentation with blur background
  /// @note enable blur background will disable custom background & mosaic
  /// background
  Future<void> enablePortraitSegmentationBackgroundBlur(bool enable) async {
    return await _channel.invokeMethod(
        'enablePortraitSegmentationBackgroundBlur', {'enable': enable});
  }

  /// set blur background parameters for portrait segmentation
  /// @param see ZegoEffectsBlurParam
  Future<void> setPortraitSegmentationBackgroundBlurParam(
      ZegoEffectsBlurParam param) async {
    return await _channel.invokeMethod(
        'setPortraitSegmentationBackgroundBlurParam',
        {'intensity': param.intensity});
  }

  /// set custom background image with path
  /// @param path local image resource path
  /// @param mode image scale mode
  Future<void> setPortraitSegmentationBackgroundPath(
      String imgPath, ZegoEffectsScaleMode mode) async {
    return await _channel.invokeMethod('setPortraitSegmentationBackgroundPath',
        {'path': imgPath, 'mode': mode});
  }

  /// set portrait segmentation foreground postion
  Future<void> setPortraitSegmentationForegroundPosition(
      Point position, Size size) async {
    return await _channel.invokeMethod(
        'setPortraitSegmentationForegroundPosition', {
      'x': position.x,
      'y': position.y,
      'width': size.width,
      'height': size.height
    });
  }

  /// enable face detection function
  Future<void> enableFaceDetection(bool enable) async {
    return await _channel
        .invokeMethod('enableFaceDetection', {'enable': enable});
  }

  /// enable face lifting function
  Future<void> enableFaceLifting(bool enable) async {
    return await _channel.invokeMethod('enableFaceLifting', {'enable': enable});
  }

  /// set face lifting parameters
  /// @param param see also 'ZegoEffectsFaceLiftingParam'
  Future<void> setFaceLiftingParam(ZegoEffectsFaceLiftingParam param) async {
    return await _channel
        .invokeMethod('setFaceLiftingParam', {'intensity': param.intensity});
  }

  /// enable skin whiten function
  Future<void> enableWhiten(bool enable) async {
    return await _channel.invokeMethod('enableWhiten', {'enable': enable});
  }

  /// set skin whiten parameters
  /// @param param see also 'ZegoEffectsWhitenParam'
  Future<void> setWhitenParam(ZegoEffectsWhitenParam param) async {
    return await _channel
        .invokeMethod('setWhitenParam', {'intensity': param.intensity});
  }

  /// enable skin smooth function
  Future<void> enableSmooth(bool enable) async {
    return await _channel.invokeMethod('enableSmooth', {'enable': enable});
  }

  /// set skin smooth funtion parameters
  /// @param param see also 'ZegoEffectsSmoothParam'
  Future<void> setSmoothParam(ZegoEffectsSmoothParam param) async {
    return await _channel
        .invokeMethod('setSmoothParam', {'intensity': param.intensity});
  }


  /// set filter function
  Future<void> setFilter(String filterName) async {
    return await _channel.invokeMethod('setFilter', {'filterName': filterName});
  }

  /// set filter funtion parameters
  /// @param param see also 'ZegoEffectsFilterParam'
  Future<void> setFilterParam(ZegoEffectsFilterParam param) async {
    return await _channel
        .invokeMethod('setFilterParam', {'intensity': param.intensity});
  }

  /// enable small mouth function
  Future<void> enableSmallMouth(bool enable) async {
    return await _channel.invokeMethod('enableSmallMouth', {'enable': enable});
  }

  /// set small mouth funtion parameters
  /// @param param see also 'ZegoEffectsSmallMouthParam'
  Future<void> setSmallMouthParam(ZegoEffectsSmallMouthParam param) async {
    return await _channel
        .invokeMethod('setSmallMouthParam', {'intensity': param.intensity});
  }

  /// enable long chin function
  Future<void> enableLongChin(bool enable) async {
    return await _channel.invokeMethod('enableLongChin', {'enable': enable});
  }

  /// set long chin function parameters
  /// @param param see also 'ZegoEffectsLongChinParam'
  Future<void> setLongChinParam(ZegoEffectsLongChinParam param) async {
    return await _channel
        .invokeMethod('setLongChinParam', {'intensity': param.intensity});
  }

  /// enable nose narrowing function
  Future<void> enableNoseNarrowing(bool enable) async {
    return await _channel
        .invokeMethod('enableNoseNarrowing', {'enable': enable});
  }

  /// set nose narrowing function param
  /// @param param see also 'ZegoEffectsNoseNarrowingParam'
  Future<void> setNoseNarrowingParam(
      ZegoEffectsNoseNarrowingParam param) async {
    return await _channel
        .invokeMethod('setNoseNarrowingParam', {'intensity': param.intensity});
  }

  /// enable teeth whitening function
  Future<void> enableTeethWhitening(bool enable) async {
    return await _channel
        .invokeMethod('enableTeethWhitening', {'enable': enable});
  }

  /// set teeth whitening function parameters
  /// @param param see also 'ZegoEffectsTeethWhiteningParam'
  Future<void> setTeethWhiteningParam(
      ZegoEffectsTeethWhiteningParam param) async {
    return await _channel
        .invokeMethod('setTeethWhiteningParam', {'intensity': param.intensity});
  }

  /// enable eyes brightening function
  Future<void> enableEyesBrightening(bool enable) async {
    return await _channel
        .invokeMethod('enableEyesBrightening', {'enable': enable});
  }

  /// set eyes britening function parameters
  /// @param param see also 'ZegoEffectsEyesBrighteningParam'
  Future<void> setEyesBrighteningParam(
      ZegoEffectsEyesBrighteningParam param) async {
    return await _channel.invokeMethod(
        'setEyesBrighteningParam', {'intensity': param.intensity});
  }

  /// enable sharpen function
  Future<void> enableSharpen(bool enable) async {
    return await _channel.invokeMethod('enableSharpen', {'enable': enable});
  }

  /// set sharpen function parameters
  /// @param param see also ZegoEffectsSharpenParam
  Future<void> setSharpenParam(ZegoEffectsSharpenParam param) async {
    return await _channel
        .invokeMethod('setSharpenParam', {'intensity': param.intensity});
  }

  /// enable rosy function
  Future<void> enableRosy(bool enable) async {
    return await _channel.invokeMethod('enableRosy', {'enable': enable});
  }

  /// set rosy function parameters
  /// @param param see also ZegoEffectsRosyParam
  Future<void> setRosyParam(ZegoEffectsRosyParam param) async {
    return await _channel
        .invokeMethod('setRosyParam', {'intensity': param.intensity});
  }

  /// enable chroma key function
  Future<void> enableChromaKey(bool enable) async {
    return await _channel.invokeMethod('enableChromaKey', {'enable': enable});
  }

  /// enable chroma key background
  /// @note blur background & mosaic background will be diable when enabled
  Future<void> enableChromaKeyBackground(bool enable) async {
    return await _channel
        .invokeMethod('enableChromaKeyBackground', {'enable': enable});
  }

  /// enable chroma key mosaic background
  /// @note custom background & blur background will be disable when enabled
  Future<void> enableChromaKeyBackgroundMosaic(bool enable) async {
    return await _channel
        .invokeMethod('enableChromaKeyBackgroundMosaic', {'enable': enable});
  }

  /// set chroma key mosaic background parameters
  /// @param param see also 'ZegoEffectsMosaicParam'
  Future<void> setChromaKeyBackgroundMosaicParam(
      ZegoEffectsMosaicParam param) async {
    return await _channel.invokeMethod('setChromaKeyBackgroundMosaicParam',
        {'intensity': param.intesity, 'type': param.type.index});
  }

  /// set chroma key parameters
  /// @param param see also 'ZegoEffectsChromaKeyParam'
  Future<void> setChromaKeyParam(ZegoEffectsChromaKeyParam param) async {
    return await _channel.invokeMethod('setChromaKeyParam', {
      'similarity': param.similarity,
      'borderSize': param.borderSize,
      'keyColor': param.keyColor,
      'opacity': param.opacity,
      'smoothness': param.smoothness
    });
  }

  /// enable chroma key blur background function
  /// @note custom background & mosaic background will be disable when enabled
  Future<void> enableChromaKeyBackgroundBlur(bool enable) async {
    return await _channel
        .invokeMethod('enableChromaKeyBackgroundBlur', {'enable': enable});
  }

  /// set chroma key blur background parameters
  Future<void> setChromaKeyBackgroundBlurParam(
      ZegoEffectsBlurParam param) async {
    return await _channel.invokeMethod(
        'setChromaKeyBackgroundBlurParam', {'intensity': param.intensity});
  }

  /// set chroma key custom background path
  Future<void> setChromaKeyBackgroundPath(
      String imagePath, ZegoEffectsScaleMode mode) async {
    return await _channel.invokeMethod(
        'setChromaKeyBackgroundPath', {'imagePath': imagePath, 'mode': mode});
  }

  /// set chroma key foreground position
  Future<void> setChromaKeyForegroundPosition(
      double x, double y, double width, double height) async {
    return await _channel.invokeMethod('setChromaKeyForegroundPosition',
        {'x': x, 'y': y, 'width': width, 'height': height});
  }

  /*Event Callback*/
  static Future<void> registerEventCallback({
    Function(int errorCode, String desc) onEffectsError,
    Function(double score, Point point, Size size) onEffectsFaceDetected,
  }) async {
    await _channel.invokeMethod('registerEventCallback');

    _onEffectsError = onEffectsError;
    _onEffectsFaceDetected = onEffectsFaceDetected;

    _streamSubscription =
        zegoEffectEvent().listen(_eventListener, onError: (error) {
      PlatformException exception = error;
      print(exception);
    });
  }

  static Future<void> destroyEventCallback() async {
    await _channel.invokeMethod('destroyEventCallback');

    _onEffectsError = null;
    _onEffectsFaceDetected = null;

    _streamSubscription.cancel().then((_) {
      _streamSubscription = null;
    }).catchError((error) {
      PlatformException exception = error;
      print(exception);
    });
  }

  /// The callback triggered when method called with errors
  ///
  /// - [errorCode] error code, please refer to error code document: https://doc-en.zego.im/article/9930
  /// - [desc] description for error code
  static void Function(int errorCode, String desc) _onEffectsError;

  /// The callback trrigered after face detected
  ///
  /// - [score] face detection result
  /// - [point] the top left coordinate of the rectangle, which totally contains the face
  /// - [size] the size of the rectangle
  static void Function(double score, Point point, Size size)
      _onEffectsFaceDetected;

  static const EventChannel _zegoEffectsEventChannel =
      const EventChannel('plugins.zego.im/zegoeffects_callback');

  static Stream<dynamic> _receivedEvents =
      _zegoEffectsEventChannel.receiveBroadcastStream();

  static Stream<dynamic> zegoEffectEvent() {
    return _receivedEvents
        .map<Map>((dynamic event) => event)
        .map<dynamic>((Map event) => event['method']);
  }

  static StreamSubscription<dynamic> _streamSubscription;

  static void _eventListener(dynamic data) {
    final Map<dynamic, dynamic> args = data;

    switch (args['name']) {
      case 'onEffectsError':
        if (_onEffectsError != null) {
          int errCode = args['errorCode'];
          String desc = args['desc'];
          _onEffectsError(errCode, desc);
        }
        break;
      case 'onEffectsFaceDetected':
        if (_onEffectsFaceDetected != null) {
          double score = args['score'];
          double x = args['x'];
          double y = args['y'];
          double width = args['width'];
          double height = args['height'];

          _onEffectsFaceDetected(score, Point(x, y), Size(width, height));
        }
        break;
      default:
        break;
    }
  }
}
