import 'package:hive_flutter/hive_flutter.dart';
import '../models/horario.dart';

class HorarioRepository {
  static const String _boxName = 'horarios';
  late Box<Horario> _box;

  HorarioRepository() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Horario>(_boxName);
  }

  Future<void> guardarHorario(Horario horario) async {
    await _box.put(horario.id, horario);
  }

  Horario? obtenerHorario(String id) {
    return _box.get(id);
  }

  List<Horario> obtenerTodosHorarios() {
    return _box.values.toList();
  }

  Future<void> eliminarHorario(String id) async {
    await _box.delete(id);
  }
}
