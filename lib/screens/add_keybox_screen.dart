import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:keybox_manager/widgets/location_picker.dart';
import 'package:provider/provider.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import '../utils/code_generator.dart';
import '../widgets/location_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddKeyBoxScreen extends StatefulWidget {
  const AddKeyBoxScreen({super.key});

  @override
  AddKeyBoxScreenState createState() => AddKeyBoxScreenState();
}

class AddKeyBoxScreenState extends State<AddKeyBoxScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String description = '';
  String photoPath = '';
  String currentCode = '';
  final picker = ImagePicker();
  final addressController = TextEditingController();
  bool isLoading = false;
  double latitude = 0.0;
  double longitude = 0.0;
  String? _videoPath;

  @override
  void initState() {
    super.initState();
    addressController.text = address;
  }

  static Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // Implement the logic to fetch the address using latitude and longitude
    // For example, using a geocoding API
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks.first.street ?? 'Unknown Address';
      }
      return 'Unknown Address';
    } catch (e) {
      return 'Error fetching address';
    }
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        photoPath = pickedFile.path;
      });
    }
  }

  void onLocationPicked(LatLng pickedLocation) async {
    latitude = pickedLocation.latitude;
    longitude = pickedLocation.longitude;
    // Use a geocoding service to get the address from the latitude and longitude
    address = await getAddressFromCoordinates(latitude, longitude);
    setState(() {
      addressController.text = address;
    });
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
      });
    }
  }

  Future<void> _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _videoPath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<KeyBoxProvider>(context, listen: false);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Add KeyBox')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    onSaved: (value) => name = value ?? '',
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    onSaved: (value) =>
                        address = value ?? 'The address of the KeyBox',
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  LocationButton(
                    onLocationFetched:
                        (fetchedAddress, fetchedLatitude, fetchedLongitude) {
                      setState(() {
                        address = fetchedAddress;
                        latitude = fetchedLatitude;
                        longitude = fetchedLongitude;
                        addressController.text = fetchedAddress;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) =>
                        description = value ?? 'The description of the KeyBox',
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Existing Code (Optional)'),
                    onSaved: (value) {
                      final code = generateRandomCode();
                      currentCode =
                          value != null && value.isNotEmpty ? value : code;
                      if (kDebugMode) {
                        print('Generated code: $code');
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  photoPath.isNotEmpty
                      ? Image.file(File(photoPath), height: 100)
                      : ElevatedButton(
                          onPressed: pickImage,
                          child: const Text('Pick Photo'),
                        ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.video_library),
                        label: const Text('Pick Video'),
                        onPressed: _pickVideo,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.videocam),
                        label: const Text('Record Video'),
                        onPressed: _recordVideo,
                      ),
                    ],
                  ),
                  if (_videoPath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          'Video selected: \\${_videoPath!.split('/').last}'),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final newKeyBox = KeyBox(
                          name: name,
                          address: address,
                          description: description,
                          photoPath: photoPath,
                          currentCode: currentCode,
                          latitude: latitude,
                          longitude: longitude,
                          previousCodes: [],
                          videoPath: _videoPath ?? '',
                        );
                        provider.addKeyBox(newKeyBox);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('KeyBox added')),
                        );

                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
