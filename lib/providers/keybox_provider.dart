import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/keybox.dart';
import '../utils/code_generator.dart';

class KeyBoxProvider with ChangeNotifier {
  final Box<KeyBox> _box = Hive.box<KeyBox>('keyboxes');

  List<KeyBox> get keyboxes => _box.values.toList();

  void addKeyBox(KeyBox keybox) {
    _box.add(keybox);
    notifyListeners();
  }

  void updateCode(KeyBox keybox) {
    String newCode = generateRandomCode();
    keybox.previousCodes.add(keybox.currentCode);
    keybox.currentCode = newCode;
    keybox.save();
    notifyListeners();
  }

  void deleteKeyBox(KeyBox keybox) {
    keybox.delete();
    notifyListeners();
  }

  void editKeyBox(
    KeyBox keybox, {
    required String name,
    required String address,
    required String description,
    required String photoPath,
  }) {
    keybox.name = name;
    keybox.address = address;
    keybox.description = description;
    keybox.photoPath = photoPath;
    keybox.save();
    notifyListeners();
  }
}
