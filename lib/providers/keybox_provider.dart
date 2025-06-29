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
}
