import 'package:flutter/material.dart';
import 'package:keybox_manager/widgets/map_screen2.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/keybox_provider.dart';
import '../widgets/keybox_card.dart';
import 'add_keybox_screen.dart';

import '../utils/backup_restore.dart';

import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KeyBox Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              await exportKeyBoxes();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup exported')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await importKeyBoxes();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup imported')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () async {
              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Location services are disabled.')),
                );
                return;
              }
              LocationPermission permission =
                  await Geolocator.checkPermission();
              if (permission == LocationPermission.denied) {
                permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Location permission denied.')),
                  );
                  return;
                }
              }
              if (permission == LocationPermission.deniedForever) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Location permission permanently denied.')),
                );
                return;
              }
              Position position = await Geolocator.getCurrentPosition();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Consumer<KeyBoxProvider>(
                    builder: (context, provider, child) => MapScreen2(
                      initialCenter:
                          LatLng(position.latitude, position.longitude),
                      boxLocations: provider.keyboxes
                          .map((keybox) =>
                              LatLng(keybox.latitude, keybox.longitude))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      /*     drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ), */
      body: CustomScrollView(
        slivers: [
          /* const SliverAppBar(
            pinned: true,
            expandedHeight: 20.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('KeyBoxes'),
            ),
          ), */
          Consumer<KeyBoxProvider>(
            builder: (context, provider, child) {
              final keyboxes = provider.keyboxes;
              if (keyboxes.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No keyboxes added yet.')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final keybox = keyboxes[index];
                    return KeyBoxCard(keybox: keybox, provider: provider);
                  },
                  childCount: keyboxes.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddKeyBoxScreen()),
          );
          if (result == true) {
            // Trigger UI rebuild after adding new keybox
            (context as Element).markNeedsBuild();
          }
        },
      ),
      /*    bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          }
        },
      ), */
    );
  }
}
