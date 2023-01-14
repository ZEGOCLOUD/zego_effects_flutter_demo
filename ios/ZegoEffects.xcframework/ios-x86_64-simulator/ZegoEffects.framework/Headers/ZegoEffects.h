//
//  ZegoEffects.h
//  ZegoEffects
//
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoEffectsEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoEffects : NSObject

/// 获取 SDK 版本号
///
/// SDK 在运行过程中，当开发者发现与预期情况不符时，可将问题与相关日志提交给 ZEGO 技术人员定位，ZEGO 技术人员可能需要 SDK 的版本的信息来辅助定位问题。
/// 开发者也可以收集此信息作为 App 所使用的 SDK 的版本信息，以便统计线上各版本 App 对应的各版本 SDK。
///
/// @return SDK 版本号
+ (NSString *)getVersion;

/// 获取授权信息
///
/// 在线鉴权时须向服务器发送授权信息,通过此接口获取。
///
///

+ (NSString *)getAuthInfo:(NSString *)appSign;

/// effects 高级功能开关，如不设置，默认不使用特殊功能。使用前请联系 ZEGO 技术支持。
///
/// 调用时机：初始化 SDK 之前
///
/// @param config effects 高级配置
+ (void)setAdvancedConfig:(ZegoEffectsAdvancedConfig *)config;

/// 设置 effects 静态资源
///
/// 在调用 [enableWhiten] [enableTeethWhitening] [setPendant] 接口时，需要调用此函数设置静态资源。
/// 支持同时设置多个资源路径。
/// 注意：必须在创建 Effects 实例前设置。
///
/// @param resourceInfoList 资源列表
+ (void)setResources:(nullable NSArray<NSString *> *)resourceInfoList;

/// 设置 AI 模型，支持同时设置多个模型
///
/// 详情描述：如果开发者需要使用到一些高级功能，人脸检测，人像分割等，就需要通过该接口设置 AI 模型，否则 AI 模型相关的功能将无法正常使用。
/// 调用时机/通知时机：全局生效，必须在创建 Effects 实例前设置。
///
/// @param modelInfoList ai模型路径
+ (void)setModels:(NSArray<NSString *> *)modelInfoList DEPRECATED_ATTRIBUTE;

/// 创建 Effects 实例
///
/// 在调用其他函数前需要先创建并初始化 Effects 实例；SDK 支持创建多个 ZegoEffects 实例
///
/// @param license 鉴权证书文件
+ (ZegoEffects *)create:(NSString *)license;

/// 销毁 effects 对象
///
/// 用于释放 SDK 使用的资源。
- (void)destroy;

/// 设置事件通知回调，传 [nil] 则清空已设置的回调。
///
/// @param eventHandler 事件通知回调。开发者应根据自身业务场景，重写回调的相关方法以关注特定的通知。SDK 主要的回调方法都在 [ZegoEffectsEventHandler] 里。
- (ZegoEffects *)setEventHandler:(nullable id<ZegoEffectsEventHandler>)eventHandler;

/// 开启亮眼, 开发者可以调用 [setEyesBrighteningParam] 来设置亮眼参数。
- (ZegoEffects *)enableEyesBrightening:(BOOL)enable;

/// 开启长下巴功能，可调用 [setLongChinParam] 接口设置长下巴参数。
- (ZegoEffects *)enableLongChin:(BOOL)enable;

/// 开启红润功能，可调用 [setRosyParam] 接口设置红润参数。
- (ZegoEffects *)enableRosy:(BOOL)enable;

/// 开启锐化功能，可调用 [setSharpenParam] 接口设置锐化参数。
- (ZegoEffects *)enableSharpen:(BOOL)enable;

/// 开启磨皮功能，可调用 [setSmoothParam] 接口设置磨皮参数。
- (ZegoEffects *)enableSmooth:(BOOL)enable;

/// 开启去除法令纹功能，可调用 [setWrinklesRemovingParam] 接口设置去除法令纹参数。
- (ZegoEffects *)enableWrinklesRemoving:(BOOL)enable;

/// 开启去除黑眼圈功能，可调用 [setDarkCirclesRemovingParam] 接口设置去除黑眼圈参数。
- (ZegoEffects *)enableDarkCirclesRemoving:(BOOL)enable;

/// 开启缩小额头高度功能，可调用 [setForeheadShorteningParam] 接口设置缩小额头高度参数。
- (ZegoEffects *)enableForeheadShortening:(BOOL)enable;

