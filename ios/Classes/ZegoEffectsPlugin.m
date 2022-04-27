#import "ZegoEffectsPlugin.h"
#import "ZegoEffectsMethodHandler.h"
#import "zegoEffectsEventHandler.h"
#import <objc/message.h>

@interface ZegoEffectsPlugin() <FlutterStreamHandler>

@property (nonatomic, strong) id<FlutterPluginRegistrar> registrar;

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;
@property (nonatomic, strong) FlutterEventChannel *eventChannel;

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation ZegoEffectsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"zego_effects_plugin"
                                     binaryMessenger:[registrar messenger]];
    ZegoEffectsPlugin *instance = [[ZegoEffectsPlugin alloc] init];
    instance.registrar = registrar;
    
    [registrar addMethodCallDelegate:instance channel:channel];
    instance.methodChannel = channel;
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.zego.im/zegoeffects_callback" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    instance.eventChannel = eventChannel;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([call.method isEqualToString:@"create"]) {
        NSMutableDictionary *argumentsMap = [NSMutableDictionary dictionaryWithDictionary:call.arguments];
        
        argumentsMap[@"registrar"] = _registrar;
        
        call = [FlutterMethodCall methodCallWithMethodName:@"create" arguments:argumentsMap];
    }
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:result:", call.method]);
    
    if (![[ZegoEffectsMethodHandler sharedInstance] respondsToSelector:selector]) {
        result(FlutterMethodNotImplemented);
        return;
    }
    
    NSMethodSignature *sign = [[ZegoEffectsMethodHandler sharedInstance] methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
    
    invocation.target = [ZegoEffectsMethodHandler sharedInstance];
    invocation.selector = selector;
    
    [invocation setArgument:&call atIndex:2];
    [invocation setArgument:&result atIndex:3];
    
    [invocation invoke];
}

#pragma mark- FlutterStreamHandler
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.eventSink = events;
    [[ZegoEffectsEventHandler sharedInstance] setEventSink:events];
    return nil;
}

@end
