// api_app.dart: loading data from a web API (JSON over HTTPS)
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ApiApp());

class User {
  User(this.name, this.email, this.city);
  final String name, email, city;

  // Convert one JSON object from the server into a Dart object
  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['name'], json['email'], json['address']['city']);
}

// The networking layer: one function that calls the API
Future<List<User>> fetchUsers(http.Client client) async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/users');
  final response =
      await client.get(url).timeout(const Duration(seconds: 10));
  if (response.statusCode != 200) {
    throw Exception('Server error ${response.statusCode}');
  }
  final List<dynamic> list = jsonDecode(response.body);
  return list.map((item) => User.fromJson(item)).toList();
}

class ApiApp extends StatelessWidget {
  const ApiApp({super.key, this.client});
  final http.Client? client; // tests can pass in a fake client

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: UsersScreen(client: client ?? http.Client()),
    );
  }
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key, required this.client});
  final http.Client client;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<User>> _users;

  @override
  void initState() {
    super.initState();
    _users = fetchUsers(widget.client);
  }

  void _retry() => setState(() => _users = fetchUsers(widget.client));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users from the API')),
      body: FutureBuilder<List<User>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load users. Check the internet.'),
                  TextButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            );
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(child: Text(users[i].name[0])),
              title: Text(users[i].name),
              subtitle: Text('${users[i].email} - ${users[i].city}'),
            ),
          );
        },
      ),
    );
  }
}
