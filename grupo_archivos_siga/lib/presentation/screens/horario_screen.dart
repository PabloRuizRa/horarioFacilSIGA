import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/horario_provider.dart';

class HorarioScreen extends ConsumerWidget {
  const HorarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horario = ref.watch(horarioProvider);

    if (horario == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi Horario'),
          backgroundColor: const Color(0xFF0033A0),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No hay horario cargado'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Importar Horario'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(horario.nombre),
        backgroundColor: const Color(0xFF0033A0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Información del estudiante
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(
                  avatar: const Icon(Icons.person, size: 16),
                  label: Text(horario.estudiante),
                ),
                Chip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(horario.periodo),
                ),
                Chip(
                  avatar: const Icon(Icons.book, size: 16),
                  label: Text('${horario.asignaturas.length} ramos'),
                ),
              ],
            ),
          ),
          // Lista de bloques
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: horario.bloques.length,
              itemBuilder: (context, index) {
                final bloque = horario.bloques[index];
                final asignatura = horario.asignaturas.firstWhere(
                  (a) => a.id == bloque.asignaturaId,
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 6,
                      height: 40,
                      color: Colors.blue.shade200,
                    ),
                    title: Text(asignatura.nombre),
                    subtitle: Text('${bloque.dia} • ${bloque.horaInicio} - ${bloque.horaFin} • ${bloque.sala}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _mostrarDetalle(context, asignatura, bloque);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalle(BuildContext context, dynamic asignatura, dynamic bloque) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asignatura.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${asignatura.codigo}'),
            const SizedBox(height: 8),
            Text('Profesor: ${asignatura.profesor}'),
            Text('Día: ${bloque.dia}'),
            Text('Horario: ${bloque.horaInicio} - ${bloque.horaFin}'),
            Text('Sala: ${bloque.sala}'),
            Text('Tipo: ${asignatura.tipo}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
