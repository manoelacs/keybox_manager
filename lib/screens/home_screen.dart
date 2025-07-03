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
        ],
      ),
      body: Consumer<KeyBoxProvider>(
        builder: (context, provider, child) {
          final keyboxes = provider.keyboxes;
          if (keyboxes.isEmpty) {
            return const Center(child: Text('No keyboxes added yet.'));
          }
          return ListView.builder(
            itemCount: keyboxes.length,
            itemBuilder: (context, index) {
              final keybox = keyboxes[index];
              return KeyBoxCard(keybox: keybox, provider: provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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
    );
  }
}
