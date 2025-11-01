package com.example.exerunner;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class NativeRunner {

    static {
        System.loadLibrary( BuildConfig.NATIVE_LIB_NAME );
    }

    public static native int runNative( String commandLineParams );

    public static native void interrupt();

    private static native void initialize( Context context );

    public static native void terminate();

    public static void initializeNativeBinary( Context context ) {
        initialize( context );
    }

    private static void deleteRecursive( File fileOrDirectory ) {
        if ( fileOrDirectory.isDirectory() ) {
            File[] children = fileOrDirectory.listFiles();
            if ( children != null ) {
                File[] files = fileOrDirectory.listFiles();
                if ( files != null ) {
                    for ( File child : files ) {
                        deleteRecursive( child );
                    }
                }
            }
        }

        if ( !fileOrDirectory.delete() ) {
            Log.e("tag", "Failed to delete:" + fileOrDirectory.getPath() );
        }
    }

    public static void deployAssetsToInternalStorage( Context context ) {
        File internalStorage = context.getFilesDir();
        deleteRecursive( internalStorage );
        boolean success = internalStorage.mkdir();
        if ( !success ) {
            Log.e("tag", "Cannot create directory: " + internalStorage.getPath() );
        }

        copyFileOrDir( BuildConfig.PKG_ROOT, context, internalStorage.getPath() );
    }

    private static void copyFileOrDir(String path, Context context, String destRootPath) {
        AssetManager assetManager = context.getAssets();
        String[] assets;
        try {
            assets = assetManager.list(path);
            if (assets.length == 0) {
                copyFile( path, context, destRootPath );
            } else {
                String fullPath = destRootPath + "/" + path;
                File dir = new File(fullPath);
                if ( !dir.exists() ) {
                    boolean success = dir.mkdir();
                    if ( !success ) {
                        Log.e("tag", "Cannot create directory: " + dir.getPath() );
                    }
                }
                for (String asset : assets) {
                    copyFileOrDir( path + "/" + asset, context, destRootPath );
                }
            }
        } catch (IOException ex) {
            Log.e("tag", "I/O Exception", ex);
        }
    }

    private static void copyFile( String filename, Context context, String destRootPath ) {
        AssetManager assetManager = context.getAssets();

        InputStream in = null;
        OutputStream out = null;
        try {
            in = assetManager.open(filename);
            String newFileName = destRootPath + "/" + filename;
            Log.d( "DeployResources", "Writing file: " + newFileName);
            out = new FileOutputStream(newFileName);

            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            out.flush();
            out.close();
        } catch ( Exception e ) {
            Log.e("tag", "Exception during file copy: " + e.getMessage());
        }

    }
}
