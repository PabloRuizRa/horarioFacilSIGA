import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'asignatura.g.dart';

@HiveType(typeId: 0)
class Asignatura {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String codigo;

  @HiveField(3)
  final String profesor;

  @HiveField(4)
  final String seccion;

  @HiveField(5)
  final String tipo;

  Asignatura({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.profesor,
    required this.seccion,
    required this.tipo,
  });

  Color get color {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink];
    return colors[id.hashCode % colors.length].withOpacity(0.3);
  }
}
