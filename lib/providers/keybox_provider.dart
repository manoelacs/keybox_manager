import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/keybox.dart';
import '../utils/code_generator.dart';

class KeyBoxProvider with ChangeNotifier {
  final Box<KeyBox> _box = Hive.box<KeyBox>('keyboxes');

  List<KeyBox> get keyboxes => _box.values.toList();

  double _currentLatitude = 0.0; // Default value
  double _currentLongitude = 0.0; // Default value

  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;

  void addKeyBox(KeyBox keybox) {
    _box.add(keybox);
    notifyListeners();
  }

  void updateCode(KeyBox keybox) {
    String newCode = generateRandomCode();
    keybox.previousCodes.add(keybox.currentCode);
    keybox.currentCode = newCode;
    keybox.save();
    if (kDebugMode) {
      print('Updated code for ${keybox.name}: ${keybox.currentCode}');
    }
    notifyListeners();
  }

  void createCode(KeyBox keybox) {
    String newCode = generateRandomCode();
    keybox.currentCode = newCode;
    keybox.previousCodes.add(newCode);
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
    required double latitude,
    required double longitude,
    required String videoPath,
  }) {
    keybox.name = name;
    keybox.address = address;
    keybox.description = description;
    keybox.photoPath = photoPath;
    keybox.latitude = latitude;
    keybox.longitude = longitude;
    keybox.videoPath = videoPath;
    notifyListeners();
  }

  void updateCurrentLocation(double latitude, double longitude) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;
    notifyListeners();
  }

  void addExistingCode(KeyBox keybox, String newCode) {
    final index = keyboxes.indexOf(keybox);
    if (index != -1) {
      keyboxes[index].previousCodes.add(keyboxes[index].currentCode);
      keyboxes[index].currentCode = newCode;
      notifyListeners();
    }
  }
}
