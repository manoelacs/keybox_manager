import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class KeyBoxMap extends StatelessWidget {
  final List<LatLng> markers;
  final LatLng initialLocation;
  final bool pickMode;
  final Function(LatLng)? onLocationPicked;

  const KeyBoxMap({
    super.key,
    required this.markers,
    required this.initialLocation,
    this.pickMode = false,
    this.onLocationPicked,
  });

  @override
  Widget build(BuildContext context) {
    LatLng? pickedLocation;
    return Scaffold(
      appBar: AppBar(
        title: Text(pickMode ? 'Pick Location' : 'KeyBoxes Map'),
        actions: pickMode
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (pickedLocation != null && onLocationPicked != null) {
                      onLocationPicked!(pickedLocation!);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please pick a location')),
                      );
                    }
                  },
                ),
              ]
            : null,
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return FlutterMap(
            options: MapOptions(
              initialCenter: initialLocation,
              initialZoom: 15,
              onTap: pickMode
                  ? (tapPosition, latlng) {
                      setState(() {
                        pickedLocation = latlng;
                      });
                    }
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  ...markers.map((location) => Marker(
                        point: location,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                      )),
                  if (pickMode && pickedLocation != null)
                    Marker(
                      point: pickedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on,
                          color: Colors.blue, size: 40),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
