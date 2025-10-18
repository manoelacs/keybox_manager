import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:keybox_manager/providers/keybox_provider.dart';

import 'package:keybox_manager/utils/locations.dart';
import 'package:keybox_manager/theme.dart'; // Import AppTheme
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'models/keybox.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen_flutter_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(KeyBoxAdapter());

  // Removed box closing logic to preserve older keyboxes

  var box = await Hive.openBox<KeyBox>('keyboxes');
  // Clear box to remove legacy data and fix null value errors
  await box.clear();

  if (kDebugMode) {
    print('Hive initialized with box: ${box.name}');
    print('Box name: ${box.name}');
    print('Path: ${box.path}');
  }

  /*  if (box.isEmpty) {
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
          previousCodes: [],
          videoPath: '',
        ));
  } */

  // Remove the default item after the first real KeyBox is added
  box.watch().listen((event) {
    if (box.length > 1 && box.containsKey('default')) {
      box.delete('default');
    }
  });

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
      theme: appTheme, // Use the custom light theme
      darkTheme: appDarkTheme, // Use the custom dark theme
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
                  return MapScreenFlutterMap(
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

// Optional: Open Hive box with encryption using a persistent key
// Usage: var box = await openEncryptedHiveBox<KeyBox>('keyboxes');
// Requires flutter_secure_storage and dart:convert
Future<Box<T>> openEncryptedHiveBox<T>(String boxName) async {
  // Uncomment these lines and add dependencies if you want encryption
  // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  // import 'dart:convert';
  // final secureStorage = FlutterSecureStorage();
  // const keyName = 'hive_keybox_manager_key';
  // String? base64Key = await secureStorage.read(key: keyName);
  // List<int> encryptionKey;
  // if (base64Key == null) {
  //   encryptionKey = Hive.generateSecureKey();
  //   await secureStorage.write(key: keyName, value: base64Encode(encryptionKey));
  // } else {
  //   encryptionKey = base64Decode(base64Key);
  // }
  // return await Hive.openBox<T>(
  //   boxName,
  //   encryptionCipher: HiveAesCipher(encryptionKey),
  // );
  throw UnimplementedError(
      'Encryption is not enabled. Uncomment and add dependencies to use.');
}
