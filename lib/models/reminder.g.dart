// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 1;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      watchlistItemId: fields[1] as String,
      movieTitle: fields[2] as String,
      moviePosterUrl: fields[3] as String?,
      scheduledDateTime: fields[4] as DateTime,
      timezone: fields[5] as String,
      isCompleted: fields[6] as bool,
      createdAt: fields[7] as DateTime,
      notificationId: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.watchlistItemId)
      ..writeByte(2)
      ..write(obj.movieTitle)
      ..writeByte(3)
      ..write(obj.moviePosterUrl)
      ..writeByte(4)
      ..write(obj.scheduledDateTime)
      ..writeByte(5)
      ..write(obj.timezone)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
