// hello_app.dart: a first Flutter app, showing an app's main components
import 'package:flutter/material.dart';

void main() {
  runApp(const HelloApp());
}

// The root widget: app-wide configuration (title, theme, first screen)
class HelloApp extends StatelessWidget {
  const HelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello Gomal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const CounterScreen(),
    );
  }
}

// A screen with state: data that changes while the app runs
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _taps = 0; // the data

  // The application logic: what happens when the button is pressed
  void _addTap() {
    setState(() {
      _taps++;
    });
  }

  // The user interface: what the screen looks like for the current data
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My First App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pressed the button'),
            Text(
              '$_taps times',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTap,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
