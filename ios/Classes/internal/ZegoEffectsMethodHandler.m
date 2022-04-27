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

- (void)setModels:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray<NSString *> *bundleNames = call.arguments[@"modelNames"];
    if (self.effects) {
        return;
    }
    
    NSMutableArray<NSString *> *bundlePaths = [NSMutableArray array];
    for (NSString *name in bundleNames) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
        if (bundlePath) {
            [bundlePaths addObject:bundlePath];
        }else {
            continue;
        }
    }
    if (bundlePaths.count > 0) {
        [ZegoEffects setModels:bundlePaths];
    }
}

- (void)setResources:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSArray<NSString *> *bundleNames = call.arguments[@"resourceNames"];
    if (self.effects) {
        return;
    }
    
    NSMutableArray<NSString *> *bundlePaths = [NSMutableArray array];
    for (NSString *name in bundleNames) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:name ofType:@"bundle"];
        if (bundlePath) {
            [bundlePaths addObject:bundlePath];
        }else {
            continue;
        }
    }
    if (bundlePaths.count > 0) {
        [ZegoEffects setResources:bundlePaths];
    }
}

- (void)setPendant:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *bundleName = call.arguments[@"pendantName"];
    if (!self.effects) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
        [self.effects setPendant:bundlePath];
    });
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

#pragma mark - Face Lifting
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

#pragma mark - Whiten
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

#pragma mark - Smooth
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

#pragma mark - Big Eyes
- (void)enableBigEyes:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableSmooth:enable];
    result(nil);
}

- (void)setBigEyesParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsBigEyesParam *param = [[ZegoEffectsBigEyesParam alloc] init];
    param.intensity = intensity;
    [self.effects setBigEyesParam:param];
    
    result(nil);
}

#pragma mark - Small Mouth
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

#pragma mark - Long Chin
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

#pragma mark - Nose Narrowing
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

#pragma mark - Teeth Whitening
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

#pragma mark - Eye Brightening
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

#pragma mark - Sharpen
- (void)enableSharpen:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL enable = [call.arguments[@"enable"] boolValue];
    [self.effects enableSharpen:enable];
    result(nil);
}

- (void)setSharpenParam:(FlutterMethodCall *)call result:(FlutterResult)result {
    int intensity = [call.arguments[@"intensity"] intValue];
    ZegoEffectsSmoothParam *param = [[ZegoEffectsSmoothParam alloc] init];
    param.intensity = intensity;
    [self.effects setSmoothParam:param];
    
    result(nil);
}

#pragma mark - Rosy
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

#pragma mark - Chroma Key
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


@end
