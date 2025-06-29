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

  KeyBox({
    required this.name,
    required this.address,
    required this.description,
    required this.photoPath,
    required this.currentCode,
    this.previousCodes = const [],
  });
}
