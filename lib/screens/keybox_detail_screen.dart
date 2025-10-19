import 'dart:io';
import 'package:flutter/material.dart';
import 'package:keybox_manager/screens/edit_keybox_screen.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(keybox.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditKeyBoxScreen(keybox: keybox),
                ),
              );
              if (result == true && context.mounted) {
                // Optionally refresh state if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('KeyBox updated')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete',
            onPressed: () async {
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
              if (shouldDelete == true && context.mounted) {
                Provider.of<KeyBoxProvider>(context, listen: false)
                    .deleteKeyBox(keybox);
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Existing Code',
            onPressed: () async {
              String inputValue = '';
              final newCode = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add Existing Code'),
                  content: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter a 4-digit code',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (value) {
                      inputValue =
                          value.length > 4 ? value.substring(0, 4) : value;
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, inputValue),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
              if (newCode != null && newCode.isNotEmpty && context.mounted) {
                Provider.of<KeyBoxProvider>(context, listen: false)
                    .addExistingCode(keybox, newCode);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Code added')),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Image/Icon Card
          Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: keybox.photoPath.isNotEmpty
                ? Image.file(
                    File(keybox.photoPath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Location Info Card
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Location',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    keybox.address,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (keybox.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              size: 18, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              keybox.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Current Code Card
          Consumer<KeyBoxProvider>(
            builder: (context, provider, child) {
              final updatedKeybox = provider.keyboxes.firstWhere(
                (k) => k.name == keybox.name,
                orElse: () => keybox,
              );
              return Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Access Code',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                updatedKeybox.currentCode,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            _CopyCodeButton(code: updatedKeybox.currentCode),
                            const SizedBox(width: 8),
                            _RegenerateCodeButton(keybox: updatedKeybox),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // QR Code & Sharing Card
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_2,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'QR Code & Sharing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: QrImageView(
                          data:
                              '${keybox.currentCode}\nAddress: ${keybox.address}\nDescription: ${keybox.description}',
                          version: QrVersions.auto,
                          size: 140,
                          gapless: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FilledButton.icon(
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
                              icon: const Icon(Icons.share, size: 20),
                              label: const Text('Share'),
                            ),
                            const SizedBox(height: 8),
                            Consumer<KeyBoxProvider>(
                              builder: (context, provider, child) {
                                final updatedKeybox =
                                    provider.keyboxes.firstWhere(
                                  (k) => k.name == keybox.name,
                                  orElse: () => keybox,
                                );
                                final googleMapsLink = (updatedKeybox
                                                .latitude !=
                                            0 &&
                                        updatedKeybox.longitude != 0)
                                    ? '\nGoogle Maps: https://www.google.com/maps/search/?api=1&query=${updatedKeybox.latitude},${updatedKeybox.longitude}'
                                    : '';
                                final shareText =
                                    '${updatedKeybox.currentCode}\nAddress: ${updatedKeybox.address}$googleMapsLink\nDescription: ${updatedKeybox.description} ';

                                if (updatedKeybox.videoPath.isNotEmpty) {
                                  return FilledButton.icon(
                                    onPressed: () async {
                                      await Share.shareXFiles(
                                        [XFile(updatedKeybox.videoPath)],
                                        text: shareText,
                                        subject: 'KeyBox Details & Video',
                                      );
                                    },
                                    icon: const Icon(Icons.share, size: 20),
                                    label: const Text('Share All'),
                                  );
                                } else {
                                  return FilledButton.icon(
                                    onPressed: () async {
                                      await Share.share(
                                        shareText,
                                        subject: 'KeyBox Details',
                                      );
                                    },
                                    icon: const Icon(Icons.share, size: 20),
                                    label: const Text('Share All'),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Previous Codes Section
          if (keybox.previousCodes.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.history,
                            color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Code History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...keybox.previousCodes.reversed.take(5).map((code) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_clock,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                code,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CopyCodeButton extends StatefulWidget {
  final String code;
  const _CopyCodeButton({required this.code});

  @override
  State<_CopyCodeButton> createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<_CopyCodeButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.copy_rounded,
        size: 20,
      ),
      tooltip: 'Copy Code',
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: widget.code));
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Code copied to clipboard'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );
  }
}

class _RegenerateCodeButton extends StatefulWidget {
  final KeyBox keybox;
  const _RegenerateCodeButton({required this.keybox});

  @override
  State<_RegenerateCodeButton> createState() => _RegenerateCodeButtonState();
}

class _RegenerateCodeButtonState extends State<_RegenerateCodeButton> {
  bool _regenerated = false;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: Icon(
        _regenerated ? Icons.check_rounded : Icons.refresh_rounded,
        size: 20,
      ),
      tooltip: 'Regenerate Code',
      onPressed: () {
        Provider.of<KeyBoxProvider>(context, listen: false)
            .updateCode(widget.keybox);
        setState(() => _regenerated = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _regenerated = false);
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('New code generated'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
    );
  }
}
