package com.university.lab09;

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
public class Lab09Test {

    private static void launchFresh() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab09");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        ctx.startActivity(i);
        Ci.dev().wait(Until.hasObject(By.pkg("com.university.lab09").depth(0)), 8000);
        SystemClock.sleep(1000);
    }

    private void external(String button, String shotName) {
        launchFresh();
        Ci.click(button);
        SystemClock.sleep(5000);
        Ci.log(button + " opened package: " + Ci.foreground());
        Ci.shot(shotName);
        Ci.dev().pressBack();
        SystemClock.sleep(800);
        Ci.dev().pressBack();
        SystemClock.sleep(800);
    }

    @Test
    public void a_viaMessages() { external("Via Messages", "lab09_via_messages"); }

    @Test
    public void b_direct() {
        launchFresh();
        Ci.click("Send directly");
        assertTrue("SEND_SMS dialog", Ci.allow());
        SystemClock.sleep(1200);
        Ci.shot("lab09_sent");
        SystemClock.sleep(2500);
        Ci.shot("lab09_delivered");
        assertEquals("app still running", "com.university.lab09", Ci.foreground());
    }

    @Test
    public void c_dial() { external("Dial", "lab09_dial"); }

    @Test
    public void d_email() { external("E-mail", "lab09_email"); }
}
