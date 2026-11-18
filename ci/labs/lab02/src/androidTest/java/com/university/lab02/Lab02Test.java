package com.university.lab02;

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
public class Lab02Test {

    @Test
    public void a_registerToast() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.edit_name)).perform(replaceText("Sara"), closeSoftKeyboard());
            onView(withId(R.id.radio_spring)).perform(click());
            Ci.shot("lab02_form");
            onView(withId(R.id.button_register)).perform(click());
            Ci.shot("lab02_toast");
            onView(withId(R.id.check_hostel)).perform(click());
            onView(withId(R.id.radio_fall)).perform(click());
            onView(withId(R.id.button_register)).perform(click());
            Ci.shot("lab02_toast_hostel");
        }
    }

    @Test
    public void b_listView() {
        try (ActivityScenario<MainActivity2> s = ActivityScenario.launch(MainActivity2.class)) {
            onView(withText("Database Systems")).check(matches(isDisplayed())).perform(click());
            Ci.shot("lab02_list_toast");
        }
    }

    @Test
    public void c_codeUi() {
        try (ActivityScenario<CodeActivity> s = ActivityScenario.launch(CodeActivity.class)) {
            onView(withText("Created in code")).check(matches(isDisplayed()));
            onView(withText("Tap me")).check(matches(isDisplayed()));
            Ci.shot("lab02_code_ui");
        }
    }
}
