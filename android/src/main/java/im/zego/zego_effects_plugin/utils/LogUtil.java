package im.zego.zego_effects_plugin.utils;

import android.util.Log;

public class LogUtil {

    public static boolean debug = true;

    public static void e(String tag, String msg){
        if (debug) {
            Log.e(tag, msg);
        }
    }

    public static void d(String tag, String msg){
        if (debug) {
            Log.d(tag, msg);
        }
    }

    public static void i(String tag, String msg){
        if (debug) {
            Log.i(tag, msg);
        }
    }

    public static void v(String tag, String msg){
        if (debug) {
            Log.v(tag, msg);
        }
    }
}
