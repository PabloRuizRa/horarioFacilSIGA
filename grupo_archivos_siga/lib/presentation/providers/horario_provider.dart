import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../data/models/horario.dart';
import '../../data/services/pdf_parser.dart';
import '../../data/repositories/horario_repository.dart';

final pdfParserProvider = Provider((ref) => PdfParser());
final repositoryProvider = Provider((ref) => HorarioRepository());

final horarioProvider = StateNotifierProvider<HorarioNotifier, Horario?>((ref) {
  return HorarioNotifier(ref);
});

class HorarioNotifier extends StateNotifier<Horario?> {
  final Ref ref;

  HorarioNotifier(this.ref) : super(null);

  Future<void> importarHorario(File pdf, String periodo) async {
    final parser = ref.read(pdfParserProvider);
    final repo = ref.read(repositoryProvider);
    final horario = await parser.parseHorarioFromPDF(pdf, periodo);
    await repo.guardarHorario(horario);
    state = horario;
  }

  Future<void> cargarHorario(String id) async {
    final repo = ref.read(repositoryProvider);
    final horario = await repo.obtenerHorario(id);
    state = horario;
  }
}
