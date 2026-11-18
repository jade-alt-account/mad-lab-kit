package com.university.labstarter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

// A screen built with Jetpack Compose, for the Modern Track bonus work.
// To open it first, move the MAIN/LAUNCHER intent filter to it in AndroidManifest.xml.
class ComposeActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface {
                    Column(Modifier.padding(16.dp)) {
                        Text("Hello from Jetpack Compose!")
                    }
                }
            }
        }
    }
}
