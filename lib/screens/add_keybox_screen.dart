import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import '../utils/code_generator.dart';

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
  final picker = ImagePicker();
  final addressController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    addressController.text = address;
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        photoPath = pickedFile.path;
      });
    }
  }

  Future<void> fetchAddressFromLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        print('Current position: $position');

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.firstWhere(
            (p) => p.thoroughfare?.isNotEmpty ?? false,
            orElse: () => placemarks.first,
          );

          print(place.thoroughfare);
          final placemark = place;
          setState(() {
            address =
                '${placemark.thoroughfare}, ${placemark.locality}, ${placemark.country}';
            addressController.text = address;
          });
          print('Address fetched: $address');
        }
      } on TimeoutException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location request timed out.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch location: $e')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch location: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
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
                  OutlinedButton.icon(
                    onPressed: fetchAddressFromLocation,
                    icon: const Icon(Icons.location_on, color: Colors.blue),
                    label: const Text('Use Current Location',
                        style: TextStyle(color: Colors.blue)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onSaved: (value) =>
                        description = value ?? 'The description of the KeyBox',
                  ),
                  const SizedBox(height: 10),
                  photoPath.isNotEmpty
                      ? Image.file(File(photoPath), height: 100)
                      : ElevatedButton(
                          onPressed: pickImage,
                          child: const Text('Pick Photo'),
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
                          currentCode: generateRandomCode(),
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
