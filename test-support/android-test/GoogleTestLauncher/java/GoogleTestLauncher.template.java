package %(package)s;

import static android.content.Context.POWER_SERVICE;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.PowerManager;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ErrorCollector;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class GoogleTestLauncher {

    static String[] testArgs = %(testArgs)s;
    private static final boolean deployResources = %(deployResources)b;

    @Test
    public void invokeGoogleTest() {
        Context targetContext = InstrumentationRegistry.getInstrumentation().getContext();
        PowerManager powerManager = (PowerManager) targetContext.getSystemService(POWER_SERVICE);
        PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyApp::MyWakelockTag");
        wakeLock.acquire();

        File filesDir = targetContext.getFilesDir();
        String filesDirPath = filesDir.getAbsolutePath();

        AssetManager assetManager = targetContext.getAssets();
        if ( deployResources ) {
            deployAssetsToInternalStorage( targetContext );
        }
        invokeGoogleTest(testArgs, assetManager, filesDirPath, mGTestListener);

        wakeLock.release();
    }

    static {
        System.loadLibrary("%(nativeLibrary)s");
    }

    static native int invokeGoogleTest(String[] arguments, AssetManager assetManager, String filesDir, GTestListener listener);

    public interface GTestListener
    {
        void onTestPartResult(boolean passed, int lineNumber, String filename, String description, String summary);
    }

    @Rule
    public ErrorCollector mErrorCollector = new ErrorCollector();

    private GTestListener mGTestListener = new GTestListener() {

        @Override
        public void onTestPartResult(boolean passed, int lineNumber, String filename, String description, String summary) {
            if ( !passed ) {
                mErrorCollector.addError(new AssertionError(
            "Failed with: '" + description + "'\n" +
                    "at " + filename + ":" + lineNumber + ".\n" +
                    "Summary: '" + summary + "'"
                ));
            }
        }
    };

    public static void deployAssetsToInternalStorage( Context context ) {
        File internalStorage = context.getFilesDir();
        deleteRecursive( internalStorage );
        boolean success = internalStorage.mkdir();
        if ( !success ) {
            Log.e("tag", "Cannot create directory: " + internalStorage.getPath() );
        }

        copyFileOrDir( "%(pkgroot)s", context, internalStorage.getPath() );
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
                    if ( "".equals(path) ) {
                        copyFileOrDir( asset, context, destRootPath );
                    } else {
                        copyFileOrDir( path + "/" + asset, context, destRootPath );
                    }
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
