import 'package:flutter/material.dart';
import 'package:keybox_manager/screens/map_screen_flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/keybox_provider.dart';
import '../widgets/keybox_card.dart';
import 'add_keybox_screen.dart';
import '../utils/backup_restore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar with search
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            /*  backgroundColor: colorScheme.surface, */
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search keyboxes...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  )
                : const Text('KeyBox Manager'),
            actions: [
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                    });
                  },
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
                Consumer<KeyBoxProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      icon: const Icon(Icons.map_outlined),
                      tooltip: 'View Map',
                      onPressed: provider.keyboxes.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MapScreenFlutterMap(
                                    boxLocations: provider.keyboxes
                                        .map((keybox) => LatLng(
                                            keybox.latitude, keybox.longitude))
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'export') {
                      await exportKeyBoxes();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Backup exported successfully'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } else if (value == 'import') {
                      await importKeyBoxes();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Backup imported successfully'),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.upload_file),
                          SizedBox(width: 12),
                          Text('Export Backup'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'import',
                      child: Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 12),
                          Text('Import Backup'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Summary Stats Card
          Consumer<KeyBoxProvider>(
            builder: (context, provider, child) {
              if (provider.keyboxes.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final totalBoxes = provider.keyboxes.length;
              final boxesWithVideos = provider.keyboxes
                  .where((kb) => kb.videoPath.isNotEmpty)
                  .length;

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatItem(
                                icon: Icons.lock_outline,
                                label: 'Total KeyBoxes',
                                value: totalBoxes.toString(),
                                color: colorScheme.primary),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: colorScheme.primary,
                          ),
                          Expanded(
                            child: _StatItem(
                              icon: Icons.videocam_outlined,
                              label: 'With Videos',
                              value: boxesWithVideos.toString(),
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Section Header
          Consumer<KeyBoxProvider>(
            builder: (context, provider, child) {
              if (provider.keyboxes.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              final filteredCount = provider.keyboxes
                  .where((kb) =>
                      kb.name.toLowerCase().contains(_searchQuery) ||
                      kb.address.toLowerCase().contains(_searchQuery))
                  .length;

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        _searchQuery.isEmpty
                            ? 'All KeyBoxes'
                            : 'Found $filteredCount KeyBox${filteredCount != 1 ? 'es' : ''}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // KeyBox List
          Consumer<KeyBoxProvider>(
            builder: (context, provider, child) {
              final keyboxes = provider.keyboxes
                  .where((kb) =>
                      kb.name.toLowerCase().contains(_searchQuery) ||
                      kb.address.toLowerCase().contains(_searchQuery))
                  .toList();

              if (provider.keyboxes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color:
                                colorScheme.primaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_open_outlined,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No KeyBoxes Yet',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first keybox',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (keyboxes.isEmpty && _searchQuery.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final keybox = keyboxes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: KeyBoxCard(keybox: keybox, provider: provider),
                      );
                    },
                    childCount: keyboxes.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddKeyBoxScreen()),
          );
          if (result == true && mounted) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add KeyBox'),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
