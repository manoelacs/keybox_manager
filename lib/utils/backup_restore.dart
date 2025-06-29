import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/keybox.dart';

Future<void> exportKeyBoxes() async {
  final box = Hive.box<KeyBox>('keyboxes');
  final List<Map<String, dynamic>> data = box.values
      .map((kb) => {
            'name': kb.name,
            'address': kb.address,
            'description': kb.description,
            'photoPath': kb.photoPath,
            'currentCode': kb.currentCode,
            'previousCodes': kb.previousCodes,
          })
      .toList();

  final jsonString = jsonEncode(data);

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/keyboxes_backup.json');
  await file.writeAsString(jsonString);
}

Future<void> importKeyBoxes() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/keyboxes_backup.json');
  if (!(await file.exists())) return;

  final jsonString = await file.readAsString();
  final List<dynamic> data = jsonDecode(jsonString);

  final box = Hive.box<KeyBox>('keyboxes');
  for (var item in data) {
    final kb = KeyBox(
      name: item['name'],
      address: item['address'],
      description: item['description'],
      photoPath: item['photoPath'],
      currentCode: item['currentCode'],
      previousCodes: List<String>.from(item['previousCodes']),
    );
    box.add(kb);
  }
}
