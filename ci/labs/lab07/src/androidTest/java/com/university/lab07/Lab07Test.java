package com.university.lab07;

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
public class Lab07Test {

    @Test
    public void a_insertAndList() {
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.edit_name)).perform(replaceText("Ayesha"), closeSoftKeyboard());
            onView(withId(R.id.button_add)).perform(click());
            onView(withId(R.id.edit_name)).perform(replaceText("Bilal"), closeSoftKeyboard());
            onView(withId(R.id.button_add)).perform(click());
        }
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withText("Ayesha")).check(matches(isDisplayed()));
            onView(withText("Bilal")).check(matches(isDisplayed()));
            Ci.shot("lab07_list");
        }
    }

    @Test
    public void b_contacts() {
        // add two test contacts the way a student would be told to (here through the shell)
        // one contact with a name and one without (a phone can have both)
        Ci.log("insert contact: " + Ci.sh("content insert --uri content://com.android.contacts/raw_contacts --bind account_type:n: --bind account_name:n:"));
        Ci.log("insert contact: " + Ci.sh("content insert --uri content://com.android.contacts/raw_contacts --bind account_type:n: --bind account_name:n:"));
        Ci.log("name: " + Ci.sh("content insert --uri content://com.android.contacts/data --bind raw_contact_id:i:2 --bind mimetype:s:vnd.android.cursor.item/name --bind data1:s:Test_Student"));
        Ci.log("contacts: " + Ci.sh("content query --uri content://com.android.contacts/contacts --projection display_name"));
        try (ActivityScenario<MainActivity> s = ActivityScenario.launch(MainActivity.class)) {
            onView(withId(R.id.button_contacts)).perform(click());
            boolean dialog = Ci.allow();
            assertTrue("contacts permission dialog", dialog);
            SystemClock.sleep(1500);
            Ci.shot("lab07_contacts");
            Ci.log("named contact listed: " + Ci.waitText("Test_Student", 3000));
        }
    }
}
