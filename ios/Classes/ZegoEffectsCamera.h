//
//  ZegoEffectsCamera.h
//  zego_effects_plugin
//
//  Created by zego on 2021/6/18.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <ZegoEffects/ZegoEffects.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoEffectsCamera : NSObject

@property (nonatomic, strong) ZegoEffects *effects;

// switch camera(front or back)
- (BOOL)switchCamera:(AVCaptureDevicePosition)position;

// set the framerate of camera
- (void)setCameraFrameRate:(int)framerate;

@end

NS_ASSUME_NONNULL_END
