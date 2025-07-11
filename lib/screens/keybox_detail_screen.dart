import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class KeyBoxDetailScreen extends StatelessWidget {
  final KeyBox keybox;

  const KeyBoxDetailScreen({super.key, required this.keybox});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KeyBoxProvider>(context, listen: false);
    print('KeyBoxDetailScreen created for: ${keybox.currentCode}');
    return Scaffold(
      appBar: AppBar(title: Text(keybox.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            keybox.photoPath.isNotEmpty
                ? Image.file(File(keybox.photoPath), height: 150)
                : const Icon(Icons.lock, size: 100),
            const SizedBox(height: 10),
            Text('Address: ${keybox.address}'),
            const SizedBox(height: 10),
            Text('Description: ${keybox.description}'),
            const SizedBox(height: 10),
            Text('Current Code: ${keybox.currentCode}',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text('Copy Code'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: keybox.currentCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code copied')),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Regenerate Code'),
              onPressed: () {
                provider.updateCode(keybox);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New code generated')),
                );
              },
            ),
            const SizedBox(height: 20),
            QrImageView(
              data:
                  '${keybox.currentCode}\nAddress: ${keybox.address}\nDescription: ${keybox.description}',
              version: QrVersions.auto,
              size: 150,
              gapless: false,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (keybox.latitude != 0 && keybox.longitude != 0) {
                  String googleMapsLink =
                      'https://www.google.com/maps/search/?api=1&query=${keybox.latitude},${keybox.longitude}';
                  Share.share(
                    '${keybox.currentCode}\nAddress: ${keybox.address}\nGoogle Maps: $googleMapsLink\nDescription: ${keybox.description}',
                    subject: 'KeyBox QR Code',
                  );
                } else {
                  Share.share(
                    '${keybox.currentCode}\nAddress: ${keybox.address}\nDescription: ${keybox.description}',
                    subject: 'KeyBox QR Code',
                  );
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Share QR Code'),
            ),
            const SizedBox(height: 20),
            const Text('Previous Codes:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...keybox.previousCodes.reversed.map((c) => Text(c)),
          ],
        ),
      ),
    );
  }
}
