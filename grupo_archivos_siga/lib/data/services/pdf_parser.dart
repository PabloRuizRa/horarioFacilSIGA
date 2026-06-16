// ignore_for_file: avoid_print, unused_local_variable
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/asignatura.dart';
import '../models/bloque.dart';
import '../models/horario.dart';

class PdfParser {
  static const String apiUrl = 'http://127.0.0.1:8000/extract-text';

  Future<Horario> parseHorarioFromPDF(File pdfFile, String periodo) async {
    try {
      // 1. Enviar PDF a la API
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'error') {
        throw Exception('API Error: ${jsonResponse['message']}');
      }

      final String texto = jsonResponse['text'] ?? '';
      print('=== TEXTO EXTRAÍDO ===');
      print(texto.substring(0, texto.length > 500 ? 500 : texto.length));
      print('======================');

      // 2. Extraer nombre del estudiante
      String estudiante = 'Estudiante UTFSM';
      final estudianteRegex = RegExp(r'Alumno\s*:\s*([^\n]+)');
      final estudianteMatch = estudianteRegex.firstMatch(texto);
      if (estudianteMatch != null) {
        estudiante = estudianteMatch.group(1)!.trim();
      }

      // 3. Extraer asignaturas y bloques
      final Map<String, Asignatura> asignaturasMap = {};
      final List<Bloque> bloques = [];

      // Patrón para el detalle de horario
      final detalleRegex = RegExp(
        r'(\d+) \((\d{2}:\d{2})[-–](\d{2}:\d{2})\)\s+([A-Z0-9]+)\s*-\s*([^-]+?)\s*\(([^)]+)\)\s+sala\s+(\S+)\s+(\d+)\s+([A-Za-zÁÉÍÓÚÑáéíóúñ\s]+)\s+([A-Za-z.]+)\s+([^\n]+)',
      );

      for (var match in detalleRegex.allMatches(texto)) {
        final numBloque = int.parse(match.group(1)!);
        final horaInicio = match.group(2)!;
        final horaFin = match.group(3)!;
        final codigo = match.group(4)!;
        String nombreCompleto = match.group(5)!.trim();
        final tipo = match.group(6)!.contains('Inscrita') ? 'Inscrita' : 'Preinscrita';
        final sala = match.group(7)!;
        final seccion = match.group(8)!;
        final profesor = match.group(9)!.trim();

        // Limpiar nombre
        nombreCompleto = nombreCompleto.replaceAll(RegExp(r'\([^)]+\)'), '').trim();

        // Día desde el contexto (lo determinamos por la posición)
        String dia = _determinarDia(texto, match.start);

        // Crear o obtener asignatura
        if (!asignaturasMap.containsKey(codigo)) {
          asignaturasMap[codigo] = Asignatura(
            id: codigo,
            nombre: nombreCompleto,
            codigo: codigo,
            profesor: profesor,
            seccion: seccion,
            tipo: tipo,
          );
        }

        bloques.add(Bloque(
          id: '${codigo}_${dia}_$numBloque',
          asignaturaId: codigo,
          dia: dia,
          numeroBloque: numBloque,
          horaInicio: horaInicio,
          horaFin: horaFin,
          sala: sala,
        ));
      }

      // También buscar en la tabla de horario
      final tablaRegex = RegExp(r'(\d+)\s+([A-Z0-9]+)\s*-\s*(\d+)\s*\(([^)]+)\)');

      for (var match in tablaRegex.allMatches(texto)) {
        final numBloque = int.parse(match.group(1)!);
        final codigo = match.group(2)!;
        final seccion = match.group(3)!;
        final tipo = match.group(4)!.contains('Ins') ? 'Inscrita' : 'Preinscrita';

        if (!asignaturasMap.containsKey(codigo)) {
          asignaturasMap[codigo] = Asignatura(
            id: codigo,
            nombre: codigo,
            codigo: codigo,
            profesor: 'Por definir',
            seccion: seccion.toString(),
            tipo: tipo,
          );
        }
      }

      if (asignaturasMap.isEmpty) {
        throw Exception('No se pudo extraer información del PDF. Verifica el formato.');
      }

      return Horario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: 'Horario $periodo',
        estudiante: estudiante,
        periodo: periodo,
        asignaturas: asignaturasMap.values.toList(),
        bloques: bloques,
      );
    } catch (e) {
      print('Error en parseHorarioFromPDF: $e');
      throw Exception('Error al procesar PDF: $e');
    }
  }

  String _determinarDia(String texto, int posicion) {
    final textoAntes = texto.substring(0, posicion > 500 ? posicion : 0);

    if (textoAntes.contains('Lunes')) return 'Lunes';
    if (textoAntes.contains('Martes')) return 'Martes';
    if (textoAntes.contains('Miércoles')) return 'Miércoles';
    if (textoAntes.contains('Jueves')) return 'Jueves';
    if (textoAntes.contains('Viernes')) return 'Viernes';
    if (textoAntes.contains('Sábado')) return 'Sábado';

    return 'Por definir';
  }
}
