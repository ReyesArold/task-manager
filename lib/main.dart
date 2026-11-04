import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'core/app_translations.dart';
import 'core/notification_helper.dart';
import 'core/settings_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsHelper.init();
  await NotificationHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        SettingsHelper.darkMode,
        SettingsHelper.language,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: 'TaskManager Login',
          debugShowCheckedModeBanner: false,
          locale: AppTranslations.localeFor(SettingsHelper.language.value),
          supportedLocales: AppTranslations.supportedLocales,
          localizationsDelegates: AppTranslations.delegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.blueAccent),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
            ),
          ),
          themeMode: SettingsHelper.darkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const LoginPage(),
        );
      },
    );
  }
}