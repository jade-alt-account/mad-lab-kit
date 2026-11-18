package com.university.kbonus

import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import androidx.appcompat.app.AppCompatActivity

class ConnectivityActivity : AppCompatActivity() {
    fun check(): Pair<Boolean, Boolean> {
        // Modern Track: is there a working connection, and is it unmetered (e.g. Wi-Fi)?
        val cm = getSystemService(ConnectivityManager::class.java)
        val caps = cm.getNetworkCapabilities(cm.activeNetwork)
        val online = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) == true
        val unmetered = caps?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) == true
        return online to unmetered
    }
}
