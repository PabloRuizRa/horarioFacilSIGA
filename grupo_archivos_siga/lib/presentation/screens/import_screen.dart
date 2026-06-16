import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../providers/horario_provider.dart';
import 'horario_screen.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool isLoading = false;

  Future<void> importarPDF() async {
    setState(() => isLoading = true);
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);

        if (!mounted) return;

        final periodo = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Seleccionar Periodo'),
            content: const Text('Ingrese el periodo académico (ej: 2026-1)'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, '2026-1'),
                child: const Text('Importar'),
              ),
            ],
          ),
        );

        if (periodo != null) {
          await ref.read(horarioProvider.notifier).importarHorario(file, periodo);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HorarioScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Horario'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0033A0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, size: 100, color: Colors.red.shade400),
            const SizedBox(height: 20),
            const Text(
              'Importa tu horario desde SIGA',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '📄 Paso 1: Ve a SIGA\n'
                '📅 Paso 2: Ve a tu horario\n'
                '🖨️ Paso 3: Haz clic en "Imprimir" y guarda como PDF\n'
                '📂 Paso 4: Importa el archivo aquí',
                textAlign: TextAlign.left,
                style: TextStyle(height: 1.8),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : importarPDF,
                icon: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file),
                label: Text(isLoading ? 'Procesando PDF...' : 'Seleccionar archivo PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0033A0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
