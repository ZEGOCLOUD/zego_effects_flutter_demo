//
//  ZegoEffectsCamera.m
//  zego_effects_plugin
//
//  Created by zego on 2021/6/18.
//

#import "ZegoEffectsCamera.h"
#import <objc/message.h>

@interface ZegoEffectsCamera()<AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _videoCaptureCallbackQueue;
    int frameID;
}

@property (nonatomic, strong) id customVideoCaptureManager;
@property (nonatomic, assign) SEL sendPixelBufferSelector;

@property (nonatomic, assign) BOOL isCaptured;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) AVCaptureSession *capSession;
@property (nonatomic, strong) AVCaptureInput *activateInput;
@property (nonatomic, assign) BOOL isFrontCamera;

@end

@implementation ZegoEffectsCamera

- (instancetype)init {
    if(self = [super init]) {
        _videoCaptureCallbackQueue = dispatch_queue_create("im.zego.zegoEffects.outputCallbackQueue", DISPATCH_QUEUE_SERIAL);
        _isFrontCamera = YES;
        frameID = 0;

        Class managerClass = NSClassFromString(@"ZegoCustomVideoCaptureManager");
        SEL managerSelector = NSSelectorFromString(@"sharedInstance");
        id sharedManager = ((id (*)(id, SEL))objc_msgSend)(managerClass, managerSelector);
        self.customVideoCaptureManager = sharedManager;

        self.sendPixelBufferSelector = NSSelectorFromString(@"sendCVPixelBuffer:timestamp:channel:");
    }

    return self;
}

#pragma mark- camera operation
- (BOOL)switchCamera:(AVCaptureDevicePosition)position {
    NSError * error;

    if(position == AVCaptureDevicePositionUnspecified)
        return NO;

    AVCaptureDevice * inActivityDevice = [self cameraWithPosition:position];
    if (!inActivityDevice)
        return NO;

    AVCaptureDeviceInput * deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inActivityDevice error:&error];
    if(!deviceInput) {
        return NO;
    }

    // when switch camera, remove activate then add next
    [self.capSession beginConfiguration];
    [self.capSession removeInput:self.activateInput];

    if ([self.capSession canAddInput:deviceInput]) {

        [self.capSession addInput:deviceInput];
        self.activateInput = deviceInput;
        if (deviceInput.device.position == AVCaptureDevicePositionFront) {
            self.isFrontCamera = YES;
        } else {
            self.isFrontCamera = NO;
        }

        AVCaptureVideoDataOutput *output = self.output;
        AVCaptureConnection *captureConnection = [output connectionWithMediaType:AVMediaTypeVideo];

        if (captureConnection.isVideoOrientationSupported) {
            captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        }

        if (deviceInput.device.position == AVCaptureDevicePositionFront) {
            captureConnection.videoMirrored = YES;
        } else {
            captureConnection.videoMirrored = NO;
        }
    } else {
        [self.capSession addInput:self.activateInput];
    }

    [self.capSession commitConfiguration];

    return YES;
}

- (void)setCameraFrameRate:(int)framerate {
    if (!self.input.device) {
        NSLog(@"Camera is not actived");
        return;
    }

    NSArray<AVFrameRateRange *> *ranges = self.input.device.activeFormat.videoSupportedFrameRateRanges;
    AVFrameRateRange *range = [ranges firstObject];

    if (!range) {
        NSLog(@"videoSupportedFrameRateRanges is empty");
        return;
    }

    if (framerate > range.maxFrameRate || framerate < range.minFrameRate) {
        NSLog(@"Unsupport framerate: %d, range is %.2f ~ %.2f", framerate, range.minFrameRate, range.maxFrameRate);
        return;
    }

    NSError *error = [[NSError alloc] init];
    if (![self.input.device lockForConfiguration:&error]) {
        NSLog(@"AVCaptureDevice lockForConfiguration failed. errCode:%ld, domain:%@", error.code, error.domain);
    }
    self.input.device.activeVideoMinFrameDuration = CMTimeMake(1, framerate);
    self.input.device.activeVideoMaxFrameDuration = CMTimeMake(1, framerate);
    [self.input.device unlockForConfiguration];

    NSLog(@"Set framerate to %d", framerate);
}

#pragma mark- lazy load
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {

    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

    for (AVCaptureDevice * device in devices) {

        if (device.position == position) {
            return device;
        }

    }

    return nil;
}

- (AVCaptureSession *)capSession {
    if (!_capSession) {
        _capSession = [[AVCaptureSession alloc] init];
    }
    return _capSession;
}

- (AVCaptureDeviceInput *)input {
    if (!_input) {
        NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];

        // Note: This demonstration selects the front camera. Developers should choose the appropriate camera device by themselves.
        NSArray *captureDeviceArray = [cameras filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"position == %d", AVCaptureDevicePositionFront]];
        if (captureDeviceArray.count == 0) {
            NSLog(@"Failed to get camera");
            return nil;
        }
        AVCaptureDevice *camera = captureDeviceArray.firstObject;

        NSError *error = nil;
        AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
        if (error) {
            NSLog(@"Conversion of AVCaptureDevice to AVCaptureDeviceInput failed");
            return nil;
        }
        _input = captureDeviceInput;
    }
    return _input;
}

