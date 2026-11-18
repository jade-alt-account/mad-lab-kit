package com.university.lab01;

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
public class Lab01Test {

    private static void launchFresh() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab01");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        ctx.startActivity(i);
        Ci.dev().wait(Until.hasObject(By.pkg("com.university.lab01").depth(0)), 8000);
        SystemClock.sleep(1000);
    }

    private static String lifecycleLog() {
        return Ci.sh("logcat -d -s LifecycleDemo:D");
    }

    @Test
    public void a_textAndLifecycle() {
        Ci.sh("logcat -c");
        launchFresh();
        assertTrue("welcome text", Ci.waitText("Runtime initialization complete.", 5000));
        Ci.shot("lab01_text");
        Ci.log("A open:\n" + lifecycleLog());

        Ci.sh("logcat -c");
        Ci.dev().pressHome();
        SystemClock.sleep(2000);
        Ci.log("B home:\n" + lifecycleLog());

        Ci.sh("logcat -c");
        Ci.dev().pressRecentApps();
        SystemClock.sleep(2000);
        Ci.shot("lab01_recents");
        // return to the app the way a student does: tap its card (fall back to the launcher icon intent)
        launchReturn();
        Ci.log("C return:\n" + lifecycleLog());

        Ci.sh("logcat -c");
        try {
            Ci.dev().setOrientationLeft();
            SystemClock.sleep(3000);
            Ci.shot("lab01_rotated");
            Ci.dev().setOrientationNatural();
            SystemClock.sleep(3000);
        } catch (Exception e) {
            Ci.log("rotation failed " + e);
        }
        Ci.log("D rotate (and back):\n" + lifecycleLog());

        Ci.sh("logcat -c");
        Ci.dev().pressBack();
        SystemClock.sleep(3000);
        Ci.log("E back (API " + Build.VERSION.SDK_INT + "):\n" + lifecycleLog());
    }

    private static void launchReturn() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab01");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        ctx.startActivity(i);
        SystemClock.sleep(2500);
    }
}
