//
//  ZegoEffectsMethodHandler.m
//  Pods-Runner
//
//  Created by zego on 2021/6/10.
//

#import "ZegoEffectsMethodHandler.h"
#import "ZegoEffectsCamera.h"
#import "ZegoEffectsEventHandler.h"
#import <ZegoEffects/ZegoEffects.h>
#import <objc/message.h>

@interface ZegoEffectsMethodHandler()

@property (nonatomic, strong) id<FlutterPluginRegistrar> registrar;

@property (nonatomic, strong) ZegoEffects *effects;

@property (nonatomic, strong) ZegoEffectsCamera *camera;

@end

@implementation ZegoEffectsMethodHandler

+ (instancetype)sharedInstance {
    static ZegoEffectsMethodHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZegoEffectsMethodHandler alloc] init];
    });
    
    return instance;
}

#pragma mark- Main
- (void)getVersion:(FlutterMethodCall *)call result:(FlutterResult)result {
    result([ZegoEffects getVersion]);
}

- (void)getAuthInfo:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString * appSign = call.arguments[@"appSign"];
    result([ZegoEffects getAuthInfo:appSign]);
}


- (void)setResources:(FlutterMethodCall *)call result:(FlutterResult)result {

    if (self.effects) {
        NSLog(@"ZegoEffects is null.");
        return;
    }
    NSString *commonResources = [[NSBundle mainBundle] pathForResource:@"CommonResources" ofType:@"bundle"];
    NSString *faceWhiteningResources = [[NSBundle mainBundle] pathForResource:@"FaceWhiteningResources" ofType:@"bundle"];
    NSString *pendantResources = [[NSBundle mainBundle] pathForResource:@"PendantResources" ofType:@"bundle"];
    NSString *teethWhiteningResources = [[NSBundle mainBundle] pathForResource:@"TeethWhiteningResources" ofType:@"bundle"];
    NSString *rosyResources = [[NSBundle mainBundle] pathForResource:@"RosyResources" ofType:@"bundle"];

    
    NSString *faceDetectionModelPath = [[NSBundle mainBundle] pathForResource:@"FaceDetectionModel" ofType:@"model"];
    NSString *segmentationModelPath = [[NSBundle mainBundle] pathForResource:@"SegmentationModel" ofType:@"model"];

    NSArray<NSString *> * resourcesList = @[commonResources, faceWhiteningResources, pendantResources, teethWhiteningResources, rosyResources,faceDetectionModelPath,segmentationModelPath];
    [ZegoEffects setResources:resourcesList];
    result(nil);
}

- (void)setPendant:(FlutterMethodCall *)call result:(FlutterResult)result {

    if (call != nil && call.arguments[@"pendantName"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"pendantName"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setPendant:bundlePath];
        });
    }else{
        [self.effects setPendant:nil];
    }
    result(nil);
}

- (void)create:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *license = call.arguments[@"license"];
    
    _registrar = call.arguments[@"registrar"];
    
    self.effects = [ZegoEffects create:license];
    if (self.effects) {
        result(@(0));
    }else {
        result(@(-1));
    }
}

- (void)destroy:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self.effects destroy];
    result(nil);
}

- (void)initEnv:(FlutterMethodCall *)call result:(FlutterResult)result {
    float width = [call.arguments[@"width"] floatValue];
    float height = [call.arguments[@"height"] floatValue];
    CGSize resolution = CGSizeMake(width, height);
    
    [self.effects initEnv:resolution];
    result(@(0));
}

- (void)uninitEnv:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self.effects uninitEnv];
    result(nil);
}

- (void)registerEventCallback:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self.effects setEventHandler:[ZegoEffectsEventHandler sharedInstance]];
    result(nil);
}

- (void)destoyEventCallback:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self.effects setEventHandler:nil];
    result(nil);
}

- (void)startWithCustomCaptureSource:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (self.effects) {
        ZegoEffectsCamera *camera = [[ZegoEffectsCamera alloc] init];
        camera.effects = self.effects;
        self.camera = camera;
        Class managerClass = NSClassFromString(@"ZegoCustomVideoCaptureManager");
        SEL managerSelector = NSSelectorFromString(@"sharedInstance");
        id sharedManager = ((id (*)(id, SEL))objc_msgSend)(managerClass, managerSelector);
        
        SEL setCustomVideoCaptureHandlerSelector = NSSelectorFromString(@"setCustomVideoCaptureHandler:");
        ((void (*)(id, SEL, id))objc_msgSend)(sharedManager, setCustomVideoCaptureHandlerSelector, self.camera);
    }
    result(nil);
}

