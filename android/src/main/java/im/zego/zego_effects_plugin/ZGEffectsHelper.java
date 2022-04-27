package im.zego.zego_effects_plugin;

import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Log;

import java.io.File;
import java.util.ArrayList;

import im.zego.effects.ZegoEffects;
import im.zego.effects.callback.ZegoEffectsEventHandler;
import im.zego.effects.entity.ZegoEffectsBlurParam;
import im.zego.effects.entity.ZegoEffectsChromaKeyParam;
import im.zego.effects.entity.ZegoEffectsEyesBrighteningParam;
import im.zego.effects.entity.ZegoEffectsFaceDetectionResult;
import im.zego.effects.entity.ZegoEffectsFaceLiftingParam;
import im.zego.effects.entity.ZegoEffectsFilterParam;
import im.zego.effects.entity.ZegoEffectsLongChinParam;
import im.zego.effects.entity.ZegoEffectsMosaicParam;
import im.zego.effects.entity.ZegoEffectsNoseNarrowingParam;
import im.zego.effects.entity.ZegoEffectsRect;
import im.zego.effects.entity.ZegoEffectsRosyParam;
import im.zego.effects.entity.ZegoEffectsSharpenParam;
import im.zego.effects.entity.ZegoEffectsSmallMouthParam;
import im.zego.effects.entity.ZegoEffectsSmoothParam;
import im.zego.effects.entity.ZegoEffectsTeethWhiteningParam;
import im.zego.effects.entity.ZegoEffectsWhitenParam;
import im.zego.effects.enums.ZegoEffectsMosaicType;
import im.zego.effects.enums.ZegoEffectsScaleMode;
import im.zego.zego_effects_plugin.capture.VideoCaptureFromCamera2;
import im.zego.zego_effects_plugin.utils.FileUtil;
import im.zego.zego_effects_plugin.utils.LogUtil;
import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;

public class ZGEffectsHelper {

    private static final String TAG = "ZGEffectsHelper";

    private volatile static ZGEffectsHelper mInstance;
    public ZegoEffects mZegoEffects;
    private OnEventHandler mOnEventHandler;
    private VideoCaptureFromCamera2 mVideoCaptureFromCamera2;
    private int mEffectWidth;
    private int mEffectHeight;

    static ZGEffectsHelper getInstance(){
        if (mInstance == null) {
            synchronized (ZGEffectsHelper.class) {
                if (mInstance == null) {
                    mInstance = new ZGEffectsHelper();
                }
            }
        }

        return mInstance;
    }

    String getAuthInfo(Context context,String appsign){
        String authInfo = ZegoEffects.getAuthInfo(appsign,context);
        Log.d(TAG, "getAuthInfo: " + authInfo);
        return authInfo;
    }


    void setResources(Context context){
        ArrayList<String> aiModeInfoList = copyAiModeInfoList(context);
        ArrayList<String> resourcesInfoList = copyResourcesInfoList(context);
        aiModeInfoList.addAll(resourcesInfoList);
        Log.d(TAG, "setModels: size = " + resourcesInfoList.size());
        ZegoEffects.setResources(aiModeInfoList);
    }

    private ArrayList<String> copyAiModeInfoList(Context context)
    {
        String path = context.getExternalCacheDir().getPath();
        String faceDetection = "Models/FaceDetectionModel.model";
        String segmentation = "Models/SegmentationModel.model";
        FileUtil.copyFileFromAssets(context,faceDetection , path + File.separator + faceDetection);
        FileUtil.copyFileFromAssets(context, segmentation, path + File.separator + segmentation );
        ArrayList<String> aiModeInfoList = new ArrayList<>();
        aiModeInfoList.add(path + File.separator + faceDetection);
        aiModeInfoList.add(path + File.separator + segmentation);

        return aiModeInfoList;
    }

    private ArrayList<String> copyResourcesInfoList(Context context)
    {
        String path = context.getExternalCacheDir().getPath();
        String faceWhitening = "Resources/FaceWhiteningResources.bundle";
        String pendantResources = "Resources/PendantResources.bundle";
        String rosyResources = "Resources/RosyResources.bundle";
        String teethWhiteningResources = "Resources/TeethWhiteningResources.bundle";
        String commonResources = "Resources/CommonResources.bundle";

        FileUtil.copyFileFromAssets(context,faceWhitening , path + File.separator + faceWhitening);
        FileUtil.copyFileFromAssets(context,pendantResources , path + File.separator + pendantResources);
        FileUtil.copyFileFromAssets(context,rosyResources , path + File.separator + rosyResources);
        FileUtil.copyFileFromAssets(context, teethWhiteningResources, path + File.separator + teethWhiteningResources );
        FileUtil.copyFileFromAssets(context, commonResources, path + File.separator + commonResources );

        ArrayList<String> resourcesInfoList = new ArrayList<>();
        resourcesInfoList.add(path + File.separator + faceWhitening);
        resourcesInfoList.add(path + File.separator + pendantResources);
        resourcesInfoList.add(path + File.separator + rosyResources);
        resourcesInfoList.add(path + File.separator + teethWhiteningResources);
        resourcesInfoList.add(path + File.separator + commonResources);

        return resourcesInfoList;
    }



