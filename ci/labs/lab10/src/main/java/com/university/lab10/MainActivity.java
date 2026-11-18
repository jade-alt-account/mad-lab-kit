package com.university.lab10;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private static final int REQUEST_LOCATION = 10;
    private LocationManager lm;
    private LocationListener listener;
    private TextView positionView;
    private double lastLat, lastLng;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        positionView = (TextView) findViewById(R.id.text_position);
        findViewById(R.id.button_where).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_FINE_LOCATION)
                        == PackageManager.PERMISSION_GRANTED) {
                    startUpdates();
                } else {
                    ActivityCompat.requestPermissions(MainActivity.this,
                            new String[] { Manifest.permission.ACCESS_FINE_LOCATION }, REQUEST_LOCATION);
                }
            }
        });
        findViewById(R.id.button_open_maps).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Uri geo = Uri.parse("geo:" + lastLat + "," + lastLng + "?q=" + lastLat + "," + lastLng + "(My position)");
                startActivity(new Intent(Intent.ACTION_VIEW, geo));
            }
        });
        findViewById(R.id.button_map).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startActivity(new Intent(MainActivity.this, MapActivity.class));
            }
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == REQUEST_LOCATION && grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startUpdates();
        }
    }

    @SuppressWarnings("MissingPermission")
    private void startUpdates() {
        lm = (LocationManager) getSystemService(Context.LOCATION_SERVICE);

        listener = new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                showPosition(location.getLatitude(), location.getLongitude());
            }
            @Override
            public void onStatusChanged(String provider, int status, Bundle extras) { }
            @Override
            public void onProviderEnabled(String provider) { }
            @Override
            public void onProviderDisabled(String provider) { }
        };

        // GPS updates no more often than every 10 seconds, and only after moving 50
        // metres
        lm.requestLocationUpdates(LocationManager.GPS_PROVIDER, 10000, 50, listener);
    }

    private void showPosition(final double lat, final double lng) {
        lastLat = lat;
        lastLng = lng;
        positionView.setText(lat + ", " + lng);
        // Part A step 4: the address, looked up on a background thread
        new Thread(new Runnable() {
            @Override
            public void run() {
                String text;
                try {
                    List<Address> found = new Geocoder(MainActivity.this, Locale.getDefault())
                            .getFromLocation(lat, lng, 1);
                    text = (found != null && !found.isEmpty()) ? found.get(0).getAddressLine(0) : "No address found";
                } catch (Exception e) {
                    text = "Geocoder failed: " + e.getMessage();
                }
                final String address = text;
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        positionView.setText(lat + ", " + lng + "\n" + address);
                    }
                });
            }
        }).start();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (lm != null && listener != null) {
            lm.removeUpdates(listener);
        }
    }
}
