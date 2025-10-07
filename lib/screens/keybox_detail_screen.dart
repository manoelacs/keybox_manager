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
    // Removed unused provider variable
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
            Consumer<KeyBoxProvider>(
              builder: (context, provider, child) {
                final updatedKeybox = provider.keyboxes.firstWhere(
                  (k) => k.name == keybox.name,
                  orElse: () => keybox,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Code: ${updatedKeybox.currentCode}',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      child: const Text('Copy Code'),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: updatedKeybox.currentCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied')),
                        );
                      },
                    ),
                    ElevatedButton(
                      child: const Text('Regenerate Code'),
                      onPressed: () {
                        provider.updateCode(updatedKeybox);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New code generated')),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QR code stays fixed size
                QrImageView(
                  data:
                      '${keybox.currentCode}\nAddress: ${keybox.address}\nDescription: ${keybox.description}',
                  version: QrVersions.auto,
                  size: 150,
                  gapless: false,
                ),
                const SizedBox(width: 16),
                // Make the button column flexible
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final googleMapsLink = (keybox.latitude != 0 &&
                                  keybox.longitude != 0)
                              ? '\nGoogle Maps: https://www.google.com/maps/search/?api=1&query=${keybox.latitude},${keybox.longitude}'
                              : '';
                          await Share.share(
                            '${keybox.currentCode}\nAddress: ${keybox.address}$googleMapsLink\nDescription: ${keybox.description}',
                            subject: 'KeyBox QR Code',
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share QR Code'),
                      ),
                      Consumer<KeyBoxProvider>(
                        builder: (context, provider, child) {
                          final updatedKeybox = provider.keyboxes.firstWhere(
                            (k) => k.name == keybox.name,
                            orElse: () => keybox,
                          );
                          if (updatedKeybox.videoPath.isNotEmpty) {
                            return ElevatedButton.icon(
                              onPressed: () async {
                                await Share.shareXFiles(
                                  [XFile(updatedKeybox.videoPath)],
                                  text:
                                      'Video for KeyBox: \\${updatedKeybox.name}',
                                  subject: 'KeyBox Location Video',
                                );
                              },
                              icon: const Icon(Icons.video_file),
                              label: const Text('Share Video'),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
