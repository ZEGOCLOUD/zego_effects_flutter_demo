//
//  ZegoEffectsEventHandler.h
//  Pods-Runner
//
//  Created by zego on 2021/6/10.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <ZegoEffects/ZegoEffects.h>


NS_ASSUME_NONNULL_BEGIN

@interface ZegoEffectsEventHandler : NSObject<ZegoEffectsEventHandler>

+ (instancetype)sharedInstance;

@property (nonatomic, strong, nullable) FlutterEventSink eventSink;

@end

NS_ASSUME_NONNULL_END
