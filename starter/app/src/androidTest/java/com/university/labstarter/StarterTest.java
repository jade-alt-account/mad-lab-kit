package com.university.labstarter;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;

import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Checks that the starter app opens and shows its welcome text. */
@RunWith(AndroidJUnit4.class)
public class StarterTest {
    @Rule
    public ActivityScenarioRule<MainActivity> rule = new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void showsWelcomeText() {
        onView(withId(R.id.text_welcome))
                .check(matches(isDisplayed()))
                .check(matches(withText("Welcome to Mobile Application Development!")));
    }
}