/// 开启瘦下颌骨功能，可调用 [setMandibleSlimmingParam] 接口设置瘦下颌骨参数。
- (ZegoEffects *)enableMandibleSlimming:(BOOL)enable;

/// 开启瘦颧骨功能，可调用 [setCheekboneSlimmingParam] 接口设置瘦颧骨参数。
- (ZegoEffects *)enableCheekboneSlimming:(BOOL)enable;

/// 开启小脸功能，可调用 [setFaceShorteningParam] 接口设置小脸参数。
- (ZegoEffects *)enableFaceShortening:(BOOL)enable;

/// 开启长鼻功能，可调用 [setNoseLengtheningParam] 接口设置长鼻参数。
- (ZegoEffects *)enableNoseLengthening:(BOOL)enable;

/// 开启眼线功能，可调用[setEyellinerParam]接口设置眼线参数。
/// 注意: 与风格妆功能互斥，设置眼线资源后会使风格妆效果失效。
- (ZegoEffects *)setEyeliner:(nullable NSString *)path;

/// 开启眼睫毛功能，可调用[setEyelashesParam]接口设置眼睫毛参数。
/// 注意: 与风格妆功能互斥，设置眼睫毛资源后会使风格妆效果失效。
- (ZegoEffects *)setEyelashes:(nullable NSString *)path;

///  开启眼影功能，可调用[setEyeshadowParam]接口设置眼影参数。
/// 注意: 与风格妆功能互斥，设置眼影资源后会使风格妆效果失效。
- (ZegoEffects *)setEyeshadow:(nullable NSString *)path;

/// 开启腮红功能，可调用[setBlusherParam]接口设置腮红参数。
/// 注意: 与风格妆功能互斥，设置腮红资源后会使风格妆效果失效。
- (ZegoEffects *)setBlusher:(nullable NSString *)path;

/// 开启口红功能，可调用[setLipstickParam]接口设置口红参数。
/// 注意: 与风格妆功能互斥，设置口红资源后会使风格妆效果失效。
- (ZegoEffects *)setLipstick:(nullable NSString *)path;

/// 开启美瞳功能，可调用[setColoredcontactsParam]接口设置美瞳参数。
/// 注意: 与风格妆功能互斥，设置美瞳资源后会使风格妆效果失效。
- (ZegoEffects *)setColoredcontacts:(nullable NSString *)path;

/// 开启风格妆功能,可调用[setMakeupParam]接口设置风格妆参数。
/// 注意: 与挂件，腮红，眼线，眼睫毛，眼影，口红，美瞳功能互斥，设置风格妆资源后会使挂件，腮红，眼线，眼睫毛，眼影，口红，美瞳效果失效。
- (ZegoEffects *)setMakeup:(nullable NSString *)path;

/// 设置亮眼参数
- (ZegoEffects *)setEyesBrighteningParam:(ZegoEffectsEyesBrighteningParam *)param;

/// 设置滤镜资源，设置 [nil] 默认去除滤镜
///
/// 支持版本：1.1.0
/// 详情描述：开发者可调用 [setFilterParam] 进行设置滤镜参数，当设置对应滤镜源时，会自动启动美妆滤镜功能
///
/// @param path 滤镜资源的绝对路径
- (ZegoEffects *)setFilter:(nullable NSString *)path;

/// 设置滤镜参数
- (ZegoEffects *)setFilterParam:(ZegoEffectsFilterParam *)param;

/// 设置长下巴参数
- (ZegoEffects *)setLongChinParam:(ZegoEffectsLongChinParam *)param;

/// 设置瘦鼻参数
- (ZegoEffects *)setNoseNarrowingParam:(ZegoEffectsNoseNarrowingParam *)param;

/// 设置挂件
///
/// 开发者可通过该接口设置不同的挂件。
/// 注意：设置新的挂件后都会覆盖上次设置的挂件，如果需要关闭挂件请设置 [nil]
/// 注意: 与风格妆功能互斥，设置挂件资源后会使风格妆效果失效。
/// 挂件可能会覆盖一些美颜的效果
///
/// @param path 挂件的绝对路径
- (ZegoEffects *)setPendant:(nullable NSString *)path;

/// 设置红润参数。
- (ZegoEffects *)setRosyParam:(ZegoEffectsRosyParam *)param;

/// 设置锐化参数。
- (ZegoEffects *)setSharpenParam:(ZegoEffectsSharpenParam *)param;

