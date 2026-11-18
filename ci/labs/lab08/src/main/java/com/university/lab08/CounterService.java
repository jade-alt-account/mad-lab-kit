package com.university.lab08;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import androidx.core.app.NotificationCompat;

public class CounterService extends Service {

    private static final String CHANNEL_ID = "counter";
    private volatile boolean running;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Notification n = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle("Counter running")
                .build();
        startForeground(1, n);   // must be called within a few seconds of starting

        running = true;
        new Thread(new Runnable() {
            @Override
            public void run() {
                int i = 0;
                while (running) {
                    Log.d("CounterService", "tick " + i++);
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {
                        return;
                    }
                }
            }
        }).start();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        running = false;         // lets the worker thread finish
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;             // not a bound service
    }
}
