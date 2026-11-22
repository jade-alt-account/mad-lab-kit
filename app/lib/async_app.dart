// async_app.dart: slow work on the UI thread freezes the app; async does not
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const AsyncApp());

// CPU-heavy work: count the prime numbers up to `limit`.
// It is a top-level function so that compute() can run it in an isolate.
int countPrimes(int limit) {
  var count = 0;
  for (var n = 2; n <= limit; n++) {
    var isPrime = true;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) count++;
  }
  return count;
}

class AsyncApp extends StatelessWidget {
  const AsyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.purple),
      home: const WorkScreen(),
    );
  }
}

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  static const limit = 3000000;
  String _status = 'Ready';

  // 1. Waiting for the network: asynchronous, the UI stays responsive
  Future<void> _download() async {
    setState(() => _status = 'Downloading...');
    await Future.delayed(const Duration(seconds: 3)); // a slow server
    setState(() => _status = 'Downloaded 120 records');
  }

  // 2. Heavy calculation ON the UI thread: the whole app freezes
  void _onUiThread() {
    final watch = Stopwatch()..start();
    final primes = countPrimes(limit);
    setState(() => _status =
        'UI thread: $primes primes in ${watch.elapsedMilliseconds} ms');
  }

  // 3. Heavy calculation in a background isolate (on phones)
  Future<void> _inBackground() async {
    setState(() => _status = 'Working in the background...');
    final watch = Stopwatch()..start();
    final primes = await compute(countPrimes, limit);
    if (!mounted) return;
    setState(() => _status =
        'Background: $primes primes in ${watch.elapsedMilliseconds} ms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Threads and Async')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(), // stops if the UI freezes
            const SizedBox(height: 24),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: _download, child: const Text('1. Download')),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: _onUiThread,
                child: const Text('2. Count primes on UI thread')),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: _inBackground,
                child: const Text('3. Count primes in background')),
          ],
        ),
      ),
    );
  }
}
