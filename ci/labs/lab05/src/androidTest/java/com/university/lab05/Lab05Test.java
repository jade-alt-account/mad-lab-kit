package com.university.lab05;

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
public class Lab05Test {

    private static void launchFresh() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab05");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        ctx.startActivity(i);
        Ci.dev().wait(Until.hasObject(By.pkg("com.university.lab05").depth(0)), 8000);
        SystemClock.sleep(1000);
    }

    @Test
    public void a_fragmentPermissionNotification() {
        Ci.sh("cmd notification cancel_all 2>/dev/null");
        launchFresh();
        boolean dialog = Ci.allow();
        Ci.log("API " + Build.VERSION.SDK_INT + " notification permission dialog shown: " + dialog);
        if (Build.VERSION.SDK_INT >= 33) assertTrue("permission dialog on Android 13+", dialog);
        Ci.shot("lab05_after_permission");
        Ci.click("Send to activity");
        Ci.log("fragment toast seen: " + Ci.waitText("Data from Fragment!", 3000));
        Ci.shot("lab05_fragment_toast");
        Ci.click("Show notification");
        SystemClock.sleep(1500);
        Ci.dev().openNotification();
        boolean shown = Ci.waitText("New Message Alert", 8000);
        Ci.shot("lab05_notification");
        assertTrue("notification shown", shown);
        Ci.dev().pressHome();
        SystemClock.sleep(1000);
        Ci.dev().openNotification();
        UiObject2 n = Ci.dev().wait(Until.findObject(By.text("New Message Alert")), 5000);
        assertTrue("notification still there", n != null);
        n.click();
        SystemClock.sleep(3000);
        String fg = Ci.foreground();
        Ci.log("after tapping notification, foreground = " + fg);
        Ci.shot("lab05_after_tap");
        assertEquals("com.university.lab05", fg);
    }
}
