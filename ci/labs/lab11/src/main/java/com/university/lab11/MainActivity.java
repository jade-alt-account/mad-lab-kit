package com.university.lab11;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Xml;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    private TextView resultView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        resultView = (TextView) findViewById(R.id.resultView);
        findViewById(R.id.button_fetch).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // AndroidManifest.xml needs: <uses-permission
                // android:name="android.permission.INTERNET" />
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        HttpURLConnection connection = null;
                        try {
                            URL url = new URL("https://jsonplaceholder.typicode.com/users/1");
                            connection = (HttpURLConnection) url.openConnection();
                            connection.setConnectTimeout(10000);
                            connection.setReadTimeout(10000);

                            int status = connection.getResponseCode();
                            if (status != HttpURLConnection.HTTP_OK) {
                                showResult("Server returned HTTP " + status);
                                return;
                            }
                            BufferedReader reader = new BufferedReader(
                                    new InputStreamReader(connection.getInputStream(), "UTF-8"));
                            StringBuilder body = new StringBuilder();
                            String line;
                            while ((line = reader.readLine()) != null) {
                                body.append(line);
                            }
                            reader.close();

                            JSONObject json = new JSONObject(body.toString());
                            showResult(json.getString("name") + " <" + json.getString("email")
                                    + ">");
                        } catch (IOException | JSONException e) {
                            showResult("Request failed: " + e.getMessage());
                        } finally {
                            if (connection != null) {
                                connection.disconnect();
                            }
                        }
                    }
                }).start();
            }
        });
        findViewById(R.id.button_fetch99).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // AndroidManifest.xml needs: <uses-permission
                // android:name="android.permission.INTERNET" />
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        HttpURLConnection connection = null;
                        try {
                            URL url = new URL("https://jsonplaceholder.typicode.com/users/99");
                            connection = (HttpURLConnection) url.openConnection();
                            connection.setConnectTimeout(10000);
                            connection.setReadTimeout(10000);

                            int status = connection.getResponseCode();
                            if (status != HttpURLConnection.HTTP_OK) {
                                showResult("Server returned HTTP " + status);
                                return;
                            }
                            BufferedReader reader = new BufferedReader(
                                    new InputStreamReader(connection.getInputStream(), "UTF-8"));
                            StringBuilder body = new StringBuilder();
                            String line;
                            while ((line = reader.readLine()) != null) {
                                body.append(line);
                            }
                            reader.close();

                            JSONObject json = new JSONObject(body.toString());
                            showResult(json.getString("name") + " <" + json.getString("email")
                                    + ">");
                        } catch (IOException | JSONException e) {
                            showResult("Request failed: " + e.getMessage());
                        } finally {
                            if (connection != null) {
                                connection.disconnect();
                            }
                        }
                    }
                }).start();
            }
        });
        findViewById(R.id.button_notes).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // AndroidManifest.xml needs: <uses-permission
                // android:name="android.permission.INTERNET" />
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        HttpURLConnection connection = null;
                        try {
                            URL url = new URL("http://10.0.2.2:3000/api/notes");
                            connection = (HttpURLConnection) url.openConnection();
                            connection.setConnectTimeout(10000);
                            connection.setReadTimeout(10000);

                            int status = connection.getResponseCode();
                            if (status != HttpURLConnection.HTTP_OK) {
                                showResult("Server returned HTTP " + status);
                                return;
                            }
                            BufferedReader reader = new BufferedReader(
                                    new InputStreamReader(connection.getInputStream(), "UTF-8"));
                            StringBuilder body = new StringBuilder();
                            String line;
                            while ((line = reader.readLine()) != null) {
                                body.append(line);
                            }
                            reader.close();

                            JSONArray array = new JSONArray(body.toString());
                            StringBuilder titles = new StringBuilder();
                            for (int i = 0; i < array.length(); i++) {
                                titles.append(array.getJSONObject(i).getString("title")).append('\n');
                            }
                            showResult(titles.toString());
                        } catch (IOException | JSONException e) {
                            showResult("Request failed: " + e.getMessage());
                        } finally {
                            if (connection != null) {
                                connection.disconnect();
                            }
                        }
                    }
                }).start();
            }
        });
        findViewById(R.id.button_xml).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    parseXml("<lectures><title>Intents</title><title>Services</title><title>Web services</title></lectures>");
                } catch (XmlPullParserException | IOException e) {
                    resultView.setText("XML error: " + e.getMessage());
                }
            }
        });
    }

    private void parseXml(String xmlText) throws XmlPullParserException, IOException {
        List<String> titles = new ArrayList<String>();
        XmlPullParser parser = Xml.newPullParser();
        parser.setInput(new StringReader(xmlText));

        int event = parser.getEventType();
        while (event != XmlPullParser.END_DOCUMENT) {
            if (event == XmlPullParser.START_TAG && "title".equals(parser.getName())) {
                titles.add(parser.nextText());
            }
            event = parser.next();
        }
        resultView.setText(titles.toString());
        Toast.makeText(this, titles.toString(), Toast.LENGTH_SHORT).show();
    }

    private void showResult(final String text) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                resultView.setText(text);
            }
        });
    }
}
