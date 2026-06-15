import 'package:hive/hive.dart';

part '../bloque.g.dart';

@HiveType(typeId: 1)
class Bloque {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String asignaturaId;

  @HiveField(2)
  final String dia;

  @HiveField(3)
  final String horaInicio;

  @HiveField(4)
  final String horaFin;

  @HiveField(5)
  final String sala;

  @HiveField(6)
  final int bloqueNumero;

  Bloque({
    required this.id,
    required this.asignaturaId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.sala,
    required this.bloqueNumero,
  });
}
