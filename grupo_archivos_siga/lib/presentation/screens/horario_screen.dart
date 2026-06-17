import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/horario_provider.dart';
import 'import_screen.dart';
import 'login_screen.dart';

class HorarioScreen extends ConsumerWidget {
  const HorarioScreen({super.key});

  Widget _buildDrawer(BuildContext context) {
    // Obtenemos el usuario actual de Firebase
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? 'correo@usm.cl';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0033A0), Color(0xFF6B4E9E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: const Text(
              'Estudiante UTFSM',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF0033A0)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule, color: Color(0xFF0033A0)),
            title: const Text('Mi Horario'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file, color: Color(0xFF0033A0)),
            title: const Text('Importar Nuevo Horario'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horario = ref.watch(horarioProvider);

    if (horario == null) {
      return Scaffold(
        appBar: AppBar(
        title: const Text('Mi Horario'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B2A4A),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Mostrar el botón de borrar solo si hay un horario cargado
          if (horario != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                ref.read(horarioProvider.notifier).eliminarHorarioActual();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Horario eliminado')),
                );
              },
            ),
        ],
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ImportScreen()),
                  );
                },
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
      drawer: _buildDrawer(context),
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