// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactInfoAdapter extends TypeAdapter<ContactInfo> {
  @override
  final int typeId = 0;

  @override
  ContactInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContactInfo()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..avatar = fields[2] as String
      ..lastMessage = fields[3] as String
      ..isUnreadMessage = fields[4] as bool
      ..lastMesTimestamp = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, ContactInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.isUnreadMessage)
      ..writeByte(5)
      ..write(obj.lastMesTimestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