/// 设置小嘴参数。
- (ZegoEffects *)setSmallMouthParam:(ZegoEffectsSmallMouthParam *)param;

/// 设置磨皮参数。
- (ZegoEffects *)setSmoothParam:(ZegoEffectsSmoothParam *)param;

/// 设置白牙参数。
- (ZegoEffects *)setTeethWhiteningParam:(ZegoEffectsTeethWhiteningParam *)param;

/// 设置去除法令纹参数。
- (ZegoEffects *)setWrinklesRemovingParam:(ZegoEffectsWrinklesRemovingParam *)param;

/// 设置去除黑眼圈参数。
- (ZegoEffects *)setDarkCirclesRemovingParam:(ZegoEffectsDarkCirclesRemovingParam *)param;

/// 设置缩小额头高度参数。
- (ZegoEffects *)setForeheadShorteningParam:(ZegoEffectsForeheadShorteningParam *)param;

/// 设置瘦颧骨参数。
- (ZegoEffects *)setCheekboneSlimmingParam:(ZegoEffectsCheekboneSlimmingParam *)param;

/// 设置瘦下颌骨参数。
- (ZegoEffects *)setMandibleSlimmingParam:(ZegoEffectsMandibleSlimmingParam *)param;

/// 设置小脸参数。
- (ZegoEffects *)setFaceShorteningParam:(ZegoEffectsFaceShorteningParam *)param;

/// 设置长鼻参数。
- (ZegoEffects *)setNoseLengtheningParam:(ZegoEffectsNoseLengtheningParam *)param;

/// 设置眼线参数。
- (ZegoEffects *)setEyelinerParam:(ZegoEffectsEyelinerParam *)param;

/// 设置眼睫毛参数。
- (ZegoEffects *)setEyelashesParam:(ZegoEffectsEyelashesParam *)param;

/// 设置眼影参数。
- (ZegoEffects *)setEyeshadowParam:(ZegoEffectsEyeshadowParam *)param;

/// 设置腮红参数。
- (ZegoEffects *)setBlusherParam:(ZegoEffectsBlusherParam *)param;

/// 设置口红参数。
- (ZegoEffects *)setLipstickParam:(ZegoEffectsLipstickParam *)param;

///  设置美瞳参数。
- (ZegoEffects *)setColoredcontactsParam:(ZegoEffectsColoredcontactsParam *)param;

///  设置风格妆参数。
- (ZegoEffects *)setMakeupParam:(ZegoEffectsMakeupParam *)param;

/// 开启大眼功能，可调用[setBigEyesParam]接口设置大眼参数。
- (ZegoEffects *)enableBigEyes:(BOOL)enable;

/// 设置大眼参数。
- (ZegoEffects *)setBigEyesParam:(ZegoEffectsBigEyesParam *)param;

/// 开启白牙功能, 可以通过 [setTeethWhiteningParam] 接口设置白牙参数。
- (ZegoEffects *)enableTeethWhitening:(BOOL)enable;

/// 开启后皮肤会变得更白
- (ZegoEffects *)enableWhiten:(BOOL)enable;

/// 设置美白参数
- (ZegoEffects *)setWhitenParam:(ZegoEffectsWhitenParam *)param;

/// 初始化 effects 引擎环境
///
/// 在处理图像或视频数据前，需要调用该接口初始化 effects 引擎环境。
/// 注意：在第一次初始化时，如果有使用到 ai 相关的功能，该接口会产生耗时，请不要在主线程调用该接口，否则会造成 UI 线程卡顿。
///
/// @param resolution 画面分辨率
- (void)initEnv:(CGSize)resolution;

/// 设置瘦脸参数
- (ZegoEffects *)setFaceLiftingParam:(ZegoEffectsFaceLiftingParam *)param;

/// 反初始化 effects 引擎环境
///
/// 在停止使用摄像头进行采集时，可以调用该接口反初始化 effects 引擎环境，反初始化会释放引擎内部一些耗资源的线程以及内存，另外反初始化后并不会释放已经加载的 ai 模型以及静态资源，只有销毁 SDK 才会释放，所以当下次再次使用 initEnv 时不会因为模型加载导致耗时。
- (void)uninitEnv;

