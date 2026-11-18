package com.university.jsnippets;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;

public class CoursesProvider extends ContentProvider {

    public static final String AUTHORITY = "com.university.courses.provider";
    public static final Uri CONTENT_URI = Uri.parse("content://" + AUTHORITY
            + "/courses");

    private static final int COURSES = 1;      // content://.../courses
    private static final int COURSE_ID = 2;    // content://.../courses/7
    private static final UriMatcher MATCHER = new UriMatcher(UriMatcher.NO_MATCH);
    static {
        MATCHER.addURI(AUTHORITY, "courses", COURSES);
        MATCHER.addURI(AUTHORITY, "courses/#", COURSE_ID);
    }

    private CoursesDbHelper helper;

    @Override
    public boolean onCreate() {
        helper = new CoursesDbHelper(getContext());
        return true;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection,
                        String[] selectionArgs, String sortOrder) {
        SQLiteDatabase db = helper.getReadableDatabase();
        switch (MATCHER.match(uri)) {
            case COURSES:
                return db.query("courses", projection, selection, selectionArgs,
                                null, null, sortOrder);
            case COURSE_ID:
                return db.query("courses", projection, "_id = ?",
                                new String[] { uri.getLastPathSegment() },
                                null, null, sortOrder);
            default:
                throw new IllegalArgumentException("Unknown URI " + uri);
        }
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        long id = helper.getWritableDatabase().insert("courses", null, values);
        getContext().getContentResolver().notifyChange(uri, null);
        return ContentUris.withAppendedId(CONTENT_URI, id);
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection,
                      String[] selectionArgs) {
        return helper.getWritableDatabase().update("courses", values, selection,
                                                   selectionArgs);
    }

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        return helper.getWritableDatabase().delete("courses", selection,
                selectionArgs);
    }

    @Override
    public String getType(Uri uri) {
        return MATCHER.match(uri) == COURSE_ID
                ? "vnd.android.cursor.item/vnd.university.course"
                : "vnd.android.cursor.dir/vnd.university.course";
    }
}