    //create effects engine
    void create(String license, Context context){
        mZegoEffects = ZegoEffects.create(license, context);

        mZegoEffects.setEventHandler(new ZegoEffectsEventHandler() {
            @Override
            public void onError(ZegoEffects zegoEffects, int errorCode, String desc)
            {
                LogUtil.e("onError", "errorCode:" + errorCode + "; desc:" + desc);
                if (mOnEventHandler != null) {
                    mOnEventHandler.onError(zegoEffects, errorCode, desc);
                }
                super.onError(zegoEffects, errorCode, desc);
            }

            @Override
            public void onFaceDetectionResult(ZegoEffectsFaceDetectionResult[] results,
                                              ZegoEffects zegoEffects)
            {
                if (mOnEventHandler != null) {
                    mOnEventHandler.onFaceDetectionResult(results, zegoEffects);
                }
                super.onFaceDetectionResult(results, zegoEffects);
            }
        });
    }

    //init effects env
    void initEnv(double width, double height){
        if (mZegoEffects != null) {
            LogUtil.e("initEnv", "width:" + width + "|| height:" + height);
            mEffectWidth = (int) width;
            mEffectHeight = (int) height;

        }
    }

    //start capture
    void startWithCustomCaptureSource(Context context){
        if (mEffectWidth == 0 && mEffectHeight == 0) {
            DisplayMetrics dm = context.getResources().getDisplayMetrics();
            mEffectWidth = dm.widthPixels;
            mEffectHeight = dm.heightPixels;
        }

        mVideoCaptureFromCamera2 = new VideoCaptureFromCamera2(mZegoEffects, mEffectWidth, mEffectHeight);
        ZegoCustomVideoCaptureManager.getInstance().setCustomVideoCaptureHandler(
                mVideoCaptureFromCamera2);
    }

    //stop capture
    void stopCapture(){
        if (mVideoCaptureFromCamera2 != null) {
            mVideoCaptureFromCamera2 = null;
        }
    }

    //switch camera
    void switchCamera(int position){
        if (mVideoCaptureFromCamera2 != null) {
            mVideoCaptureFromCamera2.setFrontCam(position);
        }
    }

    void setFrameRate(int frameRate){
        if (mVideoCaptureFromCamera2 != null) {
            mVideoCaptureFromCamera2.setFrameRate(frameRate);
        }
    }

    //uninit effects env
    void uninitEnv(){
        if (mZegoEffects != null) {
            mZegoEffects.uninitEnv();
        }
    }

    //set effects pendant
    void setPendant(Context context, String pendantName){
        if (mZegoEffects != null) {
            String path = context.getExternalCacheDir().getPath();
            String bundle = "Pendants/" + pendantName + ".bundle";
            LogUtil.e("setPendant", bundle);
            String modelPath = path + File.separator + bundle;
            FileUtil.copyFileFromAssets(context, bundle, modelPath);
            mZegoEffects.setPendant(modelPath);
        }
    }

    //set effects pendant
    void setFilter(Context context, String filterName){
        Log.d(TAG, "setFilter: " + filterName);
        if (mZegoEffects != null) {
            String path = context.getExternalCacheDir().getPath();
            String bundle = "Resources/ColorfulStyleResources/" + filterName + ".bundle";
            LogUtil.e("setFilter", bundle);
            String modelPath = path + File.separator + bundle;
            Log.d(TAG, "setFilter: path = " + modelPath);
            FileUtil.copyFileFromAssets(context, bundle, modelPath);
            mZegoEffects.setFilter(modelPath);
        }
    }

