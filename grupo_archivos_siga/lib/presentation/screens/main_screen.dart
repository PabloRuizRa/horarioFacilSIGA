import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import 'horario_screen.dart';
import 'import_screen.dart';
import 'grid_horario_screen.dart';


class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos en qué pestaña estamos
    final currentIndex = ref.watch(bottomNavProvider);

    // Lista de las 3 pantallas de nuestra app
    final screens = [
      const HorarioScreen(), // 0: Inicio
      const ImportScreen(),  // 1: Subir
      const GridHorarioScreen(), // 2: Horario (Grilla)
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Cambiamos de pestaña al tocar
          ref.read(bottomNavProvider.notifier).state = index;
        },
        selectedItemColor: const Color(0xFFE85D04), // Color naranja del Figma
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file_outlined),
            activeIcon: Icon(Icons.upload_file),
            label: 'Subir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Horario',
          ),
        ],
      ),
    );
  }
}