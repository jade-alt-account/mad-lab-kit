// apps_test.dart: checks every lab app of the handbook
import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gomal_mad_labs/hello_app.dart' as hello;
import 'package:gomal_mad_labs/bmi_app.dart' as bmi;
import 'package:gomal_mad_labs/navigation_app.dart' as nav;
import 'package:gomal_mad_labs/notes_app.dart' as notes;
import 'package:gomal_mad_labs/async_app.dart' as work;
import 'package:gomal_mad_labs/api_app.dart' as api;
import 'package:gomal_mad_labs/firebase_app.dart' as fb;

void main() {
  testWidgets('hello: the button counts taps', (t) async {
    await t.pumpWidget(const hello.HelloApp());
    expect(find.text('0 times'), findsOneWidget);
    await t.tap(find.byIcon(Icons.add));
    await t.tap(find.byIcon(Icons.add));
    await t.pump();
    expect(find.text('2 times'), findsOneWidget);
  });

  test('bmi: logic', () {
    expect(bmi.bmi(70, 175).toStringAsFixed(1), '22.9');
    expect(bmi.category(22.9), 'Normal');
    expect(bmi.category(17), 'Underweight');
    expect(bmi.category(31), 'Obese');
  });

  testWidgets('bmi: valid and invalid input', (t) async {
    await t.pumpWidget(const bmi.BmiApp());
    await t.enterText(find.byKey(const Key('weight')), '70');
    await t.enterText(find.byKey(const Key('height')), '175');
    await t.tap(find.text('Calculate'));
    await t.pump();
    expect(find.text('BMI 22.9: Normal'), findsOneWidget);
    await t.enterText(find.byKey(const Key('height')), 'abc');
    await t.tap(find.text('Calculate'));
    await t.pump();
    expect(find.text('Please enter valid numbers'), findsOneWidget);
  });

  testWidgets('navigation: ID out, quantity back, tabs', (t) async {
    await t.pumpWidget(const nav.ShopApp());
    await t.tap(find.text('Calculator'));
    await t.pumpAndSettle();
    expect(find.text('Price: Rs 1800'), findsOneWidget);
    await t.tap(find.byIcon(Icons.add));
    await t.pump();
    expect(find.text('Add to cart (Rs 3600)'), findsOneWidget);
    await t.tap(find.text('Add to cart (Rs 3600)'));
    await t.pumpAndSettle();
    expect(find.text('Added 2 x Calculator'), findsOneWidget);
    await t.tap(find.byIcon(Icons.shopping_cart));
    await t.pumpAndSettle();
    expect(find.text('Items in cart: 2'), findsOneWidget);
    expect(nav.findProduct(99), isNull);
  });

  testWidgets('notes: loads, adds and saves', (t) async {
    SharedPreferences.setMockInitialValues({
      'notes': ['Buy milk']
    });
    await t.pumpWidget(const notes.NotesApp());
    await t.pumpAndSettle();
    expect(find.text('Buy milk'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Lab 2 report');
    await t.tap(find.byIcon(Icons.save));
    await t.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('notes'), ['Buy milk', 'Lab 2 report']);
    expect(find.text('Notes (2)'), findsOneWidget);
  });

  test('async: countPrimes', () {
    expect(work.countPrimes(100), 25);
    expect(work.countPrimes(100000), 9592);
  });

  testWidgets('async: download does not block', (t) async {
    await t.pumpWidget(const work.AsyncApp());
    await t.tap(find.text('1. Download'));
    await t.pump();
    expect(find.text('Downloading...'), findsOneWidget);
    await t.pump(const Duration(seconds: 3));
    expect(find.text('Downloaded 120 records'), findsOneWidget);
  });

  testWidgets('api: shows users, and an error offline', (t) async {
    final ok = MockClient((req) async {
      expect(req.url.toString(),
          'https://jsonplaceholder.typicode.com/users');
      return http.Response(
          jsonEncode([
            {
              'name': 'Leanne Graham',
              'email': 'Sincere@april.biz',
              'address': {'city': 'Gwenborough'}
            }
          ]),
          200);
    });
    await t.pumpWidget(api.ApiApp(client: ok));
    await t.pumpAndSettle();
    expect(find.text('Leanne Graham'), findsOneWidget);
    expect(find.text('Sincere@april.biz - Gwenborough'), findsOneWidget);

    final offline = MockClient((req) async => throw Exception('offline'));
    await t.pumpWidget(api.ApiApp(client: offline, key: UniqueKey()));
    await t.pumpAndSettle();
    expect(find.textContaining('Could not load users'), findsOneWidget);
  });

  test('firebase: sign-up, save and load use the right requests', () async {
    final seen = <String>[];
    final notesDb = <String, dynamic>{};
    final client = MockClient((req) async {
      seen.add('${req.method} ${req.url}');
      if (req.url.host == 'identitytoolkit.googleapis.com') {
        final body = jsonDecode(req.body);
        if (body['password'] == 'wrong') {
          return http.Response(
              jsonEncode({
                'error': {'message': 'INVALID_LOGIN_CREDENTIALS'}
              }),
              400);
        }
        return http.Response(
            jsonEncode({'idToken': 'TOKEN', 'localId': 'UID1'}), 200);
      }
      if (req.method == 'POST') {
        notesDb['-N${notesDb.length}'] = jsonDecode(req.body);
        return http.Response(jsonEncode({'name': '-N0'}), 200);
      }
      return http.Response(jsonEncode(notesDb), 200);
    });
    final s = fb.CloudService(client);
    await expectLater(s.signIn('ali@student.pk', 'wrong'),
        throwsA(predicate((e) => '$e'.contains('INVALID_LOGIN'))));
    await s.signIn('ali@student.pk', 'secret123', newAccount: true);
    expect(s.userId, 'UID1');
    await s.addNote('First cloud note');
    expect(await s.loadNotes(), ['First cloud note']);
    expect(seen[1], contains('accounts:signUp?key='));
    expect(seen[2], endsWith('/notes/UID1.json?auth=TOKEN'));
  });
}
