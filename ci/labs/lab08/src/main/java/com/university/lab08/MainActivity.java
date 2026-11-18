package com.university.lab08;

import android.Manifest;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity extends AppCompatActivity {

    private int counter = 0;
    private TextView statusView;
    private TextView counterView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        statusView = (TextView) findViewById(R.id.text_status);
        counterView = (TextView) findViewById(R.id.text_counter);
        Button startButton = (Button) findViewById(R.id.button_start);
        Button stopButton = (Button) findViewById(R.id.button_stop);

        createChannel();
        askForNotificationPermission();

        findViewById(R.id.button_plus).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                counter++;
                counterView.setText(String.valueOf(counter));
            }
        });
        // Step 2: freeze the screen on purpose
        findViewById(R.id.button_slow_main).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    Thread.sleep(8000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });
        // Step 3: the same work on a background thread, result posted with a Handler
        findViewById(R.id.button_slow_bg).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                statusView.setText("Working...");
                // Action: Execute heavy operation in a background thread
                new Thread(new Runnable() {
                    public void run() {
                        try {
                            Thread.sleep(8000);
                        } catch (InterruptedException e) {
                            return;
                        }
                        final String result = "Done";

                        // Action: Post the result back to the Main UI Thread
                        Handler mainHandler = new Handler(Looper.getMainLooper());
                        mainHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                statusView.setText(result);
                            }
                        });
                    }
                }).start();
            }
        });
        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(MainActivity.this, CounterService.class);
                ContextCompat.startForegroundService(MainActivity.this, i);
            }
        });
        stopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                stopService(new Intent(MainActivity.this, CounterService.class));
            }
        });
    }

    private static final String CHANNEL_ID = "counter";

    private void createChannel() {
        // Channels exist from Android 8.0 (API 26); creating one twice is harmless
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID, "Messages", NotificationManager.IMPORTANCE_HIGH);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(channel);
        }
    }


    private static final int REQUEST_NOTIFICATIONS = 7;

    private void askForNotificationPermission() {
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[] { Manifest.permission.POST_NOTIFICATIONS },
                            REQUEST_NOTIFICATIONS);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_NOTIFICATIONS && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(this, "Notifications allowed", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this, "Notification permission denied",
                    Toast.LENGTH_SHORT).show();
        }
    }

    // Task 3: PowerReceiver registered while the screen is visible
    private final PowerReceiver receiver = new PowerReceiver();

    @Override
    protected void onStart() {
        super.onStart();
        registerReceiver(receiver, new IntentFilter(Intent.ACTION_POWER_CONNECTED));
    }

    @Override
    protected void onStop() {
        unregisterReceiver(receiver);
        super.onStop();
    }
}
