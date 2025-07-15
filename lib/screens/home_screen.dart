import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/keybox_provider.dart';
import '../widgets/keybox_card.dart';
import 'add_keybox_screen.dart';

import '../utils/backup_restore.dart';

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
            onPressed: () {
              Navigator.pushNamed(context, '/map');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            ListTile(
              title: const Text('View Map'),
              onTap: () {
                Navigator.pushNamed(context, '/map');
              },
            ),
          ],
        ),
      ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/map');
          }
        },
      ),
    );
  }
}
