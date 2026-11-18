package com.university.lab04;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    private static final int REQUEST_PICK_CONTACT = 2;
    private TextView greeting;

    // In the first activity: start the second one and wait for a result
    private static final int REQUEST_NAME = 1;

    private void askForName() {
        Intent i = new Intent(this, NameActivity.class);
        startActivityForResult(i, REQUEST_NAME);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_NAME && resultCode == RESULT_OK && data != null) {
            String name = data.getStringExtra("EXTRA_NAME");
            greeting.setText("Hello, " + name);
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        greeting = (TextView) findViewById(R.id.text_greeting);
        final EditText input = (EditText) findViewById(R.id.edit_text);

        // Task 1 (assignment spec): explicit intent with a String extra
        findViewById(R.id.button_next).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String stringData = input.getText().toString();
                Intent intent = new Intent(MainActivity.this, DetailActivity.class);
                intent.putExtra("EXTRA_USER_TEXT", stringData);
                startActivity(intent);
            }
        });
        findViewById(R.id.button_web).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Open a web page in the browser
                Intent web = new Intent(Intent.ACTION_VIEW, Uri.parse("https://www.gcuf.edu.pk"));
                startActivity(web);
            }
        });
        findViewById(R.id.button_dial).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Open the dialer with a number filled in (no permission needed)
                Intent dial = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:5551234"));
                startActivity(dial);
            }
        });
        findViewById(R.id.button_map).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Show a location in the maps app (GCUF, Faisalabad)
                Intent map = new Intent(Intent.ACTION_VIEW,
                        Uri.parse("geo:31.4161,73.0700?z=16"));
                startActivity(map);
            }
        });
        findViewById(R.id.button_pick).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Let the user pick a contact; the result arrives later (see below)
                Intent pick = new Intent(Intent.ACTION_PICK,
                        ContactsContract.Contacts.CONTENT_URI);
                startActivityForResult(pick, REQUEST_PICK_CONTACT);
            }
        });
        findViewById(R.id.button_name).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                askForName();
            }
        });
        findViewById(R.id.button_profile).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendProfile();
            }
        });
    }

    private void sendProfile() {
        // Action: Construct Intent and attach Parcelable Object
        UserProfile user = new UserProfile("Alice", 5);
        Intent intent = new Intent(this, DetailActivity.class);
        intent.putExtra("EXTRA_USER_PROFILE", user);
        startActivity(intent);
    }
}
