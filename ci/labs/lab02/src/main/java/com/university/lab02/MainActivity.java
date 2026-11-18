package com.university.lab02;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RadioGroup;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final EditText name = (EditText) findViewById(R.id.edit_name);
        final CheckBox hostel = (CheckBox) findViewById(R.id.check_hostel);
        final RadioGroup semester = (RadioGroup) findViewById(R.id.radio_semester);
        Button register = (Button) findViewById(R.id.button_register);

        register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String term = semester.getCheckedRadioButtonId() == R.id.radio_fall
                        ? "Fall" : "Spring";
                String message = name.getText().toString() + ", " + term
                        + (hostel.isChecked() ? ", hostel" : ", day scholar");
                Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
            }
        });
    }
}
