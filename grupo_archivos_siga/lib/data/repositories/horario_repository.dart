import 'package:hive_flutter/hive_flutter.dart';
import '../models/horario.dart';

class HorarioRepository {
  static const String _boxName = 'horarios';

  Future<Box<Horario>> _getBox() async {
    return await Hive.openBox<Horario>(_boxName);
  }

  Future<void> guardarHorario(Horario horario) async {
    final box = await _getBox();
    await box.put(horario.id, horario);
  }

  Future<Horario?> obtenerHorario(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<List<Horario>> obtenerTodosHorarios() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> eliminarHorario(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> limpiarTodos() async {
    final box = await _getBox();
    await box.clear();
  }
}
