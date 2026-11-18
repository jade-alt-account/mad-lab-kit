package com.university.kbonus

import android.Manifest
import android.os.Bundle
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity

class PermissionActivity : AppCompatActivity() {
    private val requestContacts =
        registerForActivityResult(ActivityResultContracts
                .RequestPermission()) { granted ->
            if (granted) readContacts() else showPermissionDenied()
        }

    private fun readContacts() { Toast.makeText(this, "granted", Toast.LENGTH_SHORT).show() }
    private fun showPermissionDenied() { Toast.makeText(this, "denied", Toast.LENGTH_SHORT).show() }

    fun onShowContactsClicked() {
        requestContacts.launch(Manifest.permission.READ_CONTACTS)
    }
}
