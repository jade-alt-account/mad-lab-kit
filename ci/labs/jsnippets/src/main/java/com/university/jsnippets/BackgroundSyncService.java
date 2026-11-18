package com.university.jsnippets;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

public class BackgroundSyncService extends Service {

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("ServiceLog", "Background Service Started");

        return START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        // Return null for un-bound background services
        return null;
    }
}
