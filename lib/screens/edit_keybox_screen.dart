import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import '../widgets/location_button.dart';

class EditKeyBoxScreen extends StatefulWidget {
  final KeyBox keybox;

  const EditKeyBoxScreen({required this.keybox, super.key});

  @override
  EditKeyBoxScreenState createState() => EditKeyBoxScreenState();
}

class EditKeyBoxScreenState extends State<EditKeyBoxScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String address;
  late String description;
  late String photoPath;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    name = widget.keybox.name;
    address = widget.keybox.address;
    description = widget.keybox.description;
    photoPath = widget.keybox.photoPath;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit KeyBox')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value ?? '',
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: address,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (value) => address = value ?? '',
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value ?? '',
              ),
              const SizedBox(height: 10),
              photoPath.isNotEmpty
                  ? Image.file(File(photoPath), height: 100)
                  : ElevatedButton(
                      onPressed: pickImage,
                      child: const Text('Pick Photo'),
                    ),
              const SizedBox(height: 10),
              LocationButton(
                onLocationFetched:
                    (fetchedAddress, fetchedLatitude, fetchedLongitude) {
                  setState(() {
                    address = fetchedAddress;
                    widget.keybox.latitude = fetchedLatitude;
                    widget.keybox.longitude = fetchedLongitude;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    provider.editKeyBox(
                      widget.keybox,
                      name: name,
                      address: address,
                      description: description,
                      photoPath: photoPath,
                      latitude: widget.keybox.latitude,
                      longitude: widget.keybox.longitude,
                    );
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
