package com.university.jsnippets;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

/** Compile check for Outline Track snippets that the labs do not use directly. */
@SuppressWarnings({"deprecation", "unused"})
public class MainActivity extends Activity {

    private ProgressBar progressBar;
    private TextView myTextView;

    private String performHeavyNetworkRequest(String url) {
        return "result for " + url;
    }

    private class DownloadTask extends AsyncTask<String, Void, String> {

        @Override
        protected void onPreExecute() {
            progressBar.setVisibility(View.VISIBLE);       // main thread
        }

        @Override
        protected String doInBackground(String... urls) {
            // Background thread: never touch views here
            return performHeavyNetworkRequest(urls[0]);
        }

        @Override
        protected void onPostExecute(String result) {
            progressBar.setVisibility(View.GONE);          // main thread again
            myTextView.setText(result);
        }
    }

    void startTask() {
        new DownloadTask().execute("https://api.example.com/data");
    }

    void outlineNotification() {
        NotificationManager manager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        Intent intent = new Intent(this, TargetActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);

        Notification notification = new Notification.Builder(this)
                .setSmallIcon(R.drawable.ic_notification)
                .setContentTitle("New Message Alert")
                .setContentText("Tap to read your message.")
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .build();

        manager.notify(1, notification);
    }

    void crud() {
        FeedReaderDbHelper helper = new FeedReaderDbHelper(this);
        SQLiteDatabase db = helper.getWritableDatabase();

        // INSERT INTO users (name) VALUES ('Ayesha')
        ContentValues values = new ContentValues();
        values.put("name", "Ayesha");
        long newId = db.insert("users", null, values);

        // SELECT id, name FROM users WHERE name = 'Ayesha' ORDER BY name
        Cursor c = db.query("users", new String[] { "id", "name" },
                "name = ?", new String[] { "Ayesha" }, null, null, "name");
        try {
            while (c.moveToNext()) {
                long id = c.getLong(c.getColumnIndexOrThrow("id"));
                String name = c.getString(c.getColumnIndexOrThrow("name"));
                Log.d("DB", id + ": " + name);
            }
        } finally {
            c.close();
        }

        // UPDATE users SET name = 'Ayesha Khan' WHERE id = newId
        ContentValues changes = new ContentValues();
        changes.put("name", "Ayesha Khan");
        int updated = db.update("users", changes, "id = ?",
                new String[] { String.valueOf(newId) });

        // DELETE FROM users WHERE id = newId
        int deleted = db.delete("users", "id = ?", new String[] { String.valueOf(newId) });
    }

    void prefs() {
        // Write: getSharedPreferences(name, mode) works in any Activity or Service
        SharedPreferences prefs = getSharedPreferences("settings", MODE_PRIVATE);
        prefs.edit()
             .putString("username", "Ayesha")
             .putBoolean("dark_mode", true)
             .apply();

        // Read: the second argument is returned when the key does not exist yet
        String user = prefs.getString("username", "Guest");
        boolean dark = prefs.getBoolean("dark_mode", false);
    }

    void share() {
        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_SUBJECT, "Lecture notes");
        send.putExtra(Intent.EXTRA_TEXT, "Module 5 notes: https://example.com/notes");
        startActivity(Intent.createChooser(send, "Share notes via"));
    }

    void connectivity() {
        // Outline Track: is there a connection? (needs ACCESS_NETWORK_STATE, a normal permission)
        ConnectivityManager cm =
                (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo info = cm.getActiveNetworkInfo();     // deprecated since Android 10
        boolean online = info != null && info.isConnected();
    }

    void smsSilently() {
        // Action: Send an SMS silently using SmsManager
        SmsManager smsManager = SmsManager.getDefault();
        smsManager.sendTextMessage("5551234567", null, "Hello from my custom app!", null, null);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TextView t = new TextView(this);
        t.setText("snippets");
        setContentView(t);
    }
}
