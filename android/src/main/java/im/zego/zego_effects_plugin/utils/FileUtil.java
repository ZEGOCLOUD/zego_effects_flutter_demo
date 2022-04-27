package im.zego.zego_effects_plugin.utils;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class FileUtil {

    /**
     * 拷贝文件
     * @param context
     * @param assetsFilePath
     * @param targetFileFullPath
     */
    public static void copyFileFromAssets(Context context, String assetsFilePath, String targetFileFullPath) {

        try {
            String fileNames[] = context.getAssets().list(assetsFilePath);//获取assets目录下的所有文件及目录名
            if (fileNames.length > 0) {
                File file = new File(targetFileFullPath);
                file.mkdirs();
                for (String fileName : fileNames) {
                    copyFileFromAssets(context, assetsFilePath + File.separator + fileName, targetFileFullPath + File.separator + fileName);
                }
            } else {//如果是文件

                File file = new File(targetFileFullPath);
                File fileTemp = new File(targetFileFullPath+".temp");
                if(file.exists())
                {
                    Log.d("Tag", "文件存在");
                    return;
                }
                fileTemp.getParentFile().mkdir();

                InputStream is = context.getAssets().open(assetsFilePath);

                FileOutputStream fos = new FileOutputStream(fileTemp);
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {//循环从输入流读取 buffer字节
                    fos.write(buffer, 0, byteCount);//将读取的输入流写入到输出流
                }
                fos.flush();//刷新缓冲区
                is.close();
                fos.close();

                fileTemp.renameTo(file);
            }

        } catch (Exception e) {
            Log.d("Tag", "copyFileFromAssets " + "IOException-" + e.getMessage());
        }
    }

}
