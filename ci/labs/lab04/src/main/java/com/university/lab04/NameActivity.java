package com.university.lab04;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import androidx.appcompat.app.AppCompatActivity;

public class NameActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_name);
        final EditText name = (EditText) findViewById(R.id.edit_name);
        findViewById(R.id.button_ok).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finishWithName(name.getText().toString());
            }
        });
    }

    private void finishWithName(String name) {
        Intent result = new Intent();
        result.putExtra("EXTRA_NAME", name);
        setResult(RESULT_OK, result);
        finish();
    }
}