- (void)stopEffects:(FlutterMethodCall *)call result:(FlutterResult)result {
    self.camera = nil;
    result(nil);
}

- (void)switchCamera:(FlutterMethodCall *)call result:(FlutterResult)result {
    int position = [call.arguments[@"position"] intValue];
    AVCaptureDevicePosition pos = AVCaptureDevicePositionUnspecified;
    switch (position) {
        case 0:
            pos = AVCaptureDevicePositionFront;
            break;
        case 1:
            pos = AVCaptureDevicePositionBack;
        default:
            break;
    }
}

- (void)setCameraFrameRate:(FlutterMethodCall *)call result:(FlutterResult)result {
    int fps = [call.arguments[@"fps"] intValue];

    if(self.camera) {
        [self.camera setCameraFrameRate:fps];
    }
    
    result(nil);
}

- (void)enablePortraitSegmentation:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enablePortraitSegmentation:enable];
    result(nil);
}

- (void)enablePortraitSegmentationBackgroundMosaic:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enablePortraitSegmentationBackgroundMosaic:enable];
    result(nil);
}

- (void)setPortraitSegmentationBackgroundMosaicParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsMosaicType type = [call.arguments[@"type"] intValue];
    ZegoEffectsMosaicParam *param = [[ZegoEffectsMosaicParam alloc] init];
    param.intensity = intensity;
    param.type = type;
    [self.effects setPortraitSegmentationBackgroundMosaicParam:param];
    result(nil);
}

- (void)enablePortraitSegmentationBackground:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enablePortraitSegmentationBackground:enable];
    result(nil);
}

- (void)enablePortraitSegmentationBackgroundBlur:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enablePortraitSegmentationBackgroundBlur:enable];
    result(nil);
}

- (void)setPortraitSegmentationBackgroundBlurParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] boolValue];
    ZegoEffectsBlurParam *param = [[ZegoEffectsBlurParam alloc] init];
    param.intensity = intensity;
    [self.effects setPortraitSegmentationBackgroundBlurParam:param];
    result(nil);
}

- (void)setPortraitSegmentationBackgroundPath:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *path = call.arguments[@"path"];
    ZegoEffectsScaleMode mode = [call.arguments[@"mode"] intValue];
    
    [self.effects setPortraitSegmentationBackgroundPath:path mode:mode];
    result(nil);
}

- (void)setPortraitSegmentationForegroundPosition:(FlutterMethodCall *)call result:(FlutterResult)result {
    float x = [call.arguments[@"x"] floatValue];
    float y = [call.arguments[@"y"] floatValue];
    float width = [call.arguments[@"width"] floatValue];
    float height = [call.arguments[@"height"] floatValue];
    CGRect position = CGRectMake(x, y, width, height);
    [self.effects setPortraitSegmentationForegroundPosition:position];
    
    result(nil);
}

#pragma mark - Face Detection
- (void)enableFaceDetection:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableFaceDetection:enable];
    result(nil);
}

#pragma mark - Basic beauty effects

#pragma mark Whiten
- (void)enableWhiten:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableWhiten:enable];
    result(nil);
}
- (void)setWhitenParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsWhitenParam *param = [[ZegoEffectsWhitenParam alloc] init];
    param.intensity = intensity;
    [self.effects setWhitenParam:param];
    
    result(nil);
}

#pragma mark Smooth
- (void)enableSmooth:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableSmooth:enable];
    result(nil);
}

- (void)setSmoothParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsSmoothParam *param = [[ZegoEffectsSmoothParam alloc] init];
    param.intensity = intensity;
    [self.effects setSmoothParam:param];
    
    result(nil);
}

#pragma mark Rosy
- (void)enableRosy:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableRosy:enable];
    result(nil);
}

- (void)setRosyParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsRosyParam *param = [[ZegoEffectsRosyParam alloc] init];
    param.intensity = intensity;
    [self.effects setRosyParam:param];
    
    result(nil);
}

#pragma mark Sharpen
- (void)enableSharpen:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableSharpen:enable];
    result(nil);
}

- (void)setSharpenParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsSharpenParam *param = [[ZegoEffectsSharpenParam alloc] init];
    param.intensity = intensity;
    [self.effects setSharpenParam:param];
    
    result(nil);
}

