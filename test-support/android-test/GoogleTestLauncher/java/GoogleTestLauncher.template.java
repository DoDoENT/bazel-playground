package %(package)s;

import static android.content.Context.POWER_SERVICE;

import android.content.Context;
import android.content.res.AssetManager;
import android.os.PowerManager;

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

    @Test
    public void invokeGoogleTest() {
        Context targetContext = InstrumentationRegistry.getInstrumentation().getContext();
        PowerManager powerManager = (PowerManager) targetContext.getSystemService(POWER_SERVICE);
        PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyApp::MyWakelockTag");
        wakeLock.acquire();

        AssetManager assetManager = targetContext.getAssets();
        invokeGoogleTest(testArgs, assetManager, mGTestListener);

        wakeLock.release();
    }

    static {
        System.loadLibrary("%(nativeLibrary)s");
    }

    static native int invokeGoogleTest(String[] arguments, AssetManager assetManager, GTestListener listener);

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
}
