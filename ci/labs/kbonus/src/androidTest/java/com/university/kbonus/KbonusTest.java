package com.university.kbonus;

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
public class KbonusTest {

    @Test
    public void a_composeCounter() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            Ci.click("Update State");
            Ci.click("Update State");
            assertTrue(Ci.waitText("Taps: 2", 3000));
            try { Ci.dev().setOrientationLeft(); SystemClock.sleep(2500); } catch (Exception e) { throw new RuntimeException(e); }
            boolean kept = Ci.waitText("Taps: 2", 3000);
            Ci.shot("kbonus_compose_rotated");
            try { Ci.dev().setOrientationNatural(); SystemClock.sleep(1500); } catch (Exception ignored) { }
            assertTrue("rememberSaveable keeps the count across rotation", kept);
        }
    }

    @Test
    public void b_room() throws Exception {
        Context ctx = ApplicationProvider.getApplicationContext();
        AppDatabase db = androidx.room.Room.inMemoryDatabaseBuilder(ctx, AppDatabase.class).build();
        Ci.log("room db built: " + db.userDao());
        db.close();
    }
}
