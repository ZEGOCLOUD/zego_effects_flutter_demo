//
//  ZegoEffectsDefines.h
//  ZegoEffects
//
//  Copyright © 2021 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/// 马赛克类型
///
typedef NS_ENUM(NSUInteger, ZegoEffectsMosaicType) {

    /// 正方形
    ZegoEffectsMosaicTypeSquare = 0,

    /// 三角形
    ZegoEffectsMosaicTypeTriangle = 1,

    /// 六边形
    ZegoEffectsMosaicTypeHexagon = 2

};

/// 视频帧数据格式
///
typedef NS_ENUM(NSUInteger, ZegoEffectsVideoFrameFormat) {

    /// 未知格式，将取平台默认值
    ZegoEffectsVideoFrameFormatUnknown = 0,

    /// BGRA32 格式
    ZegoEffectsVideoFrameFormatBGRA32 = 1,

    /// RGBA32 格式
    ZegoEffectsVideoFrameFormatRGBA32 = 2,

    /// I420 格式
    ZegoEffectsVideoFrameFormatI420 = 3,

    /// yv12 格式
    ZegoEffectsVideoFrameFormatYv12 = 4,

    /// nv21 格式
    ZegoEffectsVideoFrameFormatNv21 = 5,

    /// nv12 格式
    ZegoEffectsVideoFrameFormatNv12 = 6

};

/// 显示的比例模式
///
typedef NS_ENUM(NSUInteger, ZegoEffectsScaleMode) {

    /// 详情描述：等比缩放，可能有黑边
    ZegoEffectsScaleModeAspectFit = 0,

    /// 详情描述：等比缩放填充整个 View，可能有部分被裁减
    ZegoEffectsScaleModeAspectFill = 1,

    /// 详情描述：填充整个 View，图像可能被拉伸
    ZegoEffectsScaleModeScaleToFill = 2

};

/// 引擎配置类
///
/// 注意事项：必须在创建 effects 之前调用。
///
@interface ZegoEffectsAdvancedConfig : NSObject

/// 详情描述：其他特殊功能开关，如果不设置，默认不使用特殊功能。 使用前请联系ZEGO技术支持。
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *advancedConfig;

@end

/// 亮眼参数
///
/// 详情描述：开发者可以通过该类设置亮眼强度等参数
///
@interface ZegoEffectsEyesBrighteningParam : NSObject

/// 详情描述：亮眼强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

@interface ZegoEffectsFaceLiftingParam : NSObject

/// 详情信息：瘦脸强度，范围 [-100~100]
@property (nonatomic, assign) int intensity;

@end

/// 去除法令纹参数
///
@interface ZegoEffectsWrinklesRemovingParam : NSObject

/// 详情信息：去除法令纹强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 去除黑眼圈参数
///
@interface ZegoEffectsDarkCirclesRemovingParam : NSObject

/// 详情信息：去除黑眼圈强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 缩小额头高度参数
///
@interface ZegoEffectsForeheadShorteningParam : NSObject

/// 详情信息：缩小额头高度强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 瘦下颌骨参数
///
@interface ZegoEffectsMandibleSlimmingParam : NSObject

/// 详情信息: 瘦下颌骨强度，范围[0~100]
@property (nonatomic, assign) int intensity;

@end

/// 瘦颧骨参数

@interface ZegoEffectsCheekboneSlimmingParam : NSObject

/// 详情信息: 瘦颧骨强度，范围[0~100]
@property (nonatomic, assign) int intensity;

@end

///  小脸参数

@interface ZegoEffectsFaceShorteningParam : NSObject

/// 详情信息: 小脸强度，范围[0~100]
@property (nonatomic, assign) int intensity;

@end

///  长鼻参数

@interface ZegoEffectsNoseLengtheningParam : NSObject

/// 详情信息: 长鼻强度，范围[0~100]
@property (nonatomic, assign) int intensity;

@end

/// 滤镜颜色风格参数
///
@interface ZegoEffectsFilterParam : NSObject

/// 详情信息：开发者可通过该属性调整滤镜强度
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整人脸下巴
///
@interface ZegoEffectsLongChinParam : NSObject

/// 详情描述：长下巴强度，范围 [-100~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整眼线
///
@interface ZegoEffectsEyelinerParam : NSObject

/// 详情描述：眼线强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整眼睫毛
///
@interface ZegoEffectsEyelashesParam : NSObject