#pragma mark WrinklesRemoving
- (void)enableWrinklesRemoving:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableWrinklesRemoving:enable];
    result(nil);
}

- (void)setWrinklesRemovingParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsWrinklesRemovingParam *param = [[ZegoEffectsWrinklesRemovingParam alloc] init];
    param.intensity = intensity;
    [self.effects setWrinklesRemovingParam:param];
    result(nil);
}


#pragma mark DarkCirclesRemoving
- (void)enableDarkCirclesRemoving:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableDarkCirclesRemoving:enable];
    result(nil);
}

- (void)setDarkCirclesRemovingParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsDarkCirclesRemovingParam *param = [[ZegoEffectsDarkCirclesRemovingParam alloc] init];
    param.intensity = intensity;
    [self.effects setDarkCirclesRemovingParam:param];
    result(nil);
}


#pragma mark - Body Shape Beauty

#pragma mark Big Eyes
- (void)enableBigEyes:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableBigEyes:enable];
    result(nil);
}

- (void)setBigEyesParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsBigEyesParam *param = [[ZegoEffectsBigEyesParam alloc] init];
    param.intensity = intensity;
    [self.effects setBigEyesParam:param];
    result(nil);
}

#pragma mark Face Lifting
- (void)enableFaceLifting:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableFaceLifting:enable];
    result(nil);
}

- (void)setFaceLiftingParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsFaceLiftingParam *param = [[ZegoEffectsFaceLiftingParam alloc] init];
    param.intensity = intensity;
    [self.effects setFaceLiftingParam:param];
    result(nil);
}

#pragma mark Eye Brightening
- (void)enableEyesBrightening:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableEyesBrightening:enable];
    result(nil);
}

- (void)setEyesBrighteningParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsEyesBrighteningParam *param = [[ZegoEffectsEyesBrighteningParam alloc] init];
    param.intensity = intensity;
    [self.effects setEyesBrighteningParam:param];
    
    result(nil);
}

#pragma mark Nose Narrowing
- (void)enableNoseNarrowing:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableNoseNarrowing:enable];
    result(nil);
}

- (void)setNoseNarrowingParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsNoseNarrowingParam *param = [[ZegoEffectsNoseNarrowingParam alloc] init];
    param.intensity = intensity;
    [self.effects setNoseNarrowingParam:param];
    
    result(nil);
}

#pragma mark Teeth Whitening
- (void)enableTeethWhitening:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableTeethWhitening:enable];
    result(nil);
}

- (void)setTeethWhiteningParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsTeethWhiteningParam *param = [[ZegoEffectsTeethWhiteningParam alloc] init];
    param.intensity = intensity;
    [self.effects setTeethWhiteningParam:param];
    
    result(nil);
}


#pragma mark Long Chin
- (void)enableLongChin:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableLongChin:enable];
    result(nil);
}

- (void)setLongChinParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsLongChinParam *param = [[ZegoEffectsLongChinParam alloc] init];
    param.intensity = intensity;
    [self.effects setLongChinParam:param];
    
    result(nil);
}



#pragma mark Forehead Shortening
- (void)enableForeheadShortening:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableForeheadShortening:enable];
    result(nil);
}

- (void)setForeheadShorteningParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsForeheadShorteningParam *param = [[ZegoEffectsForeheadShorteningParam alloc] init];
    param.intensity = intensity;
    [self.effects setForeheadShorteningParam:param];
    
    result(nil);
}


#pragma mark Mandible Slimming
- (void)enableMandibleSlimming:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableMandibleSlimming:enable];
    result(nil);
}

- (void):(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsMandibleSlimmingParam *param = [[ZegoEffectsMandibleSlimmingParam alloc] init];
    param.intensity = intensity;
    [self.effects setMandibleSlimmingParam:param];
    
    result(nil);
}


#pragma mark Cheekbone Slimming
- (void)enableCheekboneSlimming:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableCheekboneSlimming:enable];
    result(nil);
}

- (void)setCheekboneSlimmingParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsCheekboneSlimmingParam *param = [[ZegoEffectsCheekboneSlimmingParam alloc] init];
    param.intensity = intensity;
    [self.effects setCheekboneSlimmingParam:param];
    
    result(nil);
}

#pragma mark Face Shorten
- (void)enableFaceShortening:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableFaceShortening:enable];
    result(nil);
}

