import 'package:hive/hive.dart';
import 'asignatura.dart';
import 'bloque.dart';

part 'horario.g.dart';

@HiveType(typeId: 2)
class Horario {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String estudiante;

  @HiveField(3)
  final String periodo;

  @HiveField(4)
  final List<Asignatura> asignaturas;

  @HiveField(5)
  final List<Bloque> bloques;

  Horario({
    required this.id,
    required this.nombre,
    required this.estudiante,
    required this.periodo,
    required this.asignaturas,
    required this.bloques,
  });
}
