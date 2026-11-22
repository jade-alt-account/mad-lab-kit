// firebase_app.dart: cloud sign-in and online storage with Firebase (REST)
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

// Paste your own project's values here (Firebase console, Lab 3)
const apiKey = 'PASTE-YOUR-WEB-API-KEY';
const databaseUrl = 'https://PASTE-YOUR-PROJECT-default-rtdb.firebaseio.com';

void main() => runApp(const CloudApp());

// The cloud layer: Firebase Authentication and Realtime Database
class CloudService {
  CloudService(this.client);
  final http.Client client;
  String? idToken, userId; // set after a successful sign-in

  // Sign up (newAccount: true) or sign in with e-mail and password
  Future<void> signIn(String email, String password,
      {bool newAccount = false}) async {
    final action = newAccount ? 'signUp' : 'signInWithPassword';
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/'
        'accounts:$action?key=$apiKey');
    final response = await client.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error']['message']); // e.g. EMAIL_EXISTS
    }
    idToken = data['idToken'];
    userId = data['localId'];
  }

  Uri _notesUrl() =>
      Uri.parse('$databaseUrl/notes/$userId.json?auth=$idToken');

  // Add a note under this user's own path in the database
  Future<void> addNote(String text) async {
    final response = await client.post(_notesUrl(),
        body: jsonEncode({'text': text, 'time': DateTime.now().toString()}));
    if (response.statusCode != 200) throw Exception(response.body);
  }

  // Read all of this user's notes
  Future<List<String>> loadNotes() async {
    final response = await client.get(_notesUrl());
    if (response.statusCode != 200) throw Exception(response.body);
    final data = jsonDecode(response.body);
    if (data == null) return [];
    return [for (final note in (data as Map).values) note['text'] as String];
  }
}

class CloudApp extends StatelessWidget {
  const CloudApp({super.key, this.client});
  final http.Client? client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.amber),
      home: CloudScreen(service: CloudService(client ?? http.Client())),
    );
  }
}

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key, required this.service});
  final CloudService service;

  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _note = TextEditingController();
  List<String> _notes = [];
  String _message = 'Not signed in';

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      setState(() => _message = 'Error: $e');
    }
  }

  Future<void> _signIn(bool newAccount) => _run(() async {
        await widget.service.signIn(_email.text.trim(), _password.text,
            newAccount: newAccount);
        final notes = await widget.service.loadNotes();
        setState(() {
          _notes = notes;
          _message = 'Signed in as ${_email.text.trim()}';
        });
      });

  Future<void> _addNote() => _run(() async {
        if (widget.service.idToken == null || _note.text.isEmpty) return;
        await widget.service.addNote(_note.text);
        final notes = await widget.service.loadNotes();
        setState(() => _notes = notes);
        _note.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Notes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              key: const Key('email'),
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail')),
          TextField(
              key: const Key('password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          Row(children: [
            TextButton(
                onPressed: () => _signIn(true), child: const Text('Sign up')),
            TextButton(
                onPressed: () => _signIn(false), child: const Text('Sign in')),
          ]),
          Text(_message),
          const Divider(),
          TextField(
              key: const Key('note'),
              controller: _note,
              decoration: const InputDecoration(labelText: 'New note')),
          TextButton(onPressed: _addNote, child: const Text('Save to cloud')),
          for (final n in _notes) ListTile(title: Text(n)),
        ],
      ),
    );
  }
}
