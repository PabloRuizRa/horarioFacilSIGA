import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/asignatura.dart';
import '../../data/models/bloque.dart';
import '../providers/horario_provider.dart';

class GridHorarioScreen extends ConsumerWidget {
  const GridHorarioScreen({super.key});

  static const List<Color> _coloresRamos = [
    Color(0xFFB3E5FC), Color(0xFFA5D6A7), Color(0xFFFFF59D),
    Color(0xFFF48FB1), Color(0xFFCE93D8),
  ];

  static const List<String> _rangos = [
    "8:15 - 8:50", "8:50 - 9:25", "9:40 - 10:15", "10:15 - 10:50",
    "11:05 - 11:40", "11:40 - 12:15", "12:30 - 13:05", "13:05 - 13:40",
    "14:40 - 15:15", "15:15 - 15:50", "16:05 - 16:40", "16:40 - 17:15",
    "17:30 - 18:05", "18:05 - 18:40", "18:55 - 19:30", "19:30 - 20:05",
    "20:20 - 20:55", "20:55 - 21:30", "21:45 - 22:20", "22:20 - 22:55"
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horario = ref.watch(horarioProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Mi Horario'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B2A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: horario == null
          ? const Center(child: Text('Importa tu horario primero en la pestaña "Subir"'))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 55), // Espacio para la columna de hora
                      _buildHeaderDia('Lun'),
                      _buildHeaderDia('Mar'),
                      _buildHeaderDia('Mié'),
                      _buildHeaderDia('Jue'),
                      _buildHeaderDia('Vie'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20, // <-- Ahora son 20 bloques
                      itemBuilder: (context, index) {
                        final numBloque = index + 1;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 55,
                              height: 65,
                              margin: const EdgeInsets.only(bottom: 8, right: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2A4A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$numBloque', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(_rangos[index], style: const TextStyle(color: Colors.white70, fontSize: 8)),
                                ],
                              ),
                            ),
                            _buildCelda(horario.bloques, horario.asignaturas, 'Lunes', numBloque),
                            _buildCelda(horario.bloques, horario.asignaturas, 'Martes', numBloque),
                            _buildCelda(horario.bloques, horario.asignaturas, 'Miércoles', numBloque),
                            _buildCelda(horario.bloques, horario.asignaturas, 'Jueves', numBloque),
                            _buildCelda(horario.bloques, horario.asignaturas, 'Viernes', numBloque),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderDia(String dia) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2A4A),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          dia,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCelda(List<Bloque> bloques, List<Asignatura> asignaturas, String diaBusqueda, int bloqueNum) {
    final bloqueInfo = bloques.where((b) => b.dia == diaBusqueda && b.numeroBloque == bloqueNum).firstOrNull;

    if (bloqueInfo == null) {
      return Expanded(
        child: Container(
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    final asignatura = asignaturas.firstWhere((a) => a.id == bloqueInfo.asignaturaId);
    final colorIndex = asignaturas.indexOf(asignatura) % _coloresRamos.length;
    String nombreCorto = asignatura.nombre.length > 12 ? '${asignatura.nombre.substring(0, 12)}...' : asignatura.nombre;

    return Expanded(
      child: Container(
        height: 65,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _coloresRamos[colorIndex],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(nombreCorto, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
            Text(bloqueInfo.sala, style: const TextStyle(fontSize: 9, color: Colors.black54), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}