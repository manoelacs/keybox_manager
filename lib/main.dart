import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:keybox_manager/providers/keybox_provider.dart';
import 'package:provider/provider.dart';
import 'models/keybox.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(KeyBoxAdapter());
  await Hive.openBox<KeyBox>('keyboxes');

  runApp(
    ChangeNotifierProvider(
      create: (_) => KeyBoxProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeyBox Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData.dark(), // Enables dark mode theme
      themeMode: ThemeMode.system, // Uses system theme by default
      home: const HomeScreen(),
    );
  }
}
