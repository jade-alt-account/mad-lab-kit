package com.university.jsnippets;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

/** As described under the provider code: an SQLiteOpenHelper with a courses table keyed by _id. */
public class CoursesDbHelper extends SQLiteOpenHelper {
    public CoursesDbHelper(Context context) {
        super(context, "courses.db", null, 1);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        db.execSQL("CREATE TABLE courses (_id INTEGER PRIMARY KEY, title TEXT)");
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS courses");
        onCreate(db);
    }
}
