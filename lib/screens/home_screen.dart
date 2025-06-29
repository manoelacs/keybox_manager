import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/keybox_provider.dart';
import 'add_keybox_screen.dart';
import 'keybox_detail_screen.dart';
import '../models/keybox.dart';
import '../utils/backup_restore.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KeyBoxProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KeyBox Manager'),
          actions: [
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: () async {
                await exportKeyBoxes();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup exported')));
              },
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                await importKeyBoxes();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup imported')));
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
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: keybox.photoPath.isNotEmpty
                        ? Image.file(File(keybox.photoPath), width: 50)
                        : const Icon(Icons.lock),
                    title: Text(keybox.name),
                    subtitle:
                        Text('${keybox.address}\nCode: ${keybox.currentCode}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        provider.updateCode(keybox);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KeyBoxDetailScreen(keybox: keybox),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddKeyBoxScreen()),
            );
          },
        ),
      ),
    );
  }
}
