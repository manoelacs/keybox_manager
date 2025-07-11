import 'package:hive/hive.dart';

part 'keybox.g.dart';

@HiveType(typeId: 0)
class KeyBox extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String address;

  @HiveField(2)
  String description;

  @HiveField(3)
  String photoPath;

  @HiveField(4)
  String currentCode;

  @HiveField(5)
  List<String> previousCodes;

  @HiveField(6)
  double latitude; // Added latitude field

  @HiveField(7)
  double longitude; // Added longitude field

  KeyBox({
    required this.name,
    required this.address,
    required this.description,
    required this.currentCode,
    required this.photoPath,
    List<String>? previousCodes,
    required this.latitude, // Initialize latitude
    required this.longitude, // Initialize longitude
  }) : previousCodes = previousCodes ?? [];
}
