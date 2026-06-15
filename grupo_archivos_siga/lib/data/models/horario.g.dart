// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'horario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HorarioAdapter extends TypeAdapter<Horario> {
  @override
  final int typeId = 2;

  @override
  Horario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Horario(
      id: fields[0] as String,
      nombre: fields[1] as String,
      estudiante: fields[2] as String,
      periodo: fields[3] as String,
      asignaturas: (fields[4] as List).cast<Asignatura>(),
      bloques: (fields[5] as List).cast<Bloque>(),
    );
  }

  @override
  void write(BinaryWriter writer, Horario obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.estudiante)
      ..writeByte(3)
      ..write(obj.periodo)
      ..writeByte(4)
      ..write(obj.asignaturas)
      ..writeByte(5)
      ..write(obj.bloques);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HorarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
