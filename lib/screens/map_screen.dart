import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/keybox_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  void _moveCameraToCurrentLocation() {
    final provider = context.read<KeyBoxProvider>();
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(provider.currentLatitude, provider.currentLongitude),
        ),
      );
    }
  }

  void _moveCameraToMarkersBounds(Set<Marker> markers) {
    if (_mapController != null && markers.isNotEmpty) {
      LatLngBounds bounds = _calculateBounds(markers);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50), // Padding around the bounds
      );
    }
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double? southWestLat, southWestLng, northEastLat, northEastLng;

    for (var marker in markers) {
      double lat = marker.position.latitude;
      double lng = marker.position.longitude;

      if (southWestLat == null || lat < southWestLat) southWestLat = lat;
      if (southWestLng == null || lng < southWestLng) southWestLng = lng;
      if (northEastLat == null || lat > northEastLat) northEastLat = lat;
      if (northEastLng == null || lng > northEastLng) northEastLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat!, southWestLng!),
      northeast: LatLng(northEastLat!, northEastLng!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboxes = Provider.of<KeyBoxProvider>(context).keyboxes;

    Set<Marker> markers = keyboxes
        .where((keybox) => keybox.latitude != 0 && keybox.longitude != 0)
        .map((keybox) {
      return Marker(
        markerId: MarkerId(keybox.name),
        position: LatLng(keybox.latitude, keybox.longitude),
        infoWindow: InfoWindow(
          title: keybox.name,
          snippet: keybox.address,
        ),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KeyBox Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveCameraToCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: () => _moveCameraToMarkersBounds(markers),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _moveCameraToMarkersBounds(
              markers); // Automatically move camera to markers' bounds
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            context.read<KeyBoxProvider>().currentLatitude,
            context.read<KeyBoxProvider>().currentLongitude,
          ),
          zoom: 2,
        ),
        markers: markers,
      ),
    );
  }
}
