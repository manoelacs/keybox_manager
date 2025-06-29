import 'dart:io';
import 'package:flutter/material.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import '../screens/edit_keybox_screen.dart';
import '../screens/keybox_detail_screen.dart';

class KeyBoxCard extends StatefulWidget {
  final KeyBox keybox;
  final KeyBoxProvider provider;

  const KeyBoxCard({required this.keybox, required this.provider, super.key});

  @override
  _KeyBoxCardState createState() => _KeyBoxCardState();
}

class _KeyBoxCardState extends State<KeyBoxCard> {
  bool showCode = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: widget.keybox.photoPath.isNotEmpty
            ? Image.file(File(widget.keybox.photoPath), width: 50)
            : const Icon(Icons.lock),
        title: Text(widget.keybox.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.keybox.address),
            Row(
              children: [
                Text(showCode
                    ? 'Code: ${widget.keybox.currentCode}'
                    : 'Code: ••••'),
                IconButton(
                  icon:
                      Icon(showCode ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      showCode = !showCode;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditKeyBoxScreen(keybox: widget.keybox),
                ),
              );
              if (result == true) setState(() {});
            } else if (value == 'delete') {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete KeyBox'),
                  content: const Text(
                      'Are you sure you want to delete this KeyBox?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true) {
                widget.provider.deleteKeyBox(widget.keybox);
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KeyBoxDetailScreen(keybox: widget.keybox),
            ),
          );
        },
      ),
    );
  }
}
