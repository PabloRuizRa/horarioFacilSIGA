// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bloque.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BloqueAdapter extends TypeAdapter<Bloque> {
  @override
  final int typeId = 1;

  @override
  Bloque read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bloque(
      id: fields[0] as String,
      asignaturaId: fields[1] as String,
      dia: fields[2] as String,
      numeroBloque: fields[3] as int,
      horaInicio: fields[4] as String,
      horaFin: fields[5] as String,
      sala: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Bloque obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.asignaturaId)
      ..writeByte(2)
      ..write(obj.dia)
      ..writeByte(3)
      ..write(obj.numeroBloque)
      ..writeByte(4)
      ..write(obj.horaInicio)
      ..writeByte(5)
      ..write(obj.horaFin)
      ..writeByte(6)
      ..write(obj.sala);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloqueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
