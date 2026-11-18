package com.university.lab10;

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
public class Lab10Test {

    private static void launchFresh() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab10");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        ctx.startActivity(i);
        Ci.dev().wait(Until.hasObject(By.pkg("com.university.lab10").depth(0)), 8000);
        SystemClock.sleep(1000);
    }

    @Test
    public void a_location() {
        launchFresh();
        Ci.click("Where am I?");
        assertTrue("location permission dialog", Ci.allow());
        // the CI script sends "geo fix 73.0700 31.4161" to the emulator every few seconds
        boolean fix = Ci.dev().wait(Until.hasObject(By.textContains("31.41")), 60000);
        Ci.log("position shown: " + fix);
        SystemClock.sleep(8000);
        Ci.shot("lab10_position");
        UiObject2 pos = Ci.dev().findObject(By.res("com.university.lab10:id/text_position"));
        Ci.log("position text: " + (pos == null ? null : pos.getText()));
        assertTrue("coordinates shown", fix);
    }

    @Test
    public void b_openMaps() {
        launchFresh();
        Ci.click("Open in Maps");
        SystemClock.sleep(5000);
        Ci.log("geo intent opened: " + Ci.foreground());
        Ci.shot("lab10_geo_intent");
        Ci.dev().pressBack();
    }

    @Test
    public void c_mapLibre() {
        launchFresh();
        Ci.click("Map (MapLibre)");
        SystemClock.sleep(15000);
        Ci.shot("lab10_maplibre");
        assertEquals("map screen did not crash", "com.university.lab10", Ci.foreground());
    }
}
