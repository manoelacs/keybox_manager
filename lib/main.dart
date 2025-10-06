import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:keybox_manager/providers/keybox_provider.dart';
import 'package:keybox_manager/screens/map_screen.dart';
import 'package:keybox_manager/utils/locations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'models/keybox.dart';
import 'screens/home_screen.dart';
import 'widgets/map_screen2.dart'; // Import the MapScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(KeyBoxAdapter());
  var existingBox =
      Hive.isBoxOpen('keyboxes') ? Hive.box<KeyBox>('keyboxes') : null;
  if (existingBox != null) {
    await existingBox.close();
  }

  var encryptionKey = Hive.generateSecureKey();

  var box = await Hive.openBox<KeyBox>(
    'keyboxes',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  if (kDebugMode) {
    print('Hive initialized with box: ${box.name}');
    print('Box name: ${box.name}');
    print('Path: ${box.path}');
  }

  if (box.isEmpty) {
    // Initialize with default values if the box is empty
    box.put(
        'default',
        KeyBox(
          name: 'Default KeyBox',
          currentCode: '0000',
          address: 'No Address',
          description: 'Default Description',
          photoPath: '',
          latitude: 0.0,
          longitude: 0.0,
        ));
  }

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
      routes: {
        '/': (context) => const HomeScreen(),
        '/map': (context) => FutureBuilder(
              future: getCurrentLocation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final box = Hive.box<KeyBox>('keyboxes');
                  return MapScreen2(
                    initialCenter: snapshot.data as LatLng,
                    boxLocations: box.values
                        .map((keybox) =>
                            LatLng(keybox.latitude, keybox.longitude))
                        .toList(),
                  );
                }
              },
            ),
      },
    );
  }
}
