package com.university.lab07;

import android.Manifest;
import android.content.ContentValues;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    private static final int REQUEST_CONTACTS = 7;
    private FeedReaderDbHelper helper;
    private EditText nameField;
    private ListView list;
    private ListView contactList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        nameField = (EditText) findViewById(R.id.edit_name);
        list = (ListView) findViewById(R.id.list_names);
        contactList = (ListView) findViewById(R.id.list_contacts);
        helper = new FeedReaderDbHelper(this);
        loadList();

        findViewById(R.id.button_add).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SQLiteDatabase db = helper.getWritableDatabase();
                ContentValues values = new ContentValues();
                values.put("name", nameField.getText().toString());
                long newId = db.insert("users", null, values);
                loadList();
            }
        });
        findViewById(R.id.button_contacts).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                readContactsWithPermission();
            }
        });
    }

    // Step 3: query all rows into an ArrayList<String> and set an ArrayAdapter
    private void loadList() {
        ArrayList<String> names = new ArrayList<String>();
        Cursor c = helper.getReadableDatabase().query("users", new String[] { "name" },
                null, null, null, null, "id");
        try {
            while (c.moveToNext()) {
                names.add(c.getString(0));
            }
        } finally {
            c.close();
        }
        list.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1, names));
    }

    private void readContacts() {
        ArrayList<String> contactNames = new ArrayList<String>();
        Cursor cursor = getContentResolver().query(
                ContactsContract.Contacts.CONTENT_URI, null, null, null, null);
        if (cursor != null) {
            try {
                int nameColumn = cursor.getColumnIndexOrThrow(
                        ContactsContract.Contacts.DISPLAY_NAME);
                while (cursor.moveToNext()) {
                    String name = cursor.getString(nameColumn);
                    if (name != null) { contactNames.add(name); }
                }
            } finally {
                cursor.close();   // runs even when there are no rows or an exception occurs
            }
        }
        contactList.setAdapter(new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, contactNames));
        Toast.makeText(this, contactNames.size() + " contacts", Toast.LENGTH_SHORT).show();
    }

    private void readContactsWithPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS)
                == PackageManager.PERMISSION_GRANTED) {
            readContacts();
        } else {
            ActivityCompat.requestPermissions(this,
                    new String[] { Manifest.permission.READ_CONTACTS }, REQUEST_CONTACTS);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_CONTACTS && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            readContacts();
        } else {
            Toast.makeText(this, "Contacts permission denied", Toast.LENGTH_SHORT).show();
        }
    }
}
