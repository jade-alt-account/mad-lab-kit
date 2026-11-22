// phone_app.dart: device sensors and a local notification (run on a phone)
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';

final notifications = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up notifications once, using the app's icon
  await notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  runApp(const PhoneApp());
}

class PhoneApp extends StatelessWidget {
  const PhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red),
      home: const SensorScreen(),
    );
  }
}

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;
  int _shakes = 0;
  DateTime _lastShake = DateTime(2000);

  @override
  void initState() {
    super.initState();
    // Listen to the accelerometer (values in m/s2, including gravity)
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      final force = sqrt(event.x * event.x +
          event.y * event.y +
          event.z * event.z);
      final now = DateTime.now();
      // Much more than gravity (9.8) means a shake; count one per second
      if (force > 25 && now.difference(_lastShake).inSeconds >= 1) {
        _lastShake = now;
        _shakes++;
        if (_shakes % 5 == 0) _notify('You shook the phone $_shakes times!');
      }
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
      });
    }, onError: (_) {
      setState(() => _x = _y = _z = double.nan); // no accelerometer
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // stop the sensor to save battery
    super.dispose();
  }

  Future<void> _notify(String message) async {
    // Android 13 and later: the user must allow notifications first
    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await notifications.show(
      id: 1,
      title: 'Sensor Lab',
      body: message,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'sensor_lab', // channel ID
          'Sensor Lab alerts', // channel name shown in Settings
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String f(double v) => v.isNaN ? '-' : v.toStringAsFixed(1);
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Lab')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Accelerometer (m/s²)',
                style: Theme.of(context).textTheme.titleMedium),
            Text('x: ${f(_x)}   y: ${f(_y)}   z: ${f(_z)}',
                key: const Key('xyz')),
            const SizedBox(height: 16),
            Text('Shakes: $_shakes',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _notify('Hello from the Sensor Lab'),
              child: const Text('Send notification'),
            ),
          ],
        ),
      ),
    );
  }
}