/// 开启绿幕分割
///
/// 启动绿幕分割后引擎会把绿色作为关键颜色，并把绿色以外的颜色进行抠图，开发者可以通过 [enableChromaKeyBackground] [enableChromaKeyBackgroundBlur] [enableChromaKeyBackgroundMosaic] 接口修改绿幕自定义背景
- (ZegoEffects *)enableChromaKey:(BOOL)enable;

/// 设置绿幕自定义背景路径
///
/// 在使用自定义背景时，需要调用 [enableChromaKeyBackground] 启用自定义背景后该接口设置的背景才能生效。
///
/// @param imagePath 图片路径
/// @param mode 显示的视图模式
- (ZegoEffects *)setChromaKeyBackgroundPath:(NSString *)imagePath mode:(ZegoEffectsScaleMode)mode;

/// 设置绿幕分割参数
///
/// 开发者可以通过该接口调整绿幕容差，关键色等参数。
- (ZegoEffects *)setChromaKeyParam:(ZegoEffectsChromaKeyParam *)param;

/// 开启绿幕分割自定义背景后 SDK 引擎会将绿色作为关键颜色并替换成开发者设置的背景。
///
/// 开发者还可以通过 [setChromaKeyBackgroundBuffer]  [setChromaKeyBackgroundPath]  [setChromaKeyBackgroundTexture] 设置绿幕自定义背景
/// 注意：[enableChromaKeyBackgroundMosaic] [enableChromaKeyBackground] [enableChromaKeyBackgroundBlur] 中的接口只能启动其中一个，其中每次 enable 后都会覆盖前一个功能。
- (ZegoEffects *)enableChromaKeyBackground:(BOOL)enable;

/// 开启绿幕分割背景模糊，启动后可通过 [setChromaKeyBackgroundBlurParam] 设置背景模糊参数。
- (ZegoEffects *)enableChromaKeyBackgroundBlur:(BOOL)enable;

/// 开启绿幕背景马赛克，启动后 SDK 引擎会把绿幕背景会变成马赛克。
///
/// 开发者还可以通过 [setChromaKeyBackgroundMosaicParam] 设置绿幕马赛克参数。
/// 注意：[enableChromaKeyBackgroundMosaic] [enableChromaKeyBackground] [enableChromaKeyBackgroundBlur] 中的接口只能启动其中一个，其中每次 enable 后都会覆盖前一个功能。
- (ZegoEffects *)enableChromaKeyBackgroundMosaic:(BOOL)enable;

/// 开启 ai 人像分割，启动后 SDK 引擎会把人像进行抠图并把背景alpha通道改成 0，开发者可以通过使用透明的背景来达到在背景播放视频的目的。
/// 开发者还可以通过 [enablePortraitSegmentationBackground] [enablePortraitSegmentationBackgroundMosaic] [enablePortraitSegmentationBackgroundBlur] 接口来设置自定义背景或马赛克背景或高斯模糊背景。
/// 该功能适用于在背景播放视频或在背景播放ppt等业务场景。
- (ZegoEffects *)enablePortraitSegmentation:(BOOL)enable;

/// 开启 ai 人像分割自定义背景，启动后可通过 [setPortraitSegmentationBackgroundTexture] [setPortraitSegmentationBackgroundPath] [setPortraitSegmentationBackgroundBuffer] 等接口设置自定义背景。
/// SDK 会将人像抠图，并把人像放在开发者设置的背景图片上。
- (ZegoEffects *)enablePortraitSegmentationBackground:(BOOL)enable;

/// 开启 ai 人像分割背景模糊，启动后可通过 [setPortraitSegmentationBackgroundBlurParam] 设置背景模糊参数。
- (ZegoEffects *)enablePortraitSegmentationBackgroundBlur:(BOOL)enable;

/// 开启 ai 人像分割背景马赛克，启动后可通过 [setPortraitSegmentationBackgroundMosaicParam] 设置马赛克类型。
- (ZegoEffects *)enablePortraitSegmentationBackgroundMosaic:(BOOL)enable;

/// 设置绿幕背景模糊参数
///
/// 在使用背景模糊时，需要调用 [enableChromaKeyBackgroundBlur] 启用背景模糊后该接口设置的背景才能生效。
- (ZegoEffects *)setChromaKeyBackgroundBlurParam:(ZegoEffectsBlurParam *)param;

/// 设置绿幕分割自定义背景
///
/// 在使用自定义背景时，需要调用 [enableChromaKeyBackground] 启用自定义背景后该接口设置的背景才能生效。
///
/// @param mode 显示的视图模式
- (ZegoEffects *)setChromaKeyBackgroundBuffer:(CVPixelBufferRef)buffer
                                         mode:(ZegoEffectsScaleMode)mode;

