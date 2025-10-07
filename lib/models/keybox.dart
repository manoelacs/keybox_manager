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

  @HiveField(8)
  String videoPath; // Added videoPath field

  KeyBox({
    required this.name,
    required this.address,
    required this.description,
    required this.currentCode,
    required this.photoPath,
    List<String>? previousCodes,
    required this.latitude, // Initialize latitude
    required this.longitude, // Initialize longitude
    this.videoPath = '',
  }) : previousCodes = previousCodes ?? [];

  // Update fromJson and toJson if present
  factory KeyBox.fromJson(Map<String, dynamic> json) => KeyBox(
        name: json['name'],
        address: json['address'],
        description: json['description'],
        currentCode: json['currentCode'],
        photoPath: json['photoPath'],
        previousCodes: List<String>.from(json['previousCodes']),
        latitude: json['latitude'],
        longitude: json['longitude'],
        videoPath: json['videoPath'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'description': description,
        'currentCode': currentCode,
        'photoPath': photoPath,
        'previousCodes': previousCodes,
        'latitude': latitude,
        'longitude': longitude,
        'videoPath': videoPath,
      };
}
