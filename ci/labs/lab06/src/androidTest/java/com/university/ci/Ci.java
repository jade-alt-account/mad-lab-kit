package com.university.ci;

import android.os.SystemClock;
import android.util.Log;

import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.UiObject2;
import androidx.test.uiautomator.Until;

import java.io.IOException;
import java.util.regex.Pattern;

/** Small helpers shared by the lab tests: shell, screenshots, permission dialogs, log lines. */
public final class Ci {
    private Ci() { }

    public static UiDevice dev() {
        return UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    }

    public static String sh(String cmd) {
        try {
            return dev().executeShellCommand(cmd);
        } catch (IOException e) {
            return "ERROR " + e;
        }
    }

    /** Saves a screenshot to /sdcard/Download/ci/<name>.png; the CI script pulls the folder. */
    public static void shot(String name) {
        SystemClock.sleep(700);
        sh("mkdir -p /sdcard/Download/ci");
        sh("screencap -p /sdcard/Download/ci/" + name + ".png");
        log("screenshot " + name);
    }

    public static void log(String msg) {
        Log.i("LABCI", msg);
    }

    /** Taps the allow button of a runtime-permission dialog, if one appears. */
    public static boolean allow() {
        UiObject2 b = dev().wait(Until.findObject(By.res(Pattern.compile(
                "com.android.permissioncontroller:id/permission_allow_(foreground_only_)?button"))), 6000);
        if (b == null) {
            log("no permission dialog");
            return false;
        }
        log("permission dialog: tapping " + b.getText());
        b.click();
        SystemClock.sleep(800);
        return true;
    }

    public static boolean waitText(String text, long ms) {
        boolean found = dev().wait(Until.hasObject(By.text(Pattern.compile("(?is).*" + Pattern.quote(text) + ".*"))), ms);
        log("waitText '" + text + "': " + found);
        return found;
    }

    public static void click(String text) {
        UiObject2 o = dev().wait(Until.findObject(By.text(Pattern.compile("(?i)" + Pattern.quote(text)))), 5000);
        if (o == null) throw new AssertionError("no view with text " + text);
        o.click();
    }

    public static String foreground() {
        return dev().getCurrentPackageName();
    }
}