/// 设置绿幕分割背景马赛克参数
///
/// 需要调用 [enableChromaKeyBackgroundMosaic] 启用背景马赛克后该接口设置的背景才能生效。
///
/// @param param 马赛克参数
- (ZegoEffects *)setChromaKeyBackgroundMosaicParam:(ZegoEffectsMosaicParam *)param;

/// 设置绿幕分割前景位置
///
/// 在绿幕分割使用自定义背景时，可以通过该接口调整前景的位置坐标
- (ZegoEffects *)setChromaKeyForegroundPosition:(CGRect)rect;

/// 设置 ai 人像分割背景模糊参数
///
/// 在使用背景模糊时，需要调用 [enablePortraitSegmentationBackgroundBlur] 启用背景模糊后该接口设置的背景才能生效。
- (ZegoEffects *)setPortraitSegmentationBackgroundBlurParam:(ZegoEffectsBlurParam *)param;

/// 设置 ai 人像分割自定义背景
///
/// 在使用自定义背景时，需要调用 [enablePortraitSegmentationBackground] 启用自定义背景后该接口设置的背景才能生效。
///
/// @param buffer 图片帧数据
/// @param mode 显示的视图模式
- (ZegoEffects *)setPortraitSegmentationBackgroundBuffer:(CVPixelBufferRef)buffer
                                                    mode:(ZegoEffectsScaleMode)mode;

/// 设置 人像分割背景马赛克参数
///
/// 需要调用 [enablePortraitSegmentationBackgroundMosaic] 启用背景马赛克后该接口设置的背景才能生效。
///
/// @param param 马赛克参数
- (ZegoEffects *)setPortraitSegmentationBackgroundMosaicParam:(ZegoEffectsMosaicParam *)param;

/// 设置 ai 人像分割自定义背景路径
///
/// 在使用自定义背景时，需要调用 [enablePortraitSegmentationBackground] 启用自定义背景后该接口设置的背景才能生效。
///
/// @param imagePath 图片路径
/// @param mode 显示的视图模式
- (ZegoEffects *)setPortraitSegmentationBackgroundPath:(nullable NSString *)imagePath
                                                  mode:(ZegoEffectsScaleMode)mode;

/// 设置人像分割前景位置
///
/// 在人像分割使用自定义背景时，可以通过该接口调整前景的位置坐标
- (ZegoEffects *)setPortraitSegmentationForegroundPosition:(CGRect)rect;

/// 开启人脸检测
///
/// 启动人脸检测后，开发者可通过 [ZegoEffectsEventHandler] 中的 [onFaceDetectionResult] 来获取人脸检测结果，包括人脸数量，人脸坐标等。
- (ZegoEffects *)enableFaceDetection:(BOOL)enable;

/// 开启后脸会变得更苗条，下巴更瘦
- (ZegoEffects *)enableFaceLifting:(BOOL)enable;

/// 启用瘦鼻子函数，你可以调用 [setNoseNarrowingParam] 接口来设置参数。
///
/// @param enable true 为打开瘦鼻功能，默认为 false
- (ZegoEffects *)enableNoseNarrowing:(BOOL)enable;

/// 开启长小嘴功能，可调用 [setSmallMouthParam] 接口设置参数。
- (ZegoEffects *)enableSmallMouth:(BOOL)enable;

///// 设置 AI 模型，支持同时设置多个模型
/////
///// 详情描述：如果开发者需要使用到一些高级功能，人脸检测，人像分割等，就需要通过该接口设置 AI 模型，否则 AI 模型相关的功能将无法正常使用。
///// 调用时机/通知时机：全局生效，必须在创建 Effects 实例前设置。
/////
///// @param modelInfoList ai模型路径
//+ (void)setModels:(NSArray<NSString *> *)modelInfoList;

/// 处理图像，该接口需要传入的图片类型为 CVPixelBufferRef 类型。
///
/// 注意：在处理图像前请先调用 [initEnv] 初始化引擎环境，如果没有初始化引擎环境，会导致美颜失效。
- (void)processImageBuffer:(CVPixelBufferRef)buff;

- (void)processWithTextureId:(uint32_t)textureId width:(uint32_t)width height:(uint32_t)height;

@end

NS_ASSUME_NONNULL_END
