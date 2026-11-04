// This is a basic Flutter widget test for the login screen.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:myapp/core/auth_helper.dart';
import 'package:myapp/core/database_helper.dart';
import 'package:myapp/core/profile_helper.dart';
import 'package:myapp/core/profile_image_helper.dart';
import 'package:myapp/core/settings_helper.dart';
import 'package:myapp/main.dart';
import 'package:myapp/widgets/glow_background.dart';
import 'package:myapp/widgets/interactive.dart';

void main() {
  setUpAll(() {
    GlowBackground.animate = false;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  testWidgets('Login screen renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('TaskManager'), findsOneWidget);
    expect(find.text('Login to access your dashboard'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Language setting switches UI texts', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsHelper.init();

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('TaskManager'), findsOneWidget);

    await SettingsHelper.setLanguage('Spanish');
    await tester.pumpAndSettle();

    expect(find.text('TaskManager'), findsOneWidget);

    await SettingsHelper.setLanguage('English');
    await tester.pumpAndSettle();

    expect(find.text('TaskManager'), findsOneWidget);
  });

  testWidgets('Register creates account and returns to login', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsHelper.init();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Already have an account?'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full Name'),
      'Jane Doe',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'jane',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm Password'),
      'secret123',
    );
    await tester.ensureVisible(
      find.widgetWithText(PrimaryButton, 'Create Account'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PrimaryButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('TaskManager'), findsOneWidget);
    final usernameField = tester.widget<TextField>(
      find.widgetWithText(TextField, 'Username'),
    );
    expect(usernameField.controller!.text, 'jane');

    expect(await AuthHelper.login('jane', 'secret123'), isTrue);
    expect(await AuthHelper.usernameExists('jane'), isTrue);
  });

  test('Profiles are isolated per account', () async {
    SharedPreferences.setMockInitialValues({});
    await ProfileHelper.saveProfile(
      const ProfileData(
        fullName: 'Jane Doe',
        username: 'jane',
        email: 'jane@example.com',
        phone: '555-0101',
        location: 'Manila',
      ),
    );
    await ProfileHelper.saveProfile(
      const ProfileData(
        fullName: 'Bob Smith',
        username: 'bob',
        email: 'bob@example.com',
        phone: '555-0202',
        location: 'Paris',
      ),
    );

    final jane = await ProfileHelper.loadProfile(username: 'jane');
    final bob = await ProfileHelper.loadProfile(username: 'bob');

    expect(jane.fullName, 'Jane Doe');
    expect(jane.location, 'Manila');
    expect(bob.fullName, 'Bob Smith');
    expect(bob.location, 'Paris');
  });

  test('Legacy profile defaults still load for admin', () async {
    SharedPreferences.setMockInitialValues({});
    final profile = await ProfileHelper.loadProfile(username: 'admin');
    expect(profile.fullName, 'Arold M. Reyes');
    expect(profile.username, 'admin');
  });

  test('Multiple accounts can log in independently', () async {
    SharedPreferences.setMockInitialValues({});
    await AuthHelper.register(
      UserAccount(
        username: 'jane',
        password: 'pw123456',
        fullName: 'Jane Doe',
      ),
    );
    await AuthHelper.register(
      UserAccount(
        username: 'bob',
        password: 'pw654321',
        fullName: 'Bob Smith',
      ),
    );

    expect(await AuthHelper.usernameExists('jane'), isTrue);
    expect(await AuthHelper.login('jane', 'pw123456'), isTrue);
    expect(await AuthHelper.login('bob', 'pw654321'), isTrue);
    expect(await AuthHelper.login('jane', 'wrong'), isFalse);

    final usernames = await AuthHelper.usernames();
    expect(usernames, containsAll(['jane', 'bob', 'admin']));
  });

  test('Profile images are isolated per account', () async {
    SharedPreferences.setMockInitialValues({});
    await ProfileImageHelper.saveImage('jane', '/tmp/jane.png');
    await ProfileImageHelper.saveImage('bob', '/tmp/bob.png');

    expect(await ProfileImageHelper.getImagePath('jane'), '/tmp/jane.png');
    expect(await ProfileImageHelper.getImagePath('bob'), '/tmp/bob.png');

    await ProfileImageHelper.saveImage('jane', '/tmp/jane2.png');
    expect(await ProfileImageHelper.getImagePath('jane'), '/tmp/jane2.png');
    expect(await ProfileImageHelper.getImagePath('bob'), '/tmp/bob.png');
  });

  test('Change password is isolated per account', () async {
    SharedPreferences.setMockInitialValues({});
    await AuthHelper.register(
      UserAccount(
        username: 'jane',
        password: 'pw123456',
        fullName: 'Jane Doe',
      ),
    );
    await AuthHelper.register(
      UserAccount(
        username: 'bob',
        password: 'pw654321',
        fullName: 'Bob Smith',
      ),
    );

    await AuthHelper.updatePassword('jane', 'newJanePw');

    expect(await AuthHelper.login('jane', 'newJanePw'), isTrue);
    expect(await AuthHelper.login('jane', 'pw123456'), isFalse);
    expect(await AuthHelper.verifyPassword('jane', 'newJanePw'), isTrue);
    expect(await AuthHelper.login('bob', 'pw654321'), isTrue);
    expect(await AuthHelper.verifyPassword('bob', 'pw654321'), isTrue);
  });

  test('Forgot password is isolated per account', () async {
    SharedPreferences.setMockInitialValues({});
    await AuthHelper.register(
      UserAccount(
        username: 'jane',
        password: 'pw123456',
        fullName: 'Jane Doe',
      ),
    );
    await AuthHelper.register(
      UserAccount(
        username: 'bob',
        password: 'pw654321',
        fullName: 'Bob Smith',
      ),
    );

    await AuthHelper.updatePassword('jane', 'resetPw');

    expect(await AuthHelper.login('jane', 'resetPw'), isTrue);
    expect(await AuthHelper.login('jane', 'pw123456'), isFalse);
    expect(await AuthHelper.login('bob', 'pw654321'), isTrue);
    expect(await AuthHelper.verifyPassword('bob', 'resetPw'), isFalse);
  });

  testWidgets('Due date survives picking in the add-task dialog', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await SettingsHelper.init();

    await tester.runAsync(() async {
      final db = await DatabaseHelper.instance.database;
      await db.delete('tasks');
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Username'),
      'admin',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'admin123',
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Login'));
      await Future<void>.delayed(const Duration(milliseconds: 2600));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);

    await tester.tap(find.text('New Task'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Task Title'),
      'Buy milk',
    );
    expect(find.text('No due date'), findsOneWidget);

    await tester.tap(find.text('No due date'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('No due date'), findsNothing);
    final now = DateTime.now();
    expect(
      find.textContaining('${now.year}'),
      findsWidgets,
    );

    await tester.runAsync(() async {
      await tester.tap(find.text('Add Task'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump();
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.textContaining('${now.year}'), findsWidgets);

    final tasks = await tester.runAsync(
      () => DatabaseHelper.instance.getAllTasks(username: 'admin'),
    ) ?? <Task>[];
    expect(tasks, hasLength(1));
    expect(tasks.first.dueDate, isNotNull);
    expect(tasks.first.dueDate!.year, now.year);
    expect(tasks.first.dueDate!.month, now.month);
    expect(tasks.first.dueDate!.hour, 9);
  });
}