/// 详情描述：眼睫毛强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整眼影
///
@interface ZegoEffectsEyeshadowParam : NSObject

/// 详情描述：眼影强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整腮红
///
@interface ZegoEffectsBlusherParam : NSObject

/// 详情描述：腮红强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整口红
///
@interface ZegoEffectsLipstickParam : NSObject

/// 详情描述：口红强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整美瞳
///
@interface ZegoEffectsColoredcontactsParam : NSObject

/// 详情描述：美瞳强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整风格妆
///
@interface ZegoEffectsMakeupParam : NSObject

/// 详情描述：风格妆强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 马赛克参数
///
@interface ZegoEffectsMosaicParam : NSObject

/// 马赛克强度 [0~100]
@property (nonatomic, assign) int intensity;

/// 设置马赛克类型，默认为三角形
@property (nonatomic, assign) ZegoEffectsMosaicType type;

@end

/// 开发者可以通过该类调整瘦鼻参数
///
@interface ZegoEffectsNoseNarrowingParam : NSObject

/// 详情描述：瘦鼻强度，范围 [0-100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整红润参数
///
@interface ZegoEffectsRosyParam : NSObject

/// 详情信息：红润强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整锐化参数
///
@interface ZegoEffectsSharpenParam : NSObject

/// 详情信息：锐化强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整瘦嘴参数
///
@interface ZegoEffectsSmallMouthParam : NSObject

/// 详情信息：小嘴强度，范围 [-100~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整磨皮参数
///
@interface ZegoEffectsSmoothParam : NSObject

/// 详情信息：磨皮强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 开发者可通过该类调整白牙参数
///
@interface ZegoEffectsTeethWhiteningParam : NSObject

/// 详情信息：白牙强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 视频帧详细参数
///
@interface ZegoEffectsVideoFrameParam : NSObject

/// 详情信息：视频帧宽度，单位为像素
@property (nonatomic, assign) int width;

/// 详情描述：视频帧高度，单位为像素
@property (nonatomic, assign) int height;

/// 详情描述：视频数据帧格式
@property (nonatomic, assign) ZegoEffectsVideoFrameFormat format;

@end

/// 大眼参数
///
/// 详情描述：开发者可以通过该类修改大眼强度
///
@interface ZegoEffectsBigEyesParam : NSObject

/// 详情描述：大眼强度，取值范围 0~100
@property (nonatomic, assign) int intensity;

@end

/// 模糊参数
///
/// 详情描述：开发者可以通过该类修改模糊强度
///
@interface ZegoEffectsBlurParam : NSObject

/// 详情描述：模糊强度，取值范围 0~100
@property (nonatomic, assign) int intensity;

@end

/// 开发者可以通过该类修改美白信息
///
@interface ZegoEffectsWhitenParam : NSObject

/// 详情描述：美白强度，范围 [0~100]
@property (nonatomic, assign) int intensity;

@end

/// 绿幕参数类
///
/// 详情描述：开发者可以按需设置绿幕参数
///
@interface ZegoEffectsChromaKeyParam : NSObject

/// 详情描述：更新颜色容差，容差越大，被替换的范围越大，范围 [0~100] ，默认 67
@property (nonatomic, assign) float similarity;

/// 详情描述：更新边缘平滑指数，越大越平滑，但渲染也会越慢，范围 [0~100] ，默认 80
@property (nonatomic, assign) float smoothness;

/// 详情描述：更新透明度，范围 [0~100]，默认 100 (不透明)
@property (nonatomic, assign) int opacity;

/// 详情描述：更新要替换的颜色，格式：BGR，范围 [0,0xFFFFFF]，默认 0x00FF00
@property (nonatomic, assign) int keyColor;

///  详情描述：更新边缘像素采样半径，borderSize 越大边缘颜色过度越平缓，速度也越慢，背景和前景交接处的像素经常会有残留绿色，取附近像素平均值作为新的像素值，来去除残留，范围 [0~100]，默认 1
@property (nonatomic, assign) int borderSize;

@end

/// 人脸检测数据
///
@interface ZegoEffectsFaceDetectionResult : NSObject

/// 详情描述：人脸的置信度, 越大表示更大概率是人脸
@property (nonatomic, assign) float score;

/// 详情描述：人脸所在的矩形框, 完全包括了整个人脸, 单位是像素, 坐标系在输入图像的左上角
@property (nonatomic, assign) CGRect rect;

@end

NS_ASSUME_NONNULL_END
