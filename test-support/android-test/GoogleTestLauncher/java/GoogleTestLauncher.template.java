package %(package)s;

import android.content.Context;
import android.content.res.AssetManager;

import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class GoogleTestLauncher {
    @Test
    public void invokeGoogleTest() {
        AssetManager assetManager = InstrumentationRegistry.getInstrumentation().getContext().getAssets();
        assertEquals(0, invokeGoogleTest(%(testArgs)s, assetManager));
    }

    static {
        System.loadLibrary("%(nativeLibrary)s");
    }

    private static native int invokeGoogleTest(String[] arguments, AssetManager assetManager);
}
