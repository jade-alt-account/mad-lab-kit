package com.university.lab06;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.preference.PreferenceManager;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;

public class MainActivity extends AppCompatActivity {

    private EditText note;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        final EditText username = (EditText) findViewById(R.id.edit_username);
        final TextView greeting = (TextView) findViewById(R.id.text_greeting);
        note = (EditText) findViewById(R.id.edit_note);

        // Step 3: read the saved name
        String name = getSharedPreferences("settings", MODE_PRIVATE).getString("username", "Guest");
        greeting.setText("Welcome, " + name);

        findViewById(R.id.button_save).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getSharedPreferences("settings", MODE_PRIVATE).edit()
                        .putString("username", username.getText().toString()).apply();
                greeting.setText("Welcome, " + username.getText().toString());
            }
        });
        findViewById(R.id.button_save_note).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    FileOutputStream out = openFileOutput("notes.txt", MODE_PRIVATE);
                    out.write(note.getText().toString().getBytes("UTF-8"));
                    out.close();
                } catch (IOException e) {
                    Log.e("Files", "Could not write notes.txt", e);
                }
            }
        });
        findViewById(R.id.button_load_note).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    FileInputStream in = openFileInput("notes.txt");
                    BufferedReader reader = new BufferedReader(new InputStreamReader(in,
                            "UTF-8"));
                    StringBuilder text = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) { text.append(line).append('\n'); }
                    reader.close();
                    note.setText(text.toString());
                } catch (IOException e) {
                    Log.e("Files", "Could not read notes.txt", e);
                }
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        // Task 2: show the dark-mode setting's value on the main screen
        boolean dark = PreferenceManager.getDefaultSharedPreferences(this).getBoolean("dark_mode", false);
        ((TextView) findViewById(R.id.text_dark)).setText("Dark mode: " + dark);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        menu.add("Settings");
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        startActivity(new Intent(this, SettingsActivity.class));
        return true;
    }
}
