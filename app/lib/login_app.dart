// login_app.dart: a login screen with validation, to be widget-tested
import 'package:material_ui/material_ui.dart';

void main() => runApp(const LoginApp());

bool isValidEmail(String s) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => DashboardScreen(email: _email.text.trim())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('email'),
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) =>
                  isValidEmail(v!.trim()) ? null : 'Enter a valid e-mail',
            ),
            TextFormField(
              key: const Key('password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (v) =>
                  v!.length >= 8 ? null : 'At least 8 characters',
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('login'),
              onPressed: _submit,
              child: const Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(child: Text('Welcome, $email')),
    );
  }
}
