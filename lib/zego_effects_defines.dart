import 'dart:math';

import 'package:flutter/material.dart';

/// The scale mode for effect plugin
enum ZegoEffectsScaleMode { AspectFit, AspectFill, ScaleToFill }

/// The mosaic shape type for mosaic effect
enum ZegoEffectsMosaicType { Square, Triangle, Hexagon }

/// Frame format for plugin, effects now only support rgb series
enum ZegoEffectsVideoFrameFormat { Unknown, BGRA32, RGBA32 }

/// The camera position, determins which camera will be selected to capture video data
enum ZegoCameraPosition { Front, Back }

class ZegoEffectsMosaicParam {
  /// Mosaic effect instensity, 0-100
  int intesity;

  /// Mosaic type, also see [ZegoEffectsScaleMode]
  ZegoEffectsMosaicType type;
}

class ZegoEffectsSmoothParam {
  /// Smooth effect intensity, 0-100
  int intensity;
}

class ZegoEffectsMandibleSlimmingParam {
  /// Mandible slimming intensity, 0-100
  int intensity;
}

class ZegoEffectsCheekboneSlimmingParam {
  /// Cheekbone slimming intensity, 0-100
  int intensity;
}

class ZegoEffectsFaceShorteningParam {
  /// Face shortening intensity, 0-100
  int intensity;
}


class ZegoEffectsForeheadShorteningParam {
  /// Forehead shortening intensity, -100~100
  int intensity;
}

class ZegoEffectsNoseLengtheningParam {
  /// Nose lengthening intensity, -100~100
  int intensity;
}

class ZegoEffectsSmallMouthParam {
  /// Small Mouth intensity, -100~100
  int intensity;
}

class ZegoEffectsFilterParam {
  /// filter intensity, 0-100
  int intensity;
}

class ZegoEffectsLongChinParam {
  /// Long Chin intensity, 0-100
  int intensity;
}

class ZegoEffectsNoseNarrowingParam {
  /// Nose Narrowing intensity, 0-100
  int intensity;
}

class ZegoEffectsTeethWhiteningParam {
  /// Teeth WriteningP intensity, 0-100
  int intensity;
}

class ZegoEffectsEyesBrighteningParam {
  /// Eyes Brightening intensity, 0-100
  int intensity;
}

class ZegoEffectsSharpenParam {
  /// Sharpen intensity, 0-100
  int intensity;
}

class ZegoEffectsRosyParam {
  /// Rosy intensity, 0-100
  int intensity;
}

class ZegoEffectsWhitenParam {
  /// Whiten intensity, 0-100
  int intensity;
}

class ZegoEffectsFaceLiftingParam {
  /// Face lifting intensity, 0-100
  int intensity;
}

class ZegoEffectsWrinklesRemovingParam {
  /// Wrinkles removing intensity, 0-100
  int intensity;
}

class ZegoEffectsDarkCirclesRemovingParam {
  /// Darkcircles removing intensity, 0-100
  int intensity;
}

class ZegoEffectsBigEyesParam {
  /// big eyes intensity, 0-100
  int intensity;
}


class ZegoEffectsBlurParam {
  /// Face lifting intensity, 0-100
  int intensity;
}

class ZegoEffectsEyelinerParam {
  /// eyeliner intensity, 0-100
  int intensity;
}

class ZegoEffectsEyeshadowParam {
  /// eyeshadow intensity, 0-100
  int intensity;
}

class ZegoEffectsEyelashesParam {
  /// eyelashed intensity, 0-100
  int intensity;
}

class ZegoEffectsBlusherParam {
  /// blusher intensity, 0-100
  int intensity;
}

class ZegoEffectsLipstickParam {
  /// lipstick intensity, 0-100
  int intensity;
}

class ZegoEffectsColoredcontactsParam {
  /// color contacts intensity, 0-100
  int intensity;
}

class ZegoEffectsMakeupParam {
  /// makeup intensity, 0-100
  int intensity;
}


/// Object for video frame fieldeter.
/// Including video frame format, width and height, etc.
class ZegoEffectsVideoFrameParam {
  ZegoEffectsVideoFrameFormat format;

  int width;
  int height;
}

class ZegoEffectsFaceDetectionResult {
  /// Detection result, higher score means more likely a human face
  double score;

  /// point and size will show you a rectangle which contains the whole human face
  Point point;
  Size size;
}

class ZegoEffectsChromaKeyParam {
  /// update color similarity, higher value means larger scope was replaced
  ///  value range: [0,100], default 67
  double similarity;

  /// update edge smoothness value, higher value means more smooth egde, but also
  /// need more resources/time to render
  /// value range: [0, 100], default 67
  double smoothness;

  /// update opacity
  /// value range: [0,100]，default 100, which means opaque
  int opacity;

  /// update the color, format: BGR, value range: [0, 0xFFFFFF], default: 0x00ff00
  int keyColor;

  /// update edge pixel sampling radius, higher value means more gentle transition
  /// but also need reources/time to handle
  /// usually, there will be some green color remain on the pixels which at the junction of background and foreground
  /// the sdk will take the average of nearby pixels as new pixel values to remove this remains
  /// value range: [0,100], default 1
  int borderSize;
}
