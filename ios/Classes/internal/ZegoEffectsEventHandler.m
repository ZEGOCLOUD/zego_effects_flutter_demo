//
//  ZegoEffectsEventHandler.m
//  Pods-Runner
//
//  Created by zego on 2021/6/10.
//

#import "ZegoEffectsEventHandler.h"
#import <objc/message.h>


#define GUARD_SINK if(!sink){NSLog(@"[%s] FlutterEventSink is nil", __FUNCTION__);}

@interface ZegoEffectsEventHandler()

@end

@implementation ZegoEffectsEventHandler

+ (instancetype)sharedInstance {
    static ZegoEffectsEventHandler *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZegoEffectsEventHandler alloc] init];
    });
    
    return instance;
}

- (void)effects:(ZegoEffects *)effects errorCode:(int)errorCode desc:(NSString *)desc {
    FlutterEventSink sink = _eventSink;
    
    GUARD_SINK
    if (sink) {
        sink(@{
            @"errorCode": @(errorCode),
            @"desc": desc
        });
    }
}

- (void)effects:(ZegoEffects *)effects faceDetectionResults:(NSArray<ZegoEffectsFaceDetectionResult *> *)results {
    FlutterEventSink sink = _eventSink;
    if (sink) {
        for (ZegoEffectsFaceDetectionResult *result in results) {
            sink(@{
                @"score": @(result.score),
                @"x": @(result.rect.origin.x),
                @"y": @(result.rect.origin.y),
                @"width": @(result.rect.size.width),
                @"height": @(result.rect.size.height)
            });
        }
    }
}


@end
