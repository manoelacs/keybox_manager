import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/keybox_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboxes = Provider.of<KeyBoxProvider>(context).keyboxes;

    Set<Marker> markers = keyboxes
        .where((keybox) => keybox.latitude != 0 && keybox.longitude != 0)
        .map((keybox) {
      return Marker(
        markerId: MarkerId(keybox.name),
        position: LatLng(keybox.latitude!, keybox.longitude!),
        infoWindow: InfoWindow(
          title: keybox.name,
          snippet: keybox.address,
        ),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('KeyBox Locations')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0.0, 0.0),
          zoom: 2,
        ),
        markers: markers,
      ),
    );
  }
}
