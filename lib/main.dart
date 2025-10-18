import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keybox_manager/providers/keybox_provider.dart';
import 'package:keybox_manager/utils/locations.dart';
import 'package:keybox_manager/theme.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'models/keybox.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen_flutter_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(KeyBoxAdapter());

  var box = await Hive.openBox<KeyBox>('keyboxes');

  if (kDebugMode) {
    print('Hive initialized with box: ${box.name}');
    print('Box name: ${box.name}');
    print('Path: ${box.path}');
    print('Box contains ${box.length} items');
  }

  // Remove old KeyBoxes with default (0.0) latitude/longitude
  final keysToDelete = <dynamic>[];
  for (final entry in box.toMap().entries) {
    if (entry.value.latitude == 0.0 && entry.value.longitude == 0.0) {
      keysToDelete.add(entry.key);
    }
  }

  if (keysToDelete.isNotEmpty) {
    await box.deleteAll(keysToDelete);
    if (kDebugMode) {
      print(
          'Deleted ${keysToDelete.length} old KeyBoxes without location data');
    }
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
      theme: appTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
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
