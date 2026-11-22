# patch_android.py: the same Android settings as the student build.yml
from pathlib import Path
g = Path('android/app/build.gradle.kts')
s = g.read_text()
# the notifications plugin needs Android 17 (API 37) to compile
s = s.replace('compileSdk = flutter.compileSdkVersion',
              'compileSdk = maxOf(flutter.compileSdkVersion, 37)')
if 'isCoreLibraryDesugaringEnabled' not in s:
    s = s.replace('compileOptions {', 'compileOptions {\n'
                  '        isCoreLibraryDesugaringEnabled = true', 1)
    s += ('\ndependencies {\n    coreLibraryDesugaring('
          '"com.android.tools:desugar_jdk_libs:2.1.4")\n}\n')
g.write_text(s)
m = Path('android/app/src/main/AndroidManifest.xml')
t = m.read_text()
if 'POST_NOTIFICATIONS' not in t:
    t = t.replace('<application', '<uses-permission android:name='
                  '"android.permission.POST_NOTIFICATIONS"/>\n'
                  '    <application', 1)
    m.write_text(t)
