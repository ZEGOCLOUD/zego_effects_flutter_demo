package im.zego.zego_effects_plugin;

import android.content.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;
import im.zego.effects.ZegoEffects;
import im.zego.effects.entity.ZegoEffectsFaceDetectionResult;
import im.zego.effects.enums.ZegoEffectsScaleMode;
import im.zego.zego_effects_plugin.utils.LogUtil;
import im.zego.zegoexpress.ZegoExpressEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ZegoEffectsPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler,
                                          EventChannel.StreamHandler
{

    private MethodChannel channel;
    private Context mContext;
    private EventChannel mEventChannel;
    private EventChannel.EventSink mEventSink;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "zego_effects_plugin");
        mContext = binding.getApplicationContext();
        channel.setMethodCallHandler(this);

        mEventChannel = new EventChannel(binding.getBinaryMessenger(), "plugins.zego.im/zegoeffects_callback");
        mEventChannel.setStreamHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        LogUtil.e("onMethodCall", call.method);
        Map<String, Object> arg = null;

        try {
            if (call.arguments != null) {
                arg = (Map<String, Object>) call.arguments;
            }

            switch (call.method) {
                case "getPlatformVersion":
                    result.success("Android ${android.os.Build.VERSION.RELEASE}");
                    break;
                case "getVersion":
                    // get SDK Version
                    result.success(ZegoEffects.getVersion());
                    break;

                case "getAuthInfo":
                    if (arg != null && arg.get("appSign") != null) {
                        String appSign = (String) arg.get("appSign");
                        result.success(ZGEffectsHelper.getInstance().getAuthInfo(mContext, appSign));
                    } else{
                        result.success(null);
                    }
                    break;

                case "setResources":
                    ZGEffectsHelper.getInstance().setResources(mContext);
                    break;

                case "startWithCustomCaptureSource":
                    //start custom capture
                    ZGEffectsHelper.getInstance().startWithCustomCaptureSource(mContext);
                    result.success(null);
                    break;

                case "stopEffects":
                    //stop custom capture
                    ZGEffectsHelper.getInstance().stopCapture();
                    result.success(null);
                    break;

                case "switchCamera":
                    // switch camera
                    if (arg != null && arg.get("position") != null) {
                        int position = (int) arg.get("position");
                        ZGEffectsHelper.getInstance().switchCamera(position);
                    }

                    result.success(null);
                    break;

                case "setCameraFrameRate":
                    // set custom capture camera frame rate
                    if (arg != null && arg.get("fps") != null) {
                        int fps = (int) arg.get("fps");
                        ZGEffectsHelper.getInstance().setFrameRate(fps);
                    }

                    result.success(null);
                    break;

                case "create":
                    //create Zego Effects SDK
                    //0, init success, else init failed
                    if (arg != null && arg.get("license") != null) {
                        String license = (String) arg.get("license");
                        LogUtil.e("effectsLicense", license);
                        ZGEffectsHelper.getInstance().create(license, mContext);

                        result.success(0);
                    } else {
                        result.success(-1);
                    }
                    break;

                case "destroy":
                    //destroy Zego Effects SDK
                    ZGEffectsHelper.getInstance().destroyEffects();
                    result.success(null);
                    break;

                case "setPendant":
                    //set custom pendant through local path
                    //if path is null, SDK will remove pendant
                    if (arg != null && arg.get("pendantName") != null) {
                        String pendantName = (String) arg.get("pendantName");
                        ZGEffectsHelper.getInstance().setPendant(mContext, pendantName);
                    }
                    result.success(null);
                    break;

                case "setFilter":
                    //set custom pendant through local path
                    //if path is null, SDK will remove pendant
                    if (arg != null && arg.get("filterName") != null) {
                        String filterName = (String) arg.get("filterName");
                        ZGEffectsHelper.getInstance().setFilter(mContext, filterName);
                    }
                    result.success(null);
                    break;

                case "initEnv":
                    //init Zego Effects environment with a resolution you expect
                    //0, init success, else init failed
                    if (arg != null && arg.get("width") != null && arg.get("height") != null){
                        double width = (double) arg.get("width");
                        double height = (double) arg.get("height");
                        ZGEffectsHelper.getInstance().initEnv(width, height);

                        result.success(0);
                    } else {
                        result.success(-1);
                    }
                    break;

                case "uninitEnv":
                    //uninit Zego Effects environment
                    ZGEffectsHelper.getInstance().uninitEnv();
                    result.success(null);
                    break;

                case "enablePortraitSegmentation":
                    //enable portrait segmentation
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enablePortraitSegmentation(enable);
                    }
                    result.success(null);
                    break;

                case "enablePortraitSegmentationBackgroundMosaic":
                    //enable portrait segmentation with mosaic background
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enablePortraitSegmentationBackgroundMosaic(enable);
                    }
                    result.success(null);
                    break;

                case "setPortraitSegmentationBackgroundMosaicParam":
                    //set param for mosaic background
                    if (arg != null && arg.get("intensity") != null && arg.get("type") != null) {
                        int intensity = (int) arg.get("intensity");
                        int type = (int) arg.get("type");

                        ZGEffectsHelper.getInstance().setPortraitSegmentationBackgroundMosaicParam(intensity, type);
                    }
                    result.success(null);
                    break;

                case "enablePortraitSegmentationBackground":
                    //enable portrait segmentation background
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enablePortraitSegmentationBackground(enable);
                    }
                    result.success(null);
                    break;

                case "enablePortraitSegmentationBackgroundBlur":
                    //enable portrait segmentation with blur background
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enablePortraitSegmentationBackgroundBlur(enable);
                    }
                    result.success(null);
                    break;

                case "setPortraitSegmentationBackgroundBlurParam":
                    //set blur background parameters for portrait segmentation
                    if (arg != null && arg.get("intensity") != null) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setPortraitSegmentationBackgroundBlurParam(intensity);
                    }
                    result.success(null);
                    break;

                case "setPortraitSegmentationBackgroundPath":
                    //set custom background image with path
                    if (arg != null && arg.get("path") != null && arg.get("mode") != null) {
                        String path = (String) arg.get("path");
                        ZegoEffectsScaleMode mode = (ZegoEffectsScaleMode) arg.get("mode");

                        ZGEffectsHelper.getInstance().setPortraitSegmentationBackgroundPath(path, mode);
                    }
                    result.success(null);
                    break;

                case "setPortraitSegmentationForegroundPosition":
                    //set portrait segmentation foreground postion
                    if (arg != null && arg.get("x") != null && arg.get("y") != null
                            && arg.get("width") != null && arg.get("height") != null) {

                        int x = (int) arg.get("x");
                        int y = (int) arg.get("y");
                        int width = (int) arg.get("width");
                        int height = (int) arg.get("height");

                        ZGEffectsHelper.getInstance().setPortraitSegmentationForegroundPosition(x, y, width, height);
                    }
                    result.success(null);
                    break;

                case "enableFaceDetection":
                    //enable face detection function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableFaceDetection(enable);
                    }
                    result.success(null);
                    break;

                case "enableFaceLifting":
                    //enable face lifting function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableFaceLifting(enable);
                    }
                    result.success(null);
                    break;

                case "setFaceLiftingParam":
                    //set face lifting parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setFaceLiftingParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableWhiten":
                    //enable skin whiten function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableWhiten(enable);
                    }
                    result.success(null);
                    break;

                case "setWhitenParam":
                    //set skin whiten parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setWhitenParam(intensity);
                    }
                    result.success(null);
                    break;

                case "setFilterParam":
                    //set skin whiten parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setFilterParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableSmooth":
                    //enable skin smooth function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableSmooth(enable);
                    }
                    result.success(null);
                    break;

                case "setSmoothParam":
                    //set skin smooth parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setSmoothParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableSmallMouth":
                    //enable small mouth function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableSmallMouth(enable);
                    }
                    result.success(null);
                    break;

                case "setSmallMouthParam":
                    //set small mouth parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setSmallMouthParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableLongChin":
                    //enable long chin function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableLongChin(enable);
                    }
                    result.success(null);
                    break;

                case "setLongChinParam":
                    //set long chin parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setLongChinParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableNoseNarrowing":
                    //enable nose narrowing function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableNoseNarrowing(enable);
                    }
                    result.success(null);
                    break;

                case "setNoseNarrowingParam":
                    //set nose narrowing parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setNoseNarrowingParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableTeethWhitening":
                    //enable teeth whitening function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableTeethWhitening(enable);
                    }
                    result.success(null);
                    break;

                case "setTeethWhiteningParam":
                    //set teeth whitening parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setTeethWhiteningParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableEyesBrightening":
                    //enable eyes brightening function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableEyesBrightening(enable);
                    }
                    result.success(null);
                    break;

                case "setEyesBrighteningParam":
                    //set eyes brightening parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setEyesBrighteningParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableSharpen":
                    //enable sharpen function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableSharpen(enable);
                    }
                    result.success(null);
                    break;

                case "setSharpenParam":
                    //set sharpen parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setSharpenParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableRosy":
                    //enable rosy function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableRosy(enable);
                    }
                    result.success(null);
                    break;

                case "setRosyParam":
                    //set rosy parameters
                    if (arg != null && arg.get("intensity") != null ) {
                        int intensity = (int) arg.get("intensity");
                        ZGEffectsHelper.getInstance().setRosyParam(intensity);
                    }
                    result.success(null);
                    break;

                case "enableChromaKey":
                    //enable chroma key function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableChromaKey(enable);
                    }
                    result.success(null);
                    break;

                case "enableChromaKeyBackground":
                    //enable chroma key background function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableChromaKeyBackground(enable);
                    }
                    result.success(null);
                    break;

                case "enableChromaKeyBackgroundMosaic":
                    //enable chroma key background mosaic function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableChromaKeyBackgroundMosaic(enable);
                    }
                    result.success(null);
                    break;

                case "setChromaKeyParam":
                    //set chroma key parameters
                    if (arg != null && arg.get("similarity") != null && arg.get("borderSize") != null
                            && arg.get("keyColor") != null && arg.get("opacity") != null
                            && arg.get("smoothness") != null) {

                        float similarity = (float) arg.get("similarity");
                        float smoothness = (float) arg.get("smoothness");
                        int borderSize = (int) arg.get("borderSize");
                        int keyColor = (int) arg.get("keyColor");
                        int opacity = (int) arg.get("opacity");

                        ZGEffectsHelper.getInstance().setChromaKeyParam(similarity, smoothness, borderSize, keyColor, opacity);
                    }
                    result.success(null);
                    break;

                case "setChromaKeyBackgroundMosaicParam":
                    //set chroma key background mosaic parameters
                    if (arg != null && arg.get("intensity") != null && arg.get("type") != null) {

                        int intensity = (int) arg.get("intensity");
                        int type = (int) arg.get("type");

                        ZGEffectsHelper.getInstance().setChromaKeyBackgroundMosaicParam(intensity, type);
                    }
                    result.success(null);
                    break;

                case "enableChromaKeyBackgroundBlur":
                    //enable chroma key background blur function
                    if (arg != null && arg.get("enable") != null) {
                        boolean enable = (boolean) arg.get("enable");
                        ZGEffectsHelper.getInstance().enableChromaKeyBackgroundBlur(enable);
                    }
                    result.success(null);
                    break;

                case "setChromaKeyBackgroundBlurParam":
                    //set chroma key background blur parameters
                    if (arg != null && arg.get("intensity") != null ) {

                        int intensity = (int) arg.get("intensity");

                        ZGEffectsHelper.getInstance().setChromaKeyBackgroundBlurParam(intensity);
                    }
                    result.success(null);
                    break;

                case "setChromaKeyBackgroundPath":
                    // set chroma key background custom path
                    if (arg != null && arg.get("imagePath") != null && arg.get("mode") != null) {
                        String imagePath = (String) arg.get("imagePath");
                        ZegoEffectsScaleMode mode = (ZegoEffectsScaleMode) arg.get("mode");
                        ZGEffectsHelper.getInstance().setChromaKeyBackgroundPath(imagePath, mode);
                    }
                    break;

                case "setChromaKeyForegroundPosition":
                    //set chroma key foreground postion
                    if (arg != null && arg.get("x") != null && arg.get("y") != null
                            && arg.get("width") != null && arg.get("height") != null) {

                        int x = (int) arg.get("x");
                        int y = (int) arg.get("y");
                        int width = (int) arg.get("width");
                        int height = (int) arg.get("height");

                        ZGEffectsHelper.getInstance().setChromaKeyForegroundPosition(x, y, width, height);
                    }
                    result.success(null);
                    break;

                case "registerEventCallback":

                    ZGEffectsHelper.getInstance().setOnEventHandler(new ZGEffectsHelper.OnEventHandler() {
                        @Override
                        public void onError(ZegoEffects zegoEffects, int errorCode, String desc)
                        {
                            Map<String, Object> event = new HashMap<>();
                            event.put("name", "onEffectsError");
                            event.put("errorCode", errorCode);
                            event.put("desc", desc);
                            mEventSink.success(event);
                        }

                        @Override
                        public void onFaceDetectionResult(ZegoEffectsFaceDetectionResult[] results,
                                                          ZegoEffects zegoEffects)
                        {
                            if (results.length == 0) {
                                return;
                            }

                            for (ZegoEffectsFaceDetectionResult result : results) {
                                Map<String, Object> event = new HashMap<>();
                                event.put("name", "onEffectsFaceDetected");
                                event.put("score", result.score);
                                event.put("x", result.rect.x);
                                event.put("y", result.rect.y);
                                event.put("width", result.rect.width);
                                event.put("height", result.rect.height);
                                mEventSink.success(event);
                            }

                        }
                    });
                    break;

                case "destroyEventCallback":
                    mEventSink.endOfStream();
                    result.success(null);
                    break;

                default:
                    result.notImplemented();
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        mEventSink = null;
        channel.setMethodCallHandler(null);
        mEventChannel.setStreamHandler(null);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        mEventSink = null;
    }
}
