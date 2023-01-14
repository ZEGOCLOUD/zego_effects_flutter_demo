## zego_effects_plugin

The AI Effects Flutter SDK provided by ZEGO is a Flutter Plugin Wrapper that is based on the native [AI Effects SDK](https://doc-zh.zego.im/article/9895). It provides various AI-powered real-time video effects, including face beautification, AR effects, image segmentation, and more. You can use the ZegoEffects SDK for a wide range of use cases, such as social and entertainment live streaming, online education, and camera tools.

## 1️⃣ Install Flutter

 **[Flutter Get Started](https://flutter.dev/docs/get-started/install)**

## 2️⃣ Set up the development environment

- Android Studio: Select the **Preferences** > **Plugins**, and search the `Flutter` plugin and install it, and add the Flutter SDK path downloaded in the previous step.

- VS Code: Search the `Flutter` extension in the application store and install it.

After setting up the Flutter environment, run the command `flutter doctor`, and install the dependency according to the instructions.

## 3️⃣ Apply for the ZEGO Effects license

You need to refer to the following document to get your license.

https://docs.zegocloud.com/article/12291

## 4️⃣ Import the `zego_express_engine`

Open the `pubspec.yaml` in your project, add the `zego_effects` dependency.

- Using `pub`（recommended）

```yaml
dependencies:
  flutter:
  sdk: flutter

  zego_effects: ^0.0.1
```

- Using git 

```yaml
dependencies:
  flutter:
  sdk: flutter

  zego_express_engine:
    git:
      url: git://待补充
      ref: master
```

Run the command `flutter pub get` after saving the file.

##  5️⃣ Add permissions

#### Android

Open the file `app/src/main/AndroidManifest.xml`, and add the following:

```xml
<!-- SDK 必须使用的权限 -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<!-- Demo App 需要使用的部分权限 -->
<uses-feature android:glEsVersion="0x00020000" android:required="true" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

### iOS

Select the target project, click **Info** > **Custom iOS Target Properties**.

![iOS Privacy Description](https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/privacy-description.png)

Click the `+` button to add camera and microphone permissions.

1. `Privacy - Camera Usage Description`

> If you need to use the Platform View, and the Flutter version is lower than 1.22, you will need to add an additional line of description on your iOS device. For details, see FAQ-1

## 6️⃣ Initialize the SDK

```Dart
import 'package:zego_effects_plugin/zego_effects_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    String version = 'Unknown';

    // Apply license from ZEGO
    final license appSign = 'abcdefghijklmnopqrstuvwzyv123456789abcdefghijklmnopqrstuvwzyz123';

    @override
    void initState() {
        super.initState();

        // Load Effects resources
        ZegoEffectsPlugin.instance.setResources(['FaceWhiteningResources']);
        // Create Effects
        ZegoEffectsPlugin.instance.create(license);
    }

    // Get version
    ZegoEffectsPlugin.instance.getVersion().then((value) {
      version = value;
    });

    @override
    Widget build(BuildContext context) {
        return MaterialApp(home: Scaffold(
            appBar: AppBar(title: const Text('ZegoEffects')),
            body: Center(child: Text('Version: $version')),
        ));
    }
}
```

## 7️⃣ Add colorful beauty effects

At present, only some beauty methods are exposed in the demo. You can add other beauty effects methods according to your real needs. The adding steps are as follows:

1. Add a method to `zego_effects_plugin.dart`
2. Add the implementation of this method in `ZegoEffectsPlugin.java`, and finally call the native method to complete.

You can refer to the android native documentation to add beauty effects.[ZegoEffects Reference](https://docs.zegocloud.com/article/9943)

## 8️⃣ FAQ

##### 1. iOS: This error occurs when using Platform View: [VERBOSE-2:platform_view_layer.cc(28)] Trying to embed a platform view but the PaintContext does not support embedding.

> This setting is no longer required for versions of Flutter 1.22 and later.

Open the iOS native project (Runner. Xcworkspace) that needs to use the Platform View, add the field `io.flutter.embedded_views_preview` to `Info.plist`, its value is `YES`.

![flutter enable platform view](https://storage.zego.im/sdk-doc/Pics/iOS/ZegoExpressEngine/Common/flutter_embeded_views_plist.png)

##### 2. iOS: `fatal error: lipo: -extract armv7 specified but fat file: [...] does not contain that architecture`

This issue usually occurs when switching iOS devices and can be resolved by removing the `flutter-project-path/build/` and `flutter-project-path/ios/DerivedData/` directories. (if you cannot find `DerivedData` folder, find `/Users/your-user-name/Library/Developer/Xcode/DerivedData/` instead.)



##### 3. iOS: The error occurs when compiling: `CDN: trunk URL couldn't be downloaded` or `CDN: trunk Repo update failed`

Open the Terminal, run 'cd' into the `ios` folder (the directory where the `Podfile` file is located) in the project root directory, and run the command `pod repo update`.

This is usually caused by a poor network, it is recommended to enable the agent. For details, see [iOS CocoaPods - FAQ](https://doc-zh.zego.im/zh/1253.html).



##### 4. iOS: Black tearing crack occurs when previewing.

Please enable Platform View for rendering on the iOS Platform. Due to some known compatibility issues, rendering with Texture for preview using the Express SDK on the iOS Platform cannot achieve the desired effect temporarily. This issue will be fixed in the later version.



##### 5. Android: When the Flutter was upgraded to V1.10 or later, `NoClassDefFoundError` appeared on the Android release causing the crash.

The Flutter has enabled code obfuscations by default in version 1.10 or later. Please add the `-keep` class configuration to the SDK in the `app/proguard-rules.pro` project to prevent obfuscations.

```java
-keep class **.zego.**{*;}
```



##### 6. Android: The following crashes may occur when `TextureRenderer` is frequently created or destroyed.

```text
OpenGLRenderer E [SurfaceTexture-0-4944-46] updateTexImage: SurfaceTexture is abandoned!

​    flutter E [ERROR:flutter/shell/platform/android/platform_view_android_jni.cc(39)] java.lang.RuntimeException: Error during updateTexImage (see logcat for details)
```

The cause of this issue is that the Flutter Engine caused thread insecurity when calling the updateTexImage() and release() of the SurfaceTexture, and this has been fixed in version `1.24-candidate.2`. For details, see [https://github.com/flutter/engine/pull/21777](https://github.com/flutter/engine/pull/21777)



##### 7. For other questions, see [Q&A](https://docs.zegocloud.com/faq/?product=AI_Vision&platform=android)