- (void)setFaceShorteningParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsFaceShorteningParam *param = [[ZegoEffectsFaceShorteningParam alloc] init];
    param.intensity = intensity;
    [self.effects setFaceShorteningParam:param];
    
    result(nil);
}

#pragma mark Nose Lengthening
- (void)enableNoseLengthening:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableNoseLengthening:enable];
    result(nil);
}

- (void)setNoseLengtheningParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsNoseLengtheningParam *param = [[ZegoEffectsNoseLengtheningParam alloc] init];
    param.intensity = intensity;
    [self.effects setNoseLengtheningParam:param];
    
    result(nil);
}

#pragma mark Small Mouth
- (void)enableSmallMouth:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableSmallMouth:enable];
    result(nil);
}

- (void)setSmallMouthParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsSmallMouthParam *param = [[ZegoEffectsSmallMouthParam alloc] init];
    param.intensity = intensity;
    [self.effects setSmallMouthParam:param];
    
    result(nil);
}


#pragma mark - Makeup
#pragma mark Eyeliner
- (void)setEyeliner:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"name"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"name"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setEyeliner:bundlePath];
        });
    }else{
        [self.effects setEyeliner:nil];
    }
    result(nil);
}

- (void)setEyelinerParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsEyelinerParam *param = [[ZegoEffectsEyelinerParam alloc] init];
    param.intensity = intensity;
    [self.effects setEyelinerParam:param];
    
    result(nil);
}

#pragma mark setEyeshadow
- (void)setEyeshadow:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"name"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"name"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setEyeshadow:bundlePath];
        });
    }else{
        [self.effects setEyeshadow:nil];
    }
    
    result(nil);
}

- (void)setEyeshadowParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsEyeshadowParam *param = [[ZegoEffectsEyeshadowParam alloc] init];
    param.intensity = intensity;
    [self.effects setEyeshadowParam:param];
    
    result(nil);
}


#pragma mark Eyelashes
- (void)setEyelashes:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"name"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"name"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setEyelashes:bundlePath];
        });
    }else{
        [self.effects setEyelashes:nil];
    }
    
    
    result(nil);
}

- (void)setEyelashesParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsEyelashesParam *param = [[ZegoEffectsEyelashesParam alloc] init];
    param.intensity = intensity;
    [self.effects setEyelashesParam:param];
    
    result(nil);
}


#pragma mark Blusher
- (void)setBlusher:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"name"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"name"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setBlusher:bundlePath];
        });
    }else{
        [self.effects setBlusher:nil];
    }
    result(nil);
}

- (void)setBlusherParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsBlusherParam *param = [[ZegoEffectsBlusherParam alloc] init];
    param.intensity = intensity;
    [self.effects setBlusherParam:param];
    
    result(nil);
}

#pragma mark Lipstick
- (void)setLipstick:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"name"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"name"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setLipstick:bundlePath];
        });
    }else{
        [self.effects setLipstick:nil];
    }
    result(nil);
}

- (void)setLipstickParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsLipstickParam *param = [[ZegoEffectsLipstickParam alloc] init];
    param.intensity = intensity;
    [self.effects setLipstickParam:param];
    
    result(nil);
}


#pragma mark Coloredcontacts
- (void)setColoredcontacts:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"name"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"name"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setColoredcontacts:bundlePath];
        });
    }else{
        [self.effects setColoredcontacts:nil];
    }
    result(nil);
}

- (void)setColoredcontactsParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsColoredcontactsParam *param = [[ZegoEffectsColoredcontactsParam alloc] init];
    param.intensity = intensity;
    [self.effects setColoredcontactsParam:param];
    
    result(nil);
}

#pragma mark Style Makeup
- (void)setMakeup:(FlutterMethodCall *)call result:(FlutterResult)result {
    
    if(call != nil && call.arguments[@"name"] != [NSNull null]){
        NSString * bundleName = call.arguments[@"name"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setMakeup:bundlePath];
        });
    }else{
        [self.effects setMakeup:nil];
    }
    result(nil);
}

- (void)setMakeupParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsMakeupParam *param = [[ZegoEffectsMakeupParam alloc] init];
    param.intensity = intensity;
    [self.effects setMakeupParam:param];
    
    result(nil);
}

