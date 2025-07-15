import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;
  final LatLng initialLocation;

  const LocationPicker({
    super.key,
    required this.onLocationPicked,
    required this.initialLocation,
  });

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _pickedLocation;

  void _onMapTapped(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
    widget.onLocationPicked(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_pickedLocation != null) {
                widget.onLocationPicked(_pickedLocation!);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please pick a location')),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialLocation,
          zoom: 15,
        ),
        onTap: _onMapTapped,
        markers: _pickedLocation != null
            ? {
                Marker(
                  markerId: const MarkerId('pickedLocation'),
                  position: _pickedLocation!,
                ),
              }
            : {},
      ),
      /* floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationPicker(
                onLocationPicked: widget.onLocationPicked,
                initialLocation: widget.initialLocation,
              ),
            ),
          );
        },
        label: const Text('From Map'),
        icon: const Icon(Icons.map),
      ), */
    );
  }
}
