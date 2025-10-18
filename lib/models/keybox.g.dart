// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keybox.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KeyBoxAdapter extends TypeAdapter<KeyBox> {
  @override
  final int typeId = 0;

  @override
  KeyBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KeyBox(
      name: fields[0] as String,
      address: fields[1] as String,
      description: fields[2] as String,
      currentCode: fields[4] as String,
      photoPath: fields[3] as String,
      previousCodes: (fields[5] as List?)?.cast<String>(),
      latitude: fields[6] as double,
      longitude: fields[7] as double,
      videoPath: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KeyBox obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.photoPath)
      ..writeByte(4)
      ..write(obj.currentCode)
      ..writeByte(5)
      ..write(obj.previousCodes)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.videoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
