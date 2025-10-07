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
  late String? videoPath;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    name = widget.keybox.name;
    address = widget.keybox.address;
    description = widget.keybox.description;
    photoPath = widget.keybox.photoPath;
    videoPath =
        widget.keybox.videoPath.isNotEmpty ? widget.keybox.videoPath : null;
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        photoPath = pickedFile.path;
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        videoPath = pickedFile.path;
      });
    }
  }

  Future<void> _recordVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        videoPath = pickedFile.path;
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
              if (videoPath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:
                      Text('Video selected: \\${videoPath!.split('/').last}'),
                ),
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
                      videoPath: videoPath ?? '',
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