- (AVCaptureVideoDataOutput *)output {
    if (!_output) {
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
        [videoDataOutput setSampleBufferDelegate:self queue:_videoCaptureCallbackQueue];
        _output = videoDataOutput;
    }
    return _output;
}

#pragma mark ZegoCustomVideoCaptureDelegate
- (void)onStart:(int)channel {
    self.isCaptured = YES;

    [self.capSession beginConfiguration];

    if ([self.capSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [self.capSession setSessionPreset:AVCaptureSessionPresetHigh];
    }

    AVCaptureDeviceInput *input = self.input;

    if ([self.capSession canAddInput:input]) {
        [self.capSession addInput:input];

        self.activateInput = input;

        if (input.device.position == AVCaptureDevicePositionFront) {
            self.isFrontCamera = YES;
        } else {
            self.isFrontCamera = NO;
        }

        // 相机帧率默认值为30
        [self setCameraFrameRate:30];

    }

    AVCaptureVideoDataOutput *output = self.output;

    if ([self.capSession canAddOutput:output]) {
        [self.capSession addOutput:output];
    }

    AVCaptureConnection *captureConnection = [output connectionWithMediaType:AVMediaTypeVideo];

    if (captureConnection.isVideoOrientationSupported) {
        captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }

    if (input.device.position == AVCaptureDevicePositionFront) {
        captureConnection.videoMirrored = YES;
    } else {
        captureConnection.videoMirrored = NO;
    }

    [self.capSession commitConfiguration];

    if (!self.capSession.isRunning) {
        [self.capSession startRunning];
    }
}

- (void)onStop:(int)channel {

    if (self.capSession.isRunning) {
        [self.capSession stopRunning];
    }

    self.isCaptured = NO;
}

- (CVPixelBufferRef)copyBufferRefFromCVPixelBuffer: (CVPixelBufferRef)buffer bufferFormatType: (OSType)type {
    switch (type) {
        case kCVPixelFormatType_32BGRA:
            return [self RGBBuffereCopyWithPixelBuffer:buffer];
            break;
        // iOS need NV12 type
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            return [self YUVBufferCopyWithPixelBuffer:buffer];
            break;
        default:
            return nil;
    }
}

- (CVPixelBufferRef)RGBBuffereCopyWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
{

    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    OSType pixelFormat = kCVPixelFormatType_32BGRA;

    CVPixelBufferRef pixelBufferCopy = NULL;
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, pixelFormat, (__bridge CFDictionaryRef) options, &pixelBufferCopy);
    if (status == kCVReturnSuccess) {
        CVPixelBufferLockBaseAddress(pixelBufferCopy, 0);
        uint8_t *copyBaseAddress = CVPixelBufferGetBaseAddress(pixelBufferCopy);
        memcpy(copyBaseAddress, baseAddress, bufferHeight * bytesPerRow);
    }else {
        NSLog(@"RBGBuffereCopyWithPixelBuffer :: failed");
    }

    CVPixelBufferUnlockBaseAddress(pixelBufferCopy, 0);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    return pixelBufferCopy;
}

- (CVPixelBufferRef)YUVBufferCopyWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    // Get pixel buffer info
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    OSType pixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;

    // Copy the pixel buffer
    CVPixelBufferRef pixelBufferCopy = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, pixelFormat, NULL, &pixelBufferCopy);
    if (status != kCVReturnSuccess) {
        NSLog(@"YUVBufferCopyWithPixelBuffer :: failed");
    }

    CVPixelBufferLockBaseAddress(pixelBufferCopy, 0);

    uint8_t *yDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBufferCopy, 0);
    //YUV
    uint8_t *yPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memcpy(yDestPlane, yPlane, bufferWidth * bufferHeight);
    uint8_t *uvDestPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBufferCopy, 1);
    uint8_t *uvPlane = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
    memcpy(uvDestPlane, uvPlane, bufferWidth * bufferHeight/2);
    CVPixelBufferUnlockBaseAddress(pixelBufferCopy, 0);

    return pixelBufferCopy;
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(buffer);

    // 切换了前后摄像头之后，可能会有几帧延迟，此时摄像头状态和实际出帧标记会有不一致的情况，丢弃这几帧
    if((self.isFrontCamera && connection.videoMirrored == NO) || (!self.isFrontCamera && connection.videoMirrored)) {
        return;
    }

    [self.effects processImageBuffer:buffer];
    CVPixelBufferRef tmp = [self copyBufferRefFromCVPixelBuffer:buffer bufferFormatType:format];
    frameID += 1;
    if(self.isCaptured) {

        ((void (*)(id, SEL, CVPixelBufferRef, CMTime, int))objc_msgSend)(self.customVideoCaptureManager, self.sendPixelBufferSelector, tmp, timeStamp, 0);
        CVPixelBufferRelease(tmp);
    }
}

@end
