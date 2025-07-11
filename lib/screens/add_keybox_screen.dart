import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import '../utils/code_generator.dart';
import '../widgets/location_button.dart';

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
                    onSaved: (value) =>
                        currentCode = value ?? generateRandomCode(),
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
                          currentCode: currentCode,
                          latitude: latitude,
                          longitude: longitude,
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
