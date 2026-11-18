package com.university.lab01;

import android.app.Activity;
import android.app.Application;
import android.content.res.TypedArray;
import android.os.Build;
import android.os.Bundle;
import android.view.View;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

/**
 * Part of the starter project: do not delete.
 *
 * Android 15 and later draw an app's screens behind the status bar, the Action Bar and the
 * navigation bar ("edge to edge") when the app targets Android 15 or newer, as the starter does.
 * This class adds the right amount of empty space around every screen, so that the layouts
 * in the handbook look the same on every phone. You never need to call it: the manifest names
 * it in android:name of the application element.
 */
public class LabApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        if (Build.VERSION.SDK_INT < 35) {
            return;   // older Android versions keep screens clear of the bars by themselves
        }
        registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks() {
            @Override
            public void onActivityPostCreated(Activity activity, Bundle savedInstanceState) {
                keepClearOfBars(activity);
            }
            @Override public void onActivityCreated(Activity a, Bundle b) { }
            @Override public void onActivityStarted(Activity a) { }
            @Override public void onActivityResumed(Activity a) { }
            @Override public void onActivityPaused(Activity a) { }
            @Override public void onActivityStopped(Activity a) { }
            @Override public void onActivitySaveInstanceState(Activity a, Bundle b) { }
            @Override public void onActivityDestroyed(Activity a) { }
        });
    }

    private static void keepClearOfBars(final Activity activity) {
        View content = activity.findViewById(android.R.id.content);
        if (content == null) {
            return;
        }
        ViewCompat.setOnApplyWindowInsetsListener(content, (v, insets) -> {
            Insets bars = insets.getInsets(WindowInsetsCompat.Type.systemBars()
                    | WindowInsetsCompat.Type.displayCutout());
            int top = bars.top;
            if (activity instanceof AppCompatActivity) {
                ActionBar bar = ((AppCompatActivity) activity).getSupportActionBar();
                if (bar != null && bar.isShowing()) {
                    top += actionBarHeight(activity);
                }
            }
            v.setPadding(bars.left, top, bars.right, bars.bottom);
            return insets;
        });
        ViewCompat.requestApplyInsets(content);
    }

    private static int actionBarHeight(Activity activity) {
        TypedArray a = activity.obtainStyledAttributes(new int[] { androidx.appcompat.R.attr.actionBarSize });
        int height = a.getDimensionPixelSize(0, 0);
        a.recycle();
        return height;
    }
}
