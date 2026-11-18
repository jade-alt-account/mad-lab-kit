package com.university.lab08;

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
public class Lab08Test {

    private static void launchFresh() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab08");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        ctx.startActivity(i);
        Ci.dev().wait(Until.hasObject(By.pkg("com.university.lab08").depth(0)), 8000);
        SystemClock.sleep(1000);
    }

    @Test
    public void a_anr() {
        launchFresh();
        Ci.allow();
        Ci.click("Slow (main thread)");
        SystemClock.sleep(300);
        Ci.dev().findObject(By.text("+1")).click();
        Ci.dev().findObject(By.text("+1")).click();
        SystemClock.sleep(6500);
        Ci.shot("lab08_frozen");
        boolean anr = Ci.dev().hasObject(By.textContains("isn't responding")) || Ci.dev().hasObject(By.textContains("not responding"));
        Ci.log("ANR dialog visible: " + anr);
        UiObject2 wait = Ci.dev().findObject(By.textContains("Wait"));
        if (wait != null) wait.click();
        SystemClock.sleep(4000);
        Ci.shot("lab08_after_freeze");
    }

    @Test
    public void b_background() {
        launchFresh();
        Ci.click("Slow (background)");
        Ci.click("+1");
        Ci.click("+1");
        Ci.click("+1");
        boolean responsive = Ci.dev().hasObject(By.text("3"));
        Ci.log("counter at 3 during background work: " + responsive);
        Ci.shot("lab08_working");
        assertTrue("screen responsive", responsive);
        assertTrue("Done after the sleep", Ci.waitText("Done", 12000));
        Ci.shot("lab08_done");
    }

    @Test
    public void c_foregroundService() {
        launchFresh();
        Ci.allow();
        Ci.sh("logcat -c");
        Ci.click("Start counter");
        SystemClock.sleep(3000);
        Ci.dev().pressHome();
        SystemClock.sleep(20000);
        String ticks = Ci.sh("logcat -d -s CounterService:D");
        int n = ticks.split("tick").length - 1;
        Ci.log("ticks after 20 s minimized: " + n);
        Ci.dev().openNotification();
        boolean notif = Ci.waitText("Counter running", 5000);
        Ci.shot("lab08_service_notification");
        Ci.dev().pressBack();
        assertTrue("service notification", notif);
        assertTrue("ticks continue while minimized", n >= 15);
        launchFresh();
        Ci.click("Stop counter");
        SystemClock.sleep(3000);
        int last1 = lastTick();
        SystemClock.sleep(4000);
        int last2 = lastTick();
        Ci.log("last tick 3 s after stop: " + last1 + ", 4 s later: " + last2);
        assertEquals("ticks stop", last1, last2);
    }

    private static int lastTick() {
        java.util.regex.Matcher m = java.util.regex.Pattern.compile("tick (\\d+)").matcher(Ci.sh("logcat -d -s CounterService:D"));
        int last = -1;
        while (m.find()) last = Integer.parseInt(m.group(1));
        return last;
    }

    @Test
    public void d_powerReceiver() {
        launchFresh();
        Ci.sh("dumpsys battery unplug");
        SystemClock.sleep(1500);
        Ci.sh("dumpsys battery set ac 1");
        boolean toast = Ci.waitText("Charger connected", 4000);
        Ci.shot("lab08_charger");
        Ci.log("charger toast seen: " + toast);
        Ci.sh("dumpsys battery reset");
    }
}