    //set effects filter param
    void setFilterParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsFilterParam param = new ZegoEffectsFilterParam();
            param.intensity = intensity;
            mZegoEffects.setFilterParam(param);
        }
    }

    void enablePortraitSegmentation(boolean enable){
        if (mZegoEffects != null) {
            mZegoEffects.enablePortraitSegmentation(enable);
        }
    }

    void enablePortraitSegmentationBackground(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enablePortraitSegmentationBackground(enable);
        }
    }

    void enablePortraitSegmentationBackgroundBlur(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enablePortraitSegmentationBackgroundBlur(enable);
        }
    }

    void enablePortraitSegmentationBackgroundMosaic(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enablePortraitSegmentationBackgroundMosaic(enable);
        }
    }

    void enableFaceDetection(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableFaceDetection(enable);
        }
    }

    void enableFaceLifting(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableFaceDetection(enable);
        }
    }

    void enableWhiten(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableWhiten(enable);
        }
    }

    void enableSmooth(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableSmooth(enable);
        }
    }

    void enableSmallMouth(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableSmallMouth(enable);
        }
    }

    void enableLongChin(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableLongChin(enable);
        }
    }

    void enableNoseNarrowing(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableNoseNarrowing(enable);
        }
    }

    void enableTeethWhitening(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableTeethWhitening(enable);
        }
    }

    void enableEyesBrightening(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableEyesBrightening(enable);
        }
    }

    void enableSharpen(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableSharpen(enable);
        }
    }

    void enableRosy(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableRosy(enable);
        }
    }

    void enableChromaKey(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableChromaKey(enable);
        }
    }

    void enableChromaKeyBackground(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableChromaKeyBackground(enable);
        }
    }

    void enableChromaKeyBackgroundMosaic(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableChromaKeyBackgroundMosaic(enable);
        }
    }

    void enableChromaKeyBackgroundBlur(boolean enable) {
        if (mZegoEffects != null) {
            mZegoEffects.enableChromaKeyBackgroundBlur(enable);
        }
    }

    //设置人像分割背景马赛克类型
    void setPortraitSegmentationBackgroundMosaicParam(int intensity, int type){
        if (mZegoEffects != null) {
            ZegoEffectsMosaicParam zegoEffectsMosaicParam = new ZegoEffectsMosaicParam();
            zegoEffectsMosaicParam.setIntensity(intensity);
            zegoEffectsMosaicParam.type = ZegoEffectsMosaicType.getZegoEffectsMosaicType(type);

            mZegoEffects.setPortraitSegmentationBackgroundMosaicParam(zegoEffectsMosaicParam);
        }
    }

    void setChromaKeyBackgroundMosaicParam(int intensity, int type){
        if (mZegoEffects != null) {
            ZegoEffectsMosaicParam zegoEffectsMosaicParam = new ZegoEffectsMosaicParam();
            zegoEffectsMosaicParam.setIntensity(intensity);
            zegoEffectsMosaicParam.type = ZegoEffectsMosaicType.getZegoEffectsMosaicType(type);
            mZegoEffects.setChromaKeyBackgroundMosaicParam(zegoEffectsMosaicParam);
        }
    }

    //设置人像分割背景马赛克类型
    void setPortraitSegmentationBackgroundBlurParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsBlurParam zegoEffectsBlurParam = new ZegoEffectsBlurParam();
            zegoEffectsBlurParam.setIntensity(intensity);
            mZegoEffects.setPortraitSegmentationBackgroundBlurParam(zegoEffectsBlurParam);
        }
    }

    void setChromaKeyBackgroundBlurParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsBlurParam zegoEffectsBlurParam = new ZegoEffectsBlurParam();
            zegoEffectsBlurParam.setIntensity(intensity);
            mZegoEffects.setChromaKeyBackgroundBlurParam(zegoEffectsBlurParam);
        }
    }

    void setRosyParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsRosyParam zegoEffectsRosyParam = new ZegoEffectsRosyParam();
            zegoEffectsRosyParam.setIntensity(intensity);
            mZegoEffects.setRosyParam(zegoEffectsRosyParam);
        }
    }

    void setSharpenParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsSharpenParam zegoEffectsSharpenParam = new ZegoEffectsSharpenParam();
            zegoEffectsSharpenParam.setIntensity(intensity);
            mZegoEffects.setSharpenParam(zegoEffectsSharpenParam);
        }
    }

    void setEyesBrighteningParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsEyesBrighteningParam zegoEffectsEyesBrighteningParam = new ZegoEffectsEyesBrighteningParam();
            zegoEffectsEyesBrighteningParam.setIntensity(intensity);
            mZegoEffects.setEyesBrighteningParam(zegoEffectsEyesBrighteningParam);
        }
    }

    void setTeethWhiteningParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsTeethWhiteningParam zegoEffectsTeethWhiteningParam = new ZegoEffectsTeethWhiteningParam();
            zegoEffectsTeethWhiteningParam.setIntensity(intensity);
            mZegoEffects.setTeethWhiteningParam(zegoEffectsTeethWhiteningParam);
        }
    }

    void setNoseNarrowingParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsNoseNarrowingParam zegoEffectsNoseNarrowingParam = new ZegoEffectsNoseNarrowingParam();
            zegoEffectsNoseNarrowingParam.setIntensity(intensity);
            mZegoEffects.setNoseNarrowingParam(zegoEffectsNoseNarrowingParam);
        }
    }

    void setLongChinParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsLongChinParam zegoEffectsLongChinParam = new ZegoEffectsLongChinParam();
            zegoEffectsLongChinParam.setIntensity(intensity);
            mZegoEffects.setLongChinParam(zegoEffectsLongChinParam);
        }
    }

    void setSmallMouthParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsSmallMouthParam zegoEffectsSmallMouthParam = new ZegoEffectsSmallMouthParam();
            zegoEffectsSmallMouthParam.setIntensity(intensity);
            mZegoEffects.setSmallMouthParam(zegoEffectsSmallMouthParam);
        }
    }

    void setSmoothParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsSmoothParam zegoEffectsSmoothParam = new ZegoEffectsSmoothParam();
            zegoEffectsSmoothParam.setIntensity(intensity);
            mZegoEffects.setSmoothParam(zegoEffectsSmoothParam);
        }
    }

    void setWhitenParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsWhitenParam zegoEffectsWhitenParam = new ZegoEffectsWhitenParam();
            zegoEffectsWhitenParam.setIntensity(intensity);
            mZegoEffects.setWhitenParam(zegoEffectsWhitenParam);
        }
    }

    void setFaceLiftingParam(int intensity){
        if (mZegoEffects != null) {
            ZegoEffectsFaceLiftingParam zegoEffectsFaceLiftingParam = new ZegoEffectsFaceLiftingParam();
            zegoEffectsFaceLiftingParam.setIntensity(intensity);
            mZegoEffects.setFaceLiftingParam(zegoEffectsFaceLiftingParam);
        }
    }

    void setPortraitSegmentationBackgroundPath(String path, ZegoEffectsScaleMode mode){
        if (mZegoEffects != null) {
            mZegoEffects.setPortraitSegmentationBackgroundPath(path, mode);
        }

    }

    void setChromaKeyParam(float similarity, float smoothness, int borderSize, int keyColor, int opacity){
        if (mZegoEffects != null) {
            ZegoEffectsChromaKeyParam zegoEffectsChromaKeyParam = new ZegoEffectsChromaKeyParam();
            zegoEffectsChromaKeyParam.setSimilarity(similarity);
            zegoEffectsChromaKeyParam.setBorderSize(borderSize);
            zegoEffectsChromaKeyParam.setKeyColor(keyColor);
            zegoEffectsChromaKeyParam.setOpacity(opacity);
            zegoEffectsChromaKeyParam.setSmoothness(smoothness);
            mZegoEffects.setChromaKeyParam(zegoEffectsChromaKeyParam);
        }

    }

    void setChromaKeyBackgroundPath(String imagePath, ZegoEffectsScaleMode mode){
        if (mZegoEffects != null) {
            mZegoEffects.setChromaKeyBackgroundPath(imagePath, mode);
        }
    }

    void setPortraitSegmentationForegroundPosition(int x, int y, int width, int height){
        if (mZegoEffects != null) {
            ZegoEffectsRect zegoEffectsRect = new ZegoEffectsRect();
            zegoEffectsRect.setX(x);
            zegoEffectsRect.setY(y);
            zegoEffectsRect.setWidth(width);
            zegoEffectsRect.setHeight(height);

            mZegoEffects.setPortraitSegmentationForegroundPosition(zegoEffectsRect);
        }

    }

    void setChromaKeyForegroundPosition(int x, int y, int width, int height){
        if (mZegoEffects != null) {
            ZegoEffectsRect zegoEffectsRect = new ZegoEffectsRect();
            zegoEffectsRect.setX(x);
            zegoEffectsRect.setY(y);
            zegoEffectsRect.setWidth(width);
            zegoEffectsRect.setHeight(height);

            mZegoEffects.setChromaKeyForegroundPosition(zegoEffectsRect);
        }

    }

    //destroy effects engine
    void destroyEffects(){
        if (mZegoEffects != null) {
            mZegoEffects.destroy();
        }
    }



    //set event handler listener
    public void setOnEventHandler(OnEventHandler handler) {
        mOnEventHandler = handler;
    }

    interface OnEventHandler{
        void onError(ZegoEffects zegoEffects, int errorCode, String desc);
        void onFaceDetectionResult(ZegoEffectsFaceDetectionResult[] results,
                                   ZegoEffects zegoEffects);
    }
}
