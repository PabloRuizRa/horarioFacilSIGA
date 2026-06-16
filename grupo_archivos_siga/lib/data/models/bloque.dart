import 'package:hive/hive.dart';

part 'bloque.g.dart';

@HiveType(typeId: 1)
class Bloque {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String asignaturaId;

  @HiveField(2)
  final String dia;

  @HiveField(3)
  final int numeroBloque;

  @HiveField(4)
  final String horaInicio;

  @HiveField(5)
  final String horaFin;

  @HiveField(6)
  final String sala;

  Bloque({
    required this.id,
    required this.asignaturaId,
    required this.dia,
    required this.numeroBloque,
    required this.horaInicio,
    required this.horaFin,
    required this.sala,
  });
}
