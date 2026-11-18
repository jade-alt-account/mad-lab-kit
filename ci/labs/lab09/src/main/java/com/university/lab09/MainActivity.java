package com.university.lab09;

import android.Manifest;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.telephony.SmsManager;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class MainActivity extends AppCompatActivity {

    private static final int REQUEST_SMS = 9;
    private EditText number;
    private EditText message;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        number = (EditText) findViewById(R.id.edit_number);
        message = (EditText) findViewById(R.id.edit_message);

        findViewById(R.id.button_via).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent sms = new Intent(Intent.ACTION_SENDTO, Uri.parse("smsto:" + number.getText().toString()));
                sms.putExtra("sms_body", message.getText().toString());
                startActivity(sms);
            }
        });
        findViewById(R.id.button_direct).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.SEND_SMS)
                        == PackageManager.PERMISSION_GRANTED) {
                    sendWithFeedback();
                } else {
                    ActivityCompat.requestPermissions(MainActivity.this,
                            new String[] { Manifest.permission.SEND_SMS }, REQUEST_SMS);
                }
            }
        });
        findViewById(R.id.button_dial).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Action: Open the dialer using an Implicit Intent
                Intent dialIntent = new Intent(Intent.ACTION_DIAL);
                dialIntent.setData(Uri.parse("tel:" + number.getText().toString()));
                startActivity(dialIntent);
            }
        });
        findViewById(R.id.button_email).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent email = new Intent(Intent.ACTION_SENDTO);
                // only e-mail apps accept mailto:
                email.setData(Uri.parse("mailto:"));
                email.putExtra(Intent.EXTRA_EMAIL, new String[] { "instructor@example.com" });
                email.putExtra(Intent.EXTRA_CC, new String[] { "class.rep@example.com" });
                email.putExtra(Intent.EXTRA_SUBJECT, "Question about Assignment 3");
                email.putExtra(Intent.EXTRA_TEXT,
                        "Dear Sir,\n\nI have a question about part (b).");
                startActivity(Intent.createChooser(email, "Send e-mail"));
            }
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_SMS && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            sendWithFeedback();
        }
    }

    private void sendWithFeedback() {
        String SENT = "com.university.sms.SENT";
        String DELIVERED = "com.university.sms.DELIVERED";

        PendingIntent sentPI = PendingIntent.getBroadcast(this, 0,
                new Intent(SENT).setPackage(getPackageName()),
                        PendingIntent.FLAG_IMMUTABLE);
        PendingIntent deliveredPI = PendingIntent.getBroadcast(this, 0,
                new Intent(DELIVERED).setPackage(getPackageName()),
                        PendingIntent.FLAG_IMMUTABLE);

        ContextCompat.registerReceiver(this, new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String text;
                switch (getResultCode()) {
                    case Activity.RESULT_OK:
                        text = "SMS sent"; break;
                    case SmsManager.RESULT_ERROR_NO_SERVICE:
                        text = "Failed: no service"; break;
                    case SmsManager.RESULT_ERROR_RADIO_OFF:
                        text = "Failed: radio off (airplane mode?)"; break;
                    default:
                        text = "Failed: error " + getResultCode();
                }
                Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
            }
        }, new IntentFilter(SENT), ContextCompat.RECEIVER_NOT_EXPORTED);

        ContextCompat.registerReceiver(this, new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                Toast.makeText(context, "SMS delivered", Toast.LENGTH_SHORT).show();
            }
        }, new IntentFilter(DELIVERED), ContextCompat.RECEIVER_NOT_EXPORTED);

        SmsManager smsManager = SmsManager.getDefault();
        smsManager.sendTextMessage(number.getText().toString(), null,
                message.getText().toString(),
                sentPI, deliveredPI);
    }
}
