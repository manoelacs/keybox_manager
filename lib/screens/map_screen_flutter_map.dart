import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreenFlutterMap extends StatefulWidget {
  final List<LatLng> boxLocations;
  const MapScreenFlutterMap({super.key, required this.boxLocations});

  @override
  State<MapScreenFlutterMap> createState() => _MapScreenFlutterMapState();
}

class _MapScreenFlutterMapState extends State<MapScreenFlutterMap> {
  LatLng? _center;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() {
          _error = 'Location services are disabled.';
          _loading = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Location permission denied.';
          _loading = false;
        });
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission permanently denied.';
          _loading = false;
        });
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to get location: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap (flutter_map)'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(child: Text(_error!))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _center ?? const LatLng(0.0, 0.0),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.keybox_manager',
                    ),
                    MarkerLayer(
                      markers: widget.boxLocations
                          .map((location) => Marker(
                                point: location,
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on,
                                    color: Colors.red, size: 40),
                              ))
                          .toList(),
                    ),
                  ],
                ),
    );
  }
}
