package im.zego.zego_effects_plugin.capture;

import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.SystemClock;
import android.view.TextureView;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import im.zego.effects.ZegoEffects;
import im.zego.effects.entity.ZegoEffectsVideoFrameParam;
import im.zego.effects.enums.ZegoEffectsVideoFrameFormat;
import im.zego.zego_effects_plugin.egl.EglBase;
import im.zego.zego_effects_plugin.egl.EglBase14;
import im.zego.zego_effects_plugin.egl.GlRectDrawer;
import im.zego.zego_effects_plugin.egl.GlUtil;
import im.zego.zego_effects_plugin.utils.LogUtil;
import im.zego.zego_express_engine.IZegoFlutterCustomVideoCaptureHandler;
import im.zego.zego_express_engine.ZegoCustomVideoCaptureManager;

/**
 * VideoCaptureFromCamera2
 * 实现从摄像头采集数据并传给ZEGO SDK，需要继承实现ZEGO SDK 的ZegoVideoCaptureDevice类
 * 采用SURFACE_TEXTURE方式传递数据，将client返回的SurfaceTexture对象转为EglSurface再进行图像绘制
 */

/**
 * VideoCaptureFromCamera2
 * To collect data from the camera and pass it to the ZEGO SDK, you need to inherit the ZegoVideoCaptureDevice class that implements the ZEGO SDK
 *  * Use SURFACE_TEXTURE to transfer data, convert the SurfaceTexture object returned by the client to EglSurface and then draw the image
 */
