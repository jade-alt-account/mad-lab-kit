package com.university.labstarter

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

// A screen built with an XML layout (res/layout/activity_main.xml)
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
