// ignore_for_file: avoid_print, unused_local_variable
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/asignatura.dart';
import '../models/bloque.dart';
import '../models/horario.dart';

class PdfParser {
  static const String apiUrl = 'http://127.0.0.1:8000/extract-text';

  Future<Horario> parseHorarioFromBytes(Uint8List pdfBytes, String fileName, String periodo) async {
    try {
      // 1. Enviar PDF a la API
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(http.MultipartFile.fromBytes('file', pdfBytes, filename: fileName));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (jsonResponse['status'] == 'error') {
        throw Exception('API Error: ${jsonResponse['message']}');
      }

      final String texto = jsonResponse['text'] ?? '';

      // 2. Extraer nombre del estudiante
      String estudiante = 'Estudiante UTFSM';
      final estudianteRegex = RegExp(r'Alumno\s*:\s*([^\n]+)');
      final estudianteMatch = estudianteRegex.firstMatch(texto);
      if (estudianteMatch != null) {
        estudiante = estudianteMatch.group(1)!.trim();
      }

      final Map<String, Asignatura> asignaturasMap = {};
      final Map<String, String> salasMap = {}; 
      final List<Bloque> bloques = [];

      // 3. Extraer TODAS las asignaturas Y LAS SALAS
      final asignaturaRegex = RegExp(r'([A-Z]{3}\d{3}[A-Z-]*?)\s*-\s*([A-ZÁÉÍÓÚÑa-záéíóúñ0-9\s]+?)\s*\((Inscrita|Preinscrita)\)(?:\s*sala\s+([A-Z0-9]+))?');
      
      for (var match in asignaturaRegex.allMatches(texto)) {
        final codigo = match.group(1)!.trim();
        final nombre = match.group(2)!.replaceAll(RegExp(r'\s+'), ' ').trim(); 
        final tipo = match.group(3)!.trim();
        final salaExtraida = match.group(4);

        // Si la Regex encontró una sala, la guardamos asociada al código del ramo
        if (salaExtraida != null) {
          salasMap[codigo] = salaExtraida;
        }

        if (!asignaturasMap.containsKey(codigo)) {
          asignaturasMap[codigo] = Asignatura(
            id: codigo,
            nombre: nombre,
            codigo: codigo,
            profesor: 'Revisar en SIGA', 
            seccion: 'Por definir',
            tipo: tipo,
          );
        }
      }

      // Respaldo: Buscar en la tabla superior (ej: ELE053-300 (Ins))
      final tablaRegex = RegExp(r'([A-Z]{3}\d{3}[A-Z]*)(-[A-Z])?-(\d{3})\s*\((Ins|Pre)\)');
      for (var match in tablaRegex.allMatches(texto)) {
        final codigoBase = match.group(1)!;
        final variante = match.group(2) ?? '';
        final codigoCompleto = '$codigoBase$variante';
        final tipo = match.group(4) == 'Ins' ? 'Inscrita' : 'Preinscrita';

        if (!asignaturasMap.containsKey(codigoCompleto)) {
          asignaturasMap[codigoCompleto] = Asignatura(
            id: codigoCompleto,
            nombre: 'Asignatura $codigoCompleto',
            codigo: codigoCompleto,
            profesor: 'Revisar en SIGA',
            seccion: match.group(3)!,
            tipo: tipo,
          );
        }
      }

      if (asignaturasMap.isEmpty) {
        throw Exception('No se encontraron asignaturas. Verifica el formato del PDF.');
      }

      // 4. Extraer bloques de horario
      final bloqueRegex = RegExp(r'\((\d{2}:\d{2})-(\d{2}:\d{2})\)');
      final matchesHoras = bloqueRegex.allMatches(texto).toList();
      
      int matchIndex = 0;
      
      for (var asignatura in asignaturasMap.values) {
        String horaIni = "00:00";
        String horaFin = "00:00";
        
        if (matchIndex < matchesHoras.length) {
           horaIni = matchesHoras[matchIndex].group(1)!;
           horaFin = matchesHoras[matchIndex].group(2)!;
           matchIndex++;
        }

        bloques.add(Bloque(
          id: '${asignatura.codigo}_blk',
          asignaturaId: asignatura.id,
          dia: 'Por definir', 
          numeroBloque: 1,
          horaInicio: horaIni,
          horaFin: horaFin,
          sala: salasMap[asignatura.codigo] ?? 'Por definir',
        ));
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
      throw Exception('Error al procesar PDF: $e');
    }
  }
}