public class VideoCaptureFromCamera2 implements
                                     IZegoFlutterCustomVideoCaptureHandler,
        SurfaceTexture.OnFrameAvailableListener,
        TextureView.SurfaceTextureListener {
    private static final String TAG = "VideoCaptureFromCamera2";
    private static final int CAMERA_STOP_TIMEOUT_MS = 7000;

    private Camera mCam = null;
    private Camera.CameraInfo mCamInfo = null;
    // camera相关参数的初始值
    // Initial values ​​of camera related parameters
    private int mFront = 1;
    public int mCameraWidth = 0;
    public int mCameraHeight = 0;
    private int mFrameRate = 30;
    private int mDisplayRotation = 0;
    private int mImageRotation = 0;

    // 用于帧缓冲区对象（FBO）的相关变量
    // Related variables for frame buffer object (FBO)
    private EglBase mDummyContext = null;
    private GlRectDrawer mDummyDrawer = null;
    private boolean mIsEgl14 = false;
    private int mInputTextureId = 0;
    private SurfaceTexture mInputSurfaceTexture = null;
    private float[] mInputMatrix = new float[16];
    private int mTextureId = 0;
    private int mFrameBufferId = 0;

    private HandlerThread mThread = null;
    private volatile Handler cameraThreadHandler = null;
    private final AtomicBoolean isCameraRunning = new AtomicBoolean();
    private final Object pendingCameraRestartLock = new Object();
    private volatile boolean pendingCameraRestart = false;

    // 用于展示预览图的相关变量
    // Related variables used to display preview images
    private boolean mIsPreview = false;

    private TextureView mTextureView = null;
    private ZegoEffects mZegoEffects;
    private int mEffectWidth;
    private int mEffectHeight;

    public VideoCaptureFromCamera2(ZegoEffects zegoEffects, int effectWidth, int effectHeight) {
        mZegoEffects = zegoEffects;
        mEffectWidth = effectWidth;
        mEffectHeight = effectHeight;
    }


    public void onStart(int channel) {
        allocateAndStart();
    }

    /**
     * 初始化资源，必须实现
     */
    /**
     * Initialization of resources must be achieved
     *      
     */
    public void allocateAndStart() {
        LogUtil.d(TAG, "allocateAndStart");
        mIsPreview = true;
        // 创建camera异步消息处理handler
        mThread = new HandlerThread("camera-cap");
        mThread.start();
        // 创建camera异步消息处理handler
        cameraThreadHandler = new Handler(mThread.getLooper());
        // Create a camera asynchronous message processing handler
        final CountDownLatch barrier = new CountDownLatch(1);
        cameraThreadHandler.post(new Runnable() {
            @Override
            public void run() {

                mDummyContext = EglBase.create(null, EglBase.CONFIG_PIXEL_BUFFER);

                try {
                    // 创建Surface
                    mDummyContext.createDummyPbufferSurface();
                    // 绑定eglContext、eglDisplay、eglSurface
                    mDummyContext.makeCurrent();
                    // 创建绘制类，用于FBO
                    mDummyDrawer = new GlRectDrawer();
                } catch (RuntimeException e) {
                    // Clean up before rethrowing the exception.
                    mDummyContext.releaseSurface();
                    e.printStackTrace();
                    throw e;
                }

                mIsEgl14 = EglBase14.isEGL14Supported();
                mInputTextureId = GlUtil.generateTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
                mInputSurfaceTexture = new SurfaceTexture(mInputTextureId);
                // 设置视频帧回调监听
                // Create a camera asynchronous message processing handler
                mInputSurfaceTexture.setOnFrameAvailableListener(VideoCaptureFromCamera2.this);

                barrier.countDown();

            }
        });
        try {
            barrier.await();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        startPreview();
    }


    public void onStop(int channel) {
        stopAndDeAllocate();
    }

    /**
     * 释放资源，必须实现
     * 先停止采集任务再清理client对象，以保证ZEGO SDK调用stopAndDeAllocate后，没有残留的异步任务导致野指针crash
     */
    /**
     *      * To release resources, it must be realized
     *      * Stop the collection task before cleaning the client object to ensure that after the ZEGO SDK calls stopAndDeAllocate, there is no residual asynchronous task that causes wild pointer crash
     *      
     */
    public void stopAndDeAllocate() {
        LogUtil.d(TAG, "stopAndDeAllocate");
        stopPreview();

        if (cameraThreadHandler != null) {
            final CountDownLatch barrier = new CountDownLatch(1);
            cameraThreadHandler.post(new Runnable() {
                @Override
                public void run() {

                    if (mTextureView != null) {
                        if (mTextureView.getSurfaceTextureListener().equals(VideoCaptureFromCamera2.this)) {
                            mTextureView.setSurfaceTextureListener(null);
                        }
                        mTextureView = null;
                    }

                    mInputSurfaceTexture.release();
                    mInputSurfaceTexture = null;

                    if (mInputTextureId != 0) {
                        int[] textures = new int[]{mInputTextureId};
                        GLES20.glDeleteTextures(1, textures, 0);
                        mInputTextureId = 0;
                    }

                    if (mTextureId != 0) {
                        int[] textures = new int[]{mTextureId};
                        GLES20.glDeleteTextures(1, textures, 0);
                        mTextureId = 0;
                    }

                    if (mFrameBufferId != 0) {
                        int[] frameBuffers = new int[]{mFrameBufferId};
                        GLES20.glDeleteFramebuffers(1, frameBuffers, 0);
                        mFrameBufferId = 0;
                    }

                    mDummyDrawer = null;
                    mDummyContext.release();
                    mDummyContext = null;

                    barrier.countDown();

                    mZegoEffects.uninitEnv();
                }
            });
            try {
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        mThread.quit();
        mThread = null;
    }

    // 启动camera
    public int startCamera() {
        isCameraRunning.set(true);

        final boolean didPost = maybePostOnCameraThread(new Runnable() {
            @Override
            public void run() {
                // * Create and Start Cam
                createCamOnCameraThread();
                startCamOnCameraThread();
            }
        });

        return 0;
    }

    // 关闭camera
    public int stopCamera() {
        mIsPreview = false;

        final CountDownLatch barrier = new CountDownLatch(1);
        final boolean didPost = maybePostOnCameraThread(new Runnable() {
            @Override
            public void run() {
                stopCaptureOnCameraThread(true /* stopHandler */);
                releaseCam();
                barrier.countDown();
            }
        });
        if (!didPost) {
            LogUtil.e(TAG, "Calling stopCapture() for already stopped camera.");
            return 0;
        }
        try {
            if (!barrier.await(CAMERA_STOP_TIMEOUT_MS, TimeUnit.MILLISECONDS)) {
                LogUtil.e(TAG, "Camera stop timeout");
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        LogUtil.d(TAG, "stopCapture done");

        return 0;
    }


    // 设置采集帧率
    // Set the acquisition frame rate
    public int setFrameRate(final int framerate) {
        mFrameRate = framerate;

        if (cameraThreadHandler != null) {
            cameraThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                    updateRateOnCameraThread(framerate);
                }
            });
        }

        return 0;
    }

    // 前后摄像头的切换
    // Switching between front and back cameras
    public int setFrontCam(int bFront) {
        mFront = bFront;
        // 切换摄像头后需要重启camera
        // Camera needs to be restarted after switching cameras
        restartCam();
        return 0;
    }

    // 启动预览
    public int startPreview() {
        mIsPreview = true;
        return startCamera();
    }

    // 停止预览
    public int stopPreview() {
        mIsPreview = false;
        return stopCamera();
    }

    // 更新camera的采集帧率
    // Update camera frame rate
    private int updateRateOnCameraThread(final int framerate) {
        checkIsOnCameraThread();
        if (mCam == null) {
            return 0;
        }

        mFrameRate = framerate;
        Camera.Parameters parms = mCam.getParameters();
        List<int[]> supported = parms.getSupportedPreviewFpsRange();

        for (int[] entry : supported) {
            if ((entry[0] == entry[1]) && entry[0] == mFrameRate * 1000) {
                parms.setPreviewFpsRange(entry[0], entry[1]);
                break;
            }
        }

        int[] realRate = new int[2];
        parms.getPreviewFpsRange(realRate);
        if (realRate[0] == realRate[1]) {
            mFrameRate = realRate[0] / 1000;
        } else {
            mFrameRate = realRate[1] / 2 / 1000;
        }

        try {
            mCam.setParameters(parms);
        } catch (Exception ex) {
            LogUtil.i(TAG, "vcap: update fps -- set camera parameters error with exception\n");
            ex.printStackTrace();
        }
        return 0;
    }

    private void checkIsOnCameraThread() {
        if (cameraThreadHandler == null) {
            LogUtil.e(TAG, "Camera is not initialized - can't check thread.");
        } else if (Thread.currentThread() != cameraThreadHandler.getLooper().getThread()) {
            throw new IllegalStateException("Wrong thread");
        }
    }

    private boolean maybePostOnCameraThread(Runnable runnable) {
        return cameraThreadHandler != null && isCameraRunning.get()
                && cameraThreadHandler.postAtTime(runnable, this, SystemClock.uptimeMillis());
    }

    // 创建camera
    // create camera
    private int createCamOnCameraThread() {
        LogUtil.v(TAG, "createCamOnCameraThread");
        checkIsOnCameraThread();
        if (!isCameraRunning.get()) {
            LogUtil.e(TAG, "startCaptureOnCameraThread: Camera is stopped");
            return 0;
        }

        LogUtil.i(TAG, "board: " + Build.BOARD);
        LogUtil.i(TAG, "device: " + Build.DEVICE);
        LogUtil.i(TAG, "manufacturer: " + Build.MANUFACTURER);
        LogUtil.i(TAG, "brand: " + Build.BRAND);
        LogUtil.i(TAG, "model: " + Build.MODEL);
        LogUtil.i(TAG, "product: " + Build.PRODUCT);
        LogUtil.i(TAG, "sdk: " + Build.VERSION.SDK_INT);

        // 获取欲设置camera的索引号
        // Get the index number of the camera to be set
        int nFacing = (mFront != 0) ? Camera.CameraInfo.CAMERA_FACING_FRONT : Camera.CameraInfo.CAMERA_FACING_BACK;

        if (mCam != null) {
            // 已打开camera
            // Camera opened
            return 0;
        }

        mCamInfo = new Camera.CameraInfo();
        // 获取camera的数目
        // Get the number of cameras
        int nCnt = Camera.getNumberOfCameras();
        // 得到欲设置camera的索引号并打开camera
        // Get the index number of the camera you want to set and open the camera
        for (int i = 0; i < nCnt; i++) {
            Camera.getCameraInfo(i, mCamInfo);
            if (mCamInfo.facing == nFacing) {
                try {
                    mCam = Camera.open(i);
                } catch (RuntimeException e) {
                    mCam = null;
                }
                break;
            }
        }

        // 没找到欲设置的camera
        // Did not find the camera to be set
        if (mCam == null) {
            LogUtil.i(TAG, "[WARNING] no camera found, try default\n");
            // 先试图打开默认camera
            // First try to open the default camera
            mCam = Camera.open();

            if (mCam == null) {
                LogUtil.i(TAG, "[ERROR] no camera found\n");
                return -1;
            }
        }


        int result;
        if (mCamInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            result = (mCamInfo.orientation + mDisplayRotation) % 360;
            result = (360 - result) % 360;  // compensate the mirror
        } else {  // back-facing
            result = (mCamInfo.orientation - mDisplayRotation + 360) % 360;
        }
        // 设置预览图像的转方向
        // Set the rotation direction of the preview image
        mCam.setDisplayOrientation(result);
        mImageRotation = result;

        // *
        // * Now set preview size
        // *
        Camera.Parameters parms = mCam.getParameters();
        Camera.Size psz = getOptimalPreviewSize(parms.getSupportedPreviewSizes(), mEffectWidth, mEffectHeight, mImageRotation);
        if (mImageRotation == 90 || mImageRotation == 270) {
            int tmp = psz.width;
            mCameraWidth = psz.height;
            mCameraHeight = tmp;
        }

        LogUtil.e("setPreviewSize", psz.width + "||" + psz.height);
        LogUtil.e("setInitEnvSize", mCameraWidth + "||" + mCameraHeight);
        parms.setPreviewSize(psz.width, psz.height);
        mZegoEffects.initEnv(mCameraWidth, mCameraHeight);
        // 获取camera支持的帧率范围，并设置预览帧率范围
        // Get the frame rate range supported by the camera and set the preview frame rate range
        List<int[]> supported = parms.getSupportedPreviewFpsRange();

        for (int[] entry : supported) {
            if ((entry[0] == entry[1]) && entry[0] == mFrameRate * 1000) {
                parms.setPreviewFpsRange(entry[0], entry[1]);
                break;
            }
        }

        // 获取camera的实际帧率
        // Get the actual frame rate of the camera
        int[] realRate = new int[2];
        parms.getPreviewFpsRange(realRate);
        if (realRate[0] == realRate[1]) {
            mFrameRate = realRate[0] / 1000;
        } else {
            mFrameRate = realRate[1] / 2 / 1000;
        }

        // 设置camera的对焦模式
        // Set the camera's focus mode
        boolean bFocusModeSet = false;
        for (String mode : parms.getSupportedFocusModes()) {
            if (mode.compareTo(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO) == 0) {
                try {
                    parms.setFocusMode(mode);
                    bFocusModeSet = true;
                    break;
                } catch (Exception ex) {
                    LogUtil.i(TAG, "[WARNING] vcap: set focus mode error (stack trace followed)!!!\n");
                    ex.printStackTrace();
                }
            }
        }
        if (!bFocusModeSet) {
            LogUtil.i(TAG, "[WARNING] vcap: focus mode left unset !!\n");
        }

        try {
            // 设置camera的参数
            mCam.setParameters(parms);
        } catch (Exception ex) {
            LogUtil.i(TAG, "vcap: set camera parameters error with exception\n");
            ex.printStackTrace();
        }

        if (mTextureId != 0) {
            int[] textures = new int[]{mTextureId};
            GLES20.glDeleteTextures(1, textures, 0);
            mTextureId = 0;
        }

        if (mFrameBufferId != 0) {
            int[] frameBuffers = new int[]{mFrameBufferId};
            GLES20.glDeleteFramebuffers(1, frameBuffers, 0);
            mFrameBufferId = 0;
        }

        // 销毁传递给ZEGO SDK的surface，如果原先已有EGLSurface的情况下
        return 0;
    }

    private static Camera.Size getOptimalPreviewSize(List<Camera.Size> sizes, int w, int h, int mImageRotation) {
        //获取当前相机支持的 尺寸
        List<Camera.Size> vSizes = sizes;
        double mPreviewScale = (double) h / (double) w;
        //获取和屏幕比列相近的 一个尺寸
        Camera.Size previewSize = getCloselyPreSize(w, h, vSizes, mImageRotation);

        return previewSize;
    }

    /**
     * 通过对比得到与宽高比最接近的尺寸（如果有相同尺寸，优先选择）
     *
     * @param surfaceWidth  需要被进行对比的原宽
     * @param surfaceHeight 需要被进行对比的原高
     * @param preSizeList   需要对比的预览尺寸列表
     * @return 得到与原宽高比例最接近的尺寸
     */
    private static Camera.Size getCloselyPreSize(int surfaceWidth, int surfaceHeight,
                                                 List<Camera.Size> preSizeList, int mImageRotation) {

        int ReqTmpWidth;
        int ReqTmpHeight;
        int ReqTmpWidth2;
        int ReqTmpHeight2;
        // 当屏幕为垂直的时候需要把宽高值进行调换，保证宽大于高
        ReqTmpWidth = surfaceWidth;
        ReqTmpHeight = surfaceHeight;
        //先查找preview中是否存在与surfaceview相同宽高的尺寸
        for (Camera.Size size : preSizeList) {
            ReqTmpWidth2 = size.width;
            ReqTmpHeight2 = size.height;
            if (mImageRotation == 90 || mImageRotation == 270) {
                int tmp = ReqTmpWidth2;
                ReqTmpWidth2 = ReqTmpHeight2;
                ReqTmpHeight2 = tmp;
            }

            if ((ReqTmpWidth2 == ReqTmpWidth) && (ReqTmpHeight2 == ReqTmpHeight)) {
                return size;
            }
        }

        // 得到与传入的宽高比最接近的size
        float reqRatio = ((float) ReqTmpWidth) / ReqTmpHeight;
        float curRatio, deltaRatio;
        float deltaRatioMin = Float.MAX_VALUE;
        Camera.Size retSize = null;
        for (Camera.Size size : preSizeList) {
            ReqTmpWidth2 = size.width;
            ReqTmpHeight2 = size.height;
            if (mImageRotation == 90 || mImageRotation == 270) {
                int tmp = ReqTmpWidth2;
                ReqTmpWidth2 = ReqTmpHeight2;
                ReqTmpHeight2 = tmp;
            }
            curRatio = ((float) ReqTmpWidth2) / ReqTmpHeight2;
            deltaRatio = Math.abs(reqRatio - curRatio);
            if (deltaRatio < deltaRatioMin) {
                deltaRatioMin = deltaRatio;
                retSize = size;
            }
        }

        return retSize;
    }


    // 启动camera
    private int startCamOnCameraThread() {
        checkIsOnCameraThread();
        if (!isCameraRunning.get() || mCam == null) {
            LogUtil.e(TAG, "startPreviewOnCameraThread: Camera is stopped");
            return 0;
        }

        // * mCam.setDisplayOrientation(90);
        if (mInputSurfaceTexture == null) {
            LogUtil.e(TAG, "mInputSurfaceTexture == null");
            return -1;
        }

        try {
            // 设置预览SurfaceTexture
            mCam.setPreviewTexture(mInputSurfaceTexture);
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 启动camera预览
        mCam.startPreview();
        LogUtil.v(TAG, "startPreview success");

        return 0;
    }

    // camera停止采集
    // The camera stops collecting
    private int stopCaptureOnCameraThread(boolean stopHandler) {
        checkIsOnCameraThread();
        LogUtil.d(TAG, String.format("stopCaptureOnCameraThread stopHandler: %b", stopHandler));

        if (stopHandler) {
            // Clear the cameraThreadHandler first, in case stopPreview or
            // other driver code deadlocks. Deadlock in
            // android.hardware.Camera._stopPreview(Native Method) has
            // been observed on Nexus 5 (hammerhead), OS version LMY48I.
            // The camera might post another one or two preview frames
            // before stopped, so we have to check |isCameraRunning|.
            // Remove all pending Runnables posted from |this|.
            isCameraRunning.set(false);
            cameraThreadHandler.removeCallbacksAndMessages(this /* token */);
        }

        if (mCam != null) {
            // 停止camera预览
            mCam.stopPreview();
        }
        return 0;
    }

    // 重启camera
    private int restartCam() {
        synchronized (pendingCameraRestartLock) {
            if (pendingCameraRestart) {
                LogUtil.v(TAG, "Ignoring camera switch request.");
                return 0;
            }
            pendingCameraRestart = true;
        }

        final boolean didPost = maybePostOnCameraThread(new Runnable() {
            @Override
            public void run() {
                stopCaptureOnCameraThread(false);
                releaseCam();
                createCamOnCameraThread();
                startCamOnCameraThread();
                synchronized (pendingCameraRestartLock) {
                    pendingCameraRestart = false;
                }
            }
        });

        if (!didPost) {
            synchronized (pendingCameraRestartLock) {
                pendingCameraRestart = false;
            }
        }

        return 0;
    }

    // 释放camera
    private int releaseCam() {
        // * release cam
        if (mCam != null) {
            mCam.release();
            mCam = null;
        }

        // * release cam info
        mCamInfo = null;
        return 0;
    }

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
        if (cameraThreadHandler != null) {
            cameraThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                }
            });
        }
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        if (cameraThreadHandler != null) {
            final CountDownLatch barrier = new CountDownLatch(1);
            cameraThreadHandler.post(new Runnable() {
                @Override
                public void run() {
                    // 销毁用于屏幕显示的surface（预览）
                    barrier.countDown();
                }
            });
            try {
                barrier.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        return true;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {

    }

    // 在SurfaceTexture.OnFrameAvailableListener回调中更新采集数据
    // Update the collected data in the SurfaceTexture.OnFrameAvailableListener callback
    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        // 绑定eglContext、eglDisplay、eglSurface
        surfaceTexture.updateTexImage();
        long timestamp;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            timestamp = SystemClock.elapsedRealtime();
        } else {
            timestamp = TimeUnit.MILLISECONDS.toMillis(SystemClock.elapsedRealtime());
        }

        surfaceTexture.getTransformMatrix(mInputMatrix);

        // 纠正图像展示方向
        // Correct image display direction
        int width = mCameraWidth;
        int height = mCameraHeight;

        if (mTextureId == 0) {
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
            mTextureId = GlUtil.generateTexture(GLES20.GL_TEXTURE_2D);
            // 生成2D纹理
            // Generate 2D textures
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, width, height, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);

            // 创建帧缓冲对象，绘制纹理到帧缓冲区并返回缓冲区索引
            // Create frame buffer object, draw texture to frame buffer and return buffer index
            mFrameBufferId = GlUtil.generateFrameBuffer(mTextureId);
            LogUtil.e("zego", "生成的mFrameBufferId=" + mFrameBufferId);
        } else {
            // 绑定帧缓冲区
            // Bind frame buffer
            GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFrameBufferId);
        }


        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);

        Matrix.rotateM(mInputMatrix, 0, 180, 0, 0, 1);
        Matrix.translateM(mInputMatrix, 0, -1, -1, 0);

        // 绘制OES texture
        // Draw OES texture
        mDummyDrawer.drawOes(mInputTextureId, mInputMatrix,
                width, height, 0, 0, width, height);
        // 解邦帧缓冲区
        // Unbind the frame buffer
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);

        ZegoEffectsVideoFrameParam zegoEffectsVideoFrameParam = new ZegoEffectsVideoFrameParam();
        zegoEffectsVideoFrameParam.setFormat(ZegoEffectsVideoFrameFormat.RGBA32);
        zegoEffectsVideoFrameParam.setWidth(mCameraWidth);
        zegoEffectsVideoFrameParam.setHeight(mCameraHeight);
        int zegoTextureId = mZegoEffects.processTexture(mTextureId, zegoEffectsVideoFrameParam);

        if (mIsPreview) {
            ZegoCustomVideoCaptureManager.getInstance().sendGLTextureData(zegoTextureId, mCameraWidth, mCameraHeight, timestamp, 0);
        }
    }
}
