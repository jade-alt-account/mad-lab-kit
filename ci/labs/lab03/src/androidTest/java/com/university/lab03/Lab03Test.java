package com.university.lab03;

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
public class Lab03Test {

    @Test
    public void a_menu() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            Ci.shot("lab03_actionbar");
            boolean search = Ci.dev().hasObject(By.desc("Search")) || Ci.dev().hasObject(By.text("Search"));
            Ci.log("search action visible in bar: " + search);
            openActionBarOverflowOrOptionsMenu(InstrumentationRegistry.getInstrumentation().getTargetContext());
            onView(withText("Settings")).check(matches(isDisplayed()));
            Ci.shot("lab03_overflow");
            onView(withText("Settings")).perform(click());
            Ci.shot("lab03_settings_toast");
            assertTrue("search icon in the action bar", search);
        }
    }

    @Test
    public void b_rotation() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            for (int i = 0; i < 5; i++) onView(withId(R.id.button_add)).perform(click());
            onView(withId(R.id.text_count)).check(matches(withText("5")));
            try {
                Ci.dev().setOrientationLeft();
                SystemClock.sleep(3000);
                Ci.shot("lab03_landscape");
                onView(withId(R.id.text_count)).check(matches(withText("5")));
                int orient = Ci.dev().getDisplayRotation();
                Ci.log("rotation after setOrientationLeft: " + orient);
            } catch (android.os.RemoteException e) {
                throw new RuntimeException(e);
            } finally {
                try { Ci.dev().setOrientationNatural(); } catch (Exception ignored) { }
                SystemClock.sleep(2000);
            }
            onView(withId(R.id.text_count)).check(matches(withText("5")));
        }
    }
}
