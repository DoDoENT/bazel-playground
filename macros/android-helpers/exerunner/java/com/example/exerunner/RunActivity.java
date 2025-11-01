package com.example.exerunner;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.PowerManager;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;

public class RunActivity extends Activity {

    private static final String defaultCommandLineParameters = BuildConfig.ARGS;
    private static final String parametersFilePath = "/data/local/tmp/parameters.txt";

    private boolean autoRun = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_run);

        // set wake lock
        getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        );

        NativeRunner.initializeNativeBinary(this.getApplicationContext());

        // detect if auto run should be used
        this.autoRun = new File(parametersFilePath).exists();

        if ( !autoRun ) {
            final EditText txtParams = findViewById(R.id.txtParams);
            txtParams.setText( defaultCommandLineParameters );

            Button btnClick = findViewById(R.id.btnExecute);
            btnClick.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    executeNative(txtParams.getText().toString());
                }
            });

            Button btnDeploy = findViewById(R.id.btnDeployResources);
            btnDeploy.setOnClickListener(new View.OnClickListener() {
                @SuppressLint("StaticFieldLeak")
                @Override
                public void onClick(View v) {
                    final Dialog pd = new Dialog( RunActivity.this, android.R.style.Theme_Black_NoTitleBar_Fullscreen );
                    pd.setContentView(R.layout.progress_dialog);
                    pd.setCancelable(false);
                    pd.show();
                    new AsyncTask<Void, Void, Void>() {
                        @Override
                        protected Void doInBackground(Void... params) {
                            NativeRunner.deployAssetsToInternalStorage(RunActivity.this);
                            return null;
                        }

                        @Override
                        protected void onPostExecute(Void aVoid) {
                            super.onPostExecute(aVoid);
                            pd.dismiss();
                        }
                    }.execute();
                }
            });
        }
    }

    @SuppressLint("SetTextI18n")
    private void executeNative(String parameters) {
        final Dialog pd = new Dialog( RunActivity.this, android.R.style.Theme_Black_NoTitleBar_Fullscreen );
        pd.setContentView(R.layout.progress_dialog);
        TextView tv = pd.findViewById(R.id.txtMsg);
        tv.setText( "Running executable with parameters '" + parameters + "'");
        pd.setCancelable(true);

        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        final PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
                "MyApp::MyWakelockTag");

        @SuppressLint("StaticFieldLeak")
        final AsyncTask<String, Void, Integer> task = new AsyncTask<String, Void, Integer>() {
            @Override
            protected Integer doInBackground(String... params) {
                if ( wakeLock != null ) {
                    wakeLock.acquire();
                }
                int statusCode = NativeRunner.runNative( params[ 0 ] );
                if ( wakeLock != null ) {
                    wakeLock.release();
                }
                return statusCode;
            }

            @Override
            protected void onPostExecute(Integer exitStatus) {
                super.onPostExecute(exitStatus);
                pd.dismiss();
                Toast.makeText( RunActivity.this, "Native exited with status " + exitStatus, Toast.LENGTH_LONG ).show();
                if (autoRun) {
                    RunActivity.this.finish();
                    System.exit(exitStatus);
                }
            }

            @Override
            protected void onCancelled(Integer exitStatus) {
                pd.dismiss();
                Toast.makeText( RunActivity.this, "Execution was cancelled", Toast.LENGTH_LONG ).show();
            }
        };

        pd.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
                new AlertDialog.Builder(RunActivity.this)
                        .setTitle("Cancel execution?")
                        .setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                                pd.show();
                                task.cancel(true);
                                NativeRunner.interrupt();
                            }
                        })
                        .setNegativeButton("No", new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                                pd.show();
                            }
                        })
                        .setCancelable(false)
                        .create()
                        .show();
            }
        });
        pd.show();

        // running heavy tests on UI thread will make Android kill the app
        task.execute(parameters);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (autoRun) {
            String parameters = defaultCommandLineParameters;
            FileInputStream fis = null;
            try {
                StringBuffer buf = new StringBuffer();
                fis = new FileInputStream(parametersFilePath);
                BufferedReader reader = new BufferedReader(new InputStreamReader(fis));
                String line = "";
                // merge all lines into a single command line line
                while ((line = reader.readLine()) != null) {
                    buf.append(line);
                    buf.append(' ');
                }

                parameters = buf.toString();
            } catch( FileNotFoundException fnfe ) {
                // no parameters, use default
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (fis != null) {
                    try {
                        fis.close();
                    } catch(Throwable ignored) {}
                }
            }
            executeNative(parameters);
        }
    }

    @Override
    protected void onDestroy() {
        NativeRunner.terminate();
        super.onDestroy();
    }

}
