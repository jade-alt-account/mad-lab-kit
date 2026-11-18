package com.university.kbonus

import android.os.Looper
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority

class FusedActivity : AppCompatActivity() {
    private fun showPosition(lat: Double, lng: Double) { }

    private val client by lazy { LocationServices.getFusedLocationProviderClient(this) }

    private val callback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            result.lastLocation?.let { showPosition(it.latitude, it.longitude) }
        }
    }

    @Suppress("MissingPermission")
    private fun startUpdates() {
        val request = LocationRequest.Builder(
            Priority.PRIORITY_BALANCED_POWER_ACCURACY, 10_000L   // about every 10 s
        ).build()
        client.requestLocationUpdates(request, callback, Looper.getMainLooper())
    }

    override fun onPause() {
        super.onPause()
        client.removeLocationUpdates(callback)
    }
}
