import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/keybox.dart';
import '../providers/keybox_provider.dart';
import '../utils/code_generator.dart';

class AddKeyBoxScreen extends StatefulWidget {
  @override
  _AddKeyBoxScreenState createState() => _AddKeyBoxScreenState();
}

class _AddKeyBoxScreenState extends State<AddKeyBoxScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String description = '';
  String photoPath = '';
  final picker = ImagePicker();

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
      appBar: AppBar(title: Text('Add KeyBox')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => name = value ?? '',
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                onSaved: (value) => address = value ?? '',
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value ?? '',
              ),
              SizedBox(height: 10),
              photoPath.isNotEmpty
                  ? Image.file(File(photoPath), height: 100)
                  : ElevatedButton(
                      child: Text('Pick Photo'),
                      onPressed: pickImage,
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Save'),
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
                    Navigator.pop(context);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
