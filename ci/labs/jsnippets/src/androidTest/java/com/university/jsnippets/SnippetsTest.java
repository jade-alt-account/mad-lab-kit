package com.university.jsnippets;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.Espresso.openActionBarOverflowOrOptionsMenu;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.closeSoftKeyboard;
import static androidx.test.espresso.action.ViewActions.longClick;
import static androidx.test.espresso.action.ViewActions.replaceText;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static org.hamcrest.Matchers.containsString;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.SystemClock;

import androidx.test.core.app.ActivityScenario;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiObject2;
import androidx.test.uiautomator.Until;

import com.university.ci.Ci;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.MethodSorters;

@RunWith(AndroidJUnit4.class)
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class SnippetsTest {

    @Test
    public void a_provider() {
        Context ctx = ApplicationProvider.getApplicationContext();
        android.content.ContentValues v = new android.content.ContentValues();
        v.put("title", "Mobile Application Development");
        android.net.Uri row = ctx.getContentResolver().insert(CoursesProvider.CONTENT_URI, v);
        Ci.log("provider insert -> " + row);
        android.database.Cursor c = ctx.getContentResolver().query(row, null, null, null, null);
        assertTrue(c != null && c.moveToFirst());
        assertEquals("Mobile Application Development", c.getString(c.getColumnIndexOrThrow("title")));
        c.close();
        String fromShell = Ci.sh("content query --uri content://com.university.courses.provider/courses");
        Ci.log("content query from another process: " + fromShell);
        assertTrue(fromShell.contains("Mobile Application Development"));
    }

    @Test
    public void b_crud() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            s.onActivity(a -> { a.crud(); a.prefs(); a.connectivity(); });
        }
    }
}
