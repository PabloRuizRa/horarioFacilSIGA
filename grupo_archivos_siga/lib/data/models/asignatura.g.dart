// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asignatura.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AsignaturaAdapter extends TypeAdapter<Asignatura> {
  @override
  final int typeId = 0;

  @override
  Asignatura read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Asignatura(
      id: fields[0] as String,
      nombre: fields[1] as String,
      codigo: fields[2] as String,
      profesor: fields[3] as String,
      seccion: fields[4] as String,
      tipo: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Asignatura obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.codigo)
      ..writeByte(3)
      ..write(obj.profesor)
      ..writeByte(4)
      ..write(obj.seccion)
      ..writeByte(5)
      ..write(obj.tipo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsignaturaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