#pragma mark - Filter
- (void)setFilter:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (call != nil && call.arguments[@"filterName"] != [NSNull null]) {
        NSString *bundleName = call.arguments[@"filterName"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
            [self.effects setFilter:bundlePath];
        });
    }else{
        [self.effects setFilter:nil];
    }
    result(nil);
}

- (void)setFilterParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsFilterParam *param = [[ZegoEffectsFilterParam alloc] init];
    param.intensity = intensity;
    [self.effects setFilterParam:param];
    
    result(nil);
}


#pragma mark - Chroma Key
//绿幕分割
- (void)enableChromaKey:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableChromaKey:enable];
    result(nil);
}

- (void)enableChromaKeyBackground:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableChromaKeyBackground:enable];
    result(nil);
}

- (void)enableChromaKeyBackgroundMosaic:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableChromaKeyBackgroundMosaic:enable];
    result(nil);
}

- (void)setChromaKeyBackgroundMosaicParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsMosaicParam *param = [[ZegoEffectsMosaicParam alloc] init];
    param.intensity = intensity;
    [self.effects setChromaKeyBackgroundMosaicParam:param];
    
    result(nil);
}

- (void)setChromaKeyParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    float similarity = [call.arguments[@"similarity"] intValue];
    float smoothness = [call.arguments[@"smoothness"] intValue];
    int opacity = [call.arguments[@"opacity"] intValue];
    int keyColor = [call.arguments[@"keyColor"] intValue];
    int borderSize = [call.arguments[@"borderSize"] intValue];
    
    ZegoEffectsChromaKeyParam *param = [[ZegoEffectsChromaKeyParam alloc] init];
    param.similarity = similarity;
    param.smoothness = smoothness;
    param.opacity = opacity;
    param.keyColor = keyColor;
    param.borderSize = borderSize;
    
    [self.effects setChromaKeyParam:param];
    
    result(nil);
}

- (void)enableChromaKeyBackgroundBlur:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableChromaKeyBackgroundBlur:enable];
    result(nil);
}

- (void)setChromaKeyBackgroundBlurParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsBlurParam *param = [[ZegoEffectsBlurParam alloc] init];
    param.intensity = intensity;
    [self.effects enableChromaKeyBackgroundBlur:param];
    
    result(nil);
}

- (void)setChromaKeyBackgroundPath:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *path = call.arguments[@"path"];
    ZegoEffectsScaleMode mode = [call.arguments[@"mode"] intValue];
    [self.effects setPortraitSegmentationBackgroundPath:path mode:mode];
    
    result(nil);
}

- (void)setChromaKeyForegroundPosition:(FlutterMethodCall *)call result:(FlutterResult)result {
    float x = [call.arguments[@"x"] floatValue];
    float y = [call.arguments[@"y"] floatValue];
    float width = [call.arguments[@"width"] floatValue];
    float height = [call.arguments[@"height"] floatValue];
    CGRect position = CGRectMake(x, y, width, height);
    
    [self.effects setChromaKeyForegroundPosition:position];
    
    result(nil);
}

#pragma mark - Others
/*
- (NSString *)styleMakeupPathWithBundleName:(NSString *)bundleName {
    NSString *folderPath = [[NSBundle mainBundle] pathForResource:@"MakeupResources" ofType:nil];
    NSString *rscPath = [folderPath stringByAppendingPathComponent:@"makeupdir"];
    rscPath = [rscPath stringByAppendingPathComponent:bundleName];
    NSString *bundlePath = [NSString stringWithFormat:@"%@.bundle", rscPath];
    return bundlePath;
}


- (NSString *)makeUpBundlePathWithSubDirName:(NSString *)subDirName bundleName:(NSString *)bundleName {
    NSString *folderPath = [[NSBundle mainBundle] pathForResource:@"MakeupResources" ofType:nil];
    NSString *rscPath = [folderPath stringByAppendingPathComponent:subDirName];
    rscPath = [rscPath stringByAppendingPathComponent:bundleName];
    NSString *bundlePath = [NSString stringWithFormat:@"%@.bundle", rscPath];
    return bundlePath;
}

- (NSString *)filterRscPathWithSubPath:(NSString *)subPath {
    NSString *folderPath = [[NSBundle mainBundle] pathForResource:@"ColorfulStyleResources" ofType:nil];
    NSString *rscPath = [folderPath stringByAppendingPathComponent:subPath];
    rscPath = [rscPath stringByAppendingString:@".bundle"];
    return rscPath;
}
 */

@end
