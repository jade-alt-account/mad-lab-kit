package com.university.lab04;

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
public class Lab04Test {

    private static void launchFresh() {
        Context ctx = ApplicationProvider.getApplicationContext();
        Intent i = ctx.getPackageManager().getLaunchIntentForPackage("com.university.lab04");
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        ctx.startActivity(i);
        Ci.dev().wait(Until.hasObject(By.pkg("com.university.lab04").depth(0)), 8000);
        SystemClock.sleep(1000);
    }

    @Test
    public void a_explicit() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.edit_text)).perform(replaceText("Hello GCUF"), closeSoftKeyboard());
            onView(withId(R.id.button_next)).perform(click());
            onView(withId(R.id.text_detail)).check(matches(withText("Hello GCUF")));
            Ci.shot("lab04_detail");
        }
    }

    private void external(String button, String shotName) {
        launchFresh();
        Ci.click(button);
        SystemClock.sleep(5000);
        String pkg = Ci.foreground();
        Ci.log(button + " opened package: " + pkg);
        Ci.shot(shotName);
        Ci.dev().pressBack();
        SystemClock.sleep(1000);
        Ci.dev().pressBack();
        SystemClock.sleep(1000);
    }

    @Test
    public void b_website() { external("Website", "lab04_web"); }

    @Test
    public void c_dial() { external("Call office", "lab04_dial"); }

    @Test
    public void d_map() { external("Show GCUF", "lab04_map"); }

    @Test
    public void e_pickContact() { external("Pick contact", "lab04_pick"); }

    @Test
    public void f_result() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.button_name)).perform(click());
            onView(withId(R.id.edit_name)).perform(replaceText("Ali"), closeSoftKeyboard());
            onView(withId(R.id.button_ok)).perform(click());
            onView(withId(R.id.text_greeting)).check(matches(withText("Hello, Ali")));
            Ci.shot("lab04_result");
        }
    }

    @Test
    public void g_parcelable() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.button_profile)).perform(click());
            onView(withId(R.id.text_detail)).check(matches(withText("Profile: Alice")));
        }
    }
}
