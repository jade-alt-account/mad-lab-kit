package com.university.lab06;

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
public class Lab06Test {

    @Test
    public void a_prefsSurviveRestart() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.edit_username)).perform(replaceText("Ayesha"), closeSoftKeyboard());
            onView(withId(R.id.button_save)).perform(click());
        }
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.text_greeting)).check(matches(withText("Welcome, Ayesha")));
            Ci.shot("lab06_welcome");
        }
    }

    @Test
    public void b_noteFile() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.edit_note)).perform(replaceText("Line one\nLine two"), closeSoftKeyboard());
            onView(withId(R.id.button_save_note)).perform(click());
            onView(withId(R.id.edit_note)).perform(replaceText(""), closeSoftKeyboard());
            onView(withId(R.id.button_load_note)).perform(click());
            onView(withId(R.id.edit_note)).check(matches(withText("Line one\nLine two\n")));
            Ci.shot("lab06_note");
        }
    }

    @Test
    public void c_settingsScreen() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            openActionBarOverflowOrOptionsMenu(InstrumentationRegistry.getInstrumentation().getTargetContext());
            onView(withText("Settings")).perform(click());
            onView(withText("Dark mode")).check(matches(isDisplayed()));
            Ci.shot("lab06_settings");
            onView(withText("Dark mode")).perform(click());
            Ci.dev().pressBack();
            SystemClock.sleep(1000);
            onView(withId(R.id.text_dark)).check(matches(withText("Dark mode: true")));
        }
    }
}
