package %(package)s;

import static android.content.Context.POWER_SERVICE;

import android.app.Activity;
import android.content.res.AssetManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.PowerManager;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

public class LaunchActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_launch);

        Button btnClick = findViewById(R.id.btnLaunch);
        btnClick.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                executeNative();
            }
        });
    }

    private void executeNative() {
        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyApp::MyWakelockTag");

        AssetManager assetManager = getAssets();

        GoogleTestLauncher.GTestListener mGTestListener = new GoogleTestLauncher.GTestListener() {

            @Override
            public void onTestPartResult(boolean passed, int lineNumber, String filename, String description, String summary) {
                if ( !passed ) {
                    Toast.makeText( LaunchActivity.this, "Failed: " + description, Toast.LENGTH_LONG ).show();
                }
            }
        };

        final AsyncTask<String, Void, Integer> task = new AsyncTask<String, Void, Integer>() {
            @Override
            protected Integer doInBackground(String... params) {
                if ( wakeLock != null ) {
                    wakeLock.acquire();
                }
                int statusCode = GoogleTestLauncher.invokeGoogleTest(GoogleTestLauncher.testArgs, assetManager, mGTestListener);
                if ( wakeLock != null ) {
                    wakeLock.release();
                }
                return statusCode;
            }

            @Override
            protected void onPostExecute(Integer exitStatus) {
                super.onPostExecute(exitStatus);
                Toast.makeText( LaunchActivity.this, "Native exited with status " + exitStatus, Toast.LENGTH_LONG ).show();
            }

            @Override
            protected void onCancelled(Integer exitStatus) {
                Toast.makeText( LaunchActivity.this, "Execution was cancelled", Toast.LENGTH_LONG ).show();
            }
        };

        task.execute();
    }

}
