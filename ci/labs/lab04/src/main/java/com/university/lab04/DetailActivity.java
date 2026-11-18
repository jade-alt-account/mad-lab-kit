package com.university.lab04;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class DetailActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_detail);
        TextView text = (TextView) findViewById(R.id.text_detail);
        String fromMain = getIntent().getStringExtra("EXTRA_USER_TEXT");
        UserProfile receivedUser = getIntent().getParcelableExtra("EXTRA_USER_PROFILE");
        if (receivedUser != null) {
            text.setText("Profile: " + receivedUser.getUsername());
        } else {
            text.setText(fromMain);
        }
    }
}
