//
//  ZegoEffectsEventHandler.h
//  ZegoEffects
//
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoEffectsDefines.h"

@class ZegoEffects;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Zego Effects Event Handler

@protocol ZegoEffectsEventHandler <NSObject>

@optional

/// 错误信息回调
///
/// 调用 SDK 函数出现异常时，会通过该回调提示详细的异常信息
///
/// @param errorCode 引擎错误码
- (void)effects:(ZegoEffects *)effects errorCode:(int)errorCode desc:(NSString *)desc;

/// 人脸检测回调
///
/// 详情描述：开发者可通过 [enableFaceDetection] 启动人脸检测，SDK 会将检测的人脸数据通过该回调返回。
- (void)effects:(ZegoEffects *)effects
    faceDetectionResults:(NSArray<ZegoEffectsFaceDetectionResult *> *)results;

@end

NS_ASSUME_NONNULL